extends KinematicBody2D

export (PackedScene) var Bars

const UP = Vector2(0,-1)
var GRAVITY = 3000
var SPEED = 400
const ACCELERATION = 70
const JUMP = -1000

var velocity = Vector2()
var doublejump = true
var health = 100
var sp = 0
var gun_mode = false
var req = false
var bars
var backsteps = 2
var lives
var attack_num = 0
var gay = false
var smudge = false

onready var hurt_timer = 0.1
onready var pos_update_timer = 0.5
onready var gay_timer = 0.1

#PUPPET VARS
puppet var slave_position = Vector2()
puppet var slave_velocity = Vector2()
puppet var slave_health = 100
puppet var slave_sp = 0

signal backstep

func _ready():
	lives = get_node("/root/main").lives
	var number = 0
	var n = 0
	while n < Network.players.size():
		var targ = Network.players.keys()[n]
		number = n
		if Network.players[targ].character == get_parent().name:
			$Label.text = Network.players[targ].name
			break
		n += 1
	var node = Bars.instance()
	get_node("/root/main").call_deferred("add_child", node)
	node.position = get_node("/root/main").get_child(number + 1).position
	node._set_player(self)
	node._set_num(number)

func _process(delta):
	if health > 100:
		health = 100
	if hurt_timer >= 0:
		hurt_timer -= delta
	if hurt_timer <= 0 and health > 0:
		modulate = Color(1,1,1)
	if gay_timer >= 0 and gay:
		gay_timer -= delta
	else:
		gay = false
		for child in get_children():
			if child.name == ("gay"):
				child.queue_free()
#GRAVITY
	velocity.y += GRAVITY * delta
#RIGHT/LEFT MOVEMENT
	if is_network_master():
		if Input.is_action_pressed("ui_right"):
			velocity.x = min(velocity.x + ACCELERATION, SPEED)
		elif Input.is_action_pressed("ui_left"):
			velocity.x = max(velocity.x - ACCELERATION, -SPEED)
		else:
			if is_on_floor():
				velocity.x = lerp(velocity.x, 0, 0.4)
			else:
				velocity.x = lerp(velocity.x, 0, 0.05)
		rset("slave_velocity", velocity)
		rset("slave_position", position)
		rset("slave_health", health)
		rset("slave_sp", sp)
	else:
		health = slave_health
		velocity.x = slave_velocity.x
		if pos_update_timer >= 0:
			pos_update_timer -= delta
		else:
			if abs(position.x - slave_position.x) > 10 or abs(position.y - slave_position.y) > 10:
				position = slave_position
				sp = slave_sp
			pos_update_timer = 0.2
#VELOCITY PROCESSING
	velocity = move_and_slide(velocity, UP)
#ANIMATIONS
	if is_on_floor():
		doublejump = true
		if abs(velocity.x) >= 120 and velocity.x/$Sprite.scale.x > 0:
			_animate("run")
		else:
			_animate("idle")
	else:
		if velocity.y <= 0:
			_animate("jump")
		else:
			_animate("fall")
#SP
	if sp > 100:
		sp = 100

func _input(event):
	var ev
	if event.is_action_pressed("ui_left"):
		ev = ("left")
	elif event.is_action_pressed("ui_right"):
		ev = ("right")
	elif event.is_action_pressed("ui_up"):
		ev = ("up")
#BACK STEP
	if event.is_action_pressed("ui_down") and not get_parent().get_node("AnimationPlayer").current_animation == ("run") and backsteps > 0:
		ev = ("down")
#PRESS Z
	if event.is_action_pressed("z"):
		ev = ("z")
#PRESS X
	elif event.is_action_pressed("x") and not gun_mode:
		ev = ("x")
#PRESS C
	elif event.is_action_pressed("c"):
		ev = ("c")
#PRESS V
	elif event.is_action_pressed("v"):
		ev = ("v")

	if is_network_master():
		rpc("_input_effect", ev)

remotesync func _input_effect(event):
	if event == ("left"):
		$Sprite.scale = Vector2(-1, 1)
	elif event == ("right"):
		$Sprite.scale = Vector2(1, 1)
	if event == ("up"):
		if is_on_floor():
			velocity.y = JUMP
		else:
			if doublejump:
				velocity.y = JUMP
				doublejump = false
	if event == ("down"):
		_backstep()
	if event == ("z"):
		if gun_mode:
			$Sprite/handR/weapon.show()
			gun_mode = false
			$Sprite/gun.hide()
			get_parent().get_node("AnimationPlayer2").stop()
		else:
			var attack_anims = ["attack", "stab"]
			if not attack_anims.has(get_parent().get_node("AnimationPlayer2").current_animation):
				if attack_num < 2:
					_animate2("attack")
					attack_num += 1
				else:
					_animate2("stab")
					attack_num = 0
	if event == ("x") and get_parent().ult == false:
		$Sprite/handR/weapon.hide()
		gun_mode = true
		$Sprite/gun.show()
	if event == ("c"):
#SP MINI
		if sp >= 33 and gun_mode == req:
			sp -= 33
			get_parent()._sp_mini()
	if event == ("v"):
#ULT
		#if sp == 100:
			#sp = 0
			#$Sprite/head/eyes.show()
		get_parent()._ult()

func _damage(num):
	if not get_parent().ult == true and get_parent().get_node("DeathTimer").is_stopped():
		hurt_timer = 0.1
		modulate = Color(0.9,0,0)
		health -= num
		sp += 2 * num/3
		if health <= 0:
			if is_network_master():
				rpc("_die")

func _animate(anim):
	if get_parent().get_node("AnimationPlayer").current_animation != (anim):
		get_parent().get_node("AnimationPlayer").play(anim)

func _animate2(anim):
	if get_parent().get_node("AnimationPlayer2").current_animation != (anim):
		get_parent().get_node("AnimationPlayer2").play(anim)

func _on_weapon_body_entered(body):
	if body != self:
		if body.is_in_group("player"):
			if not (gay == true and body == get_node("/root/main/hollis/KinematicBody2D")):
				get_parent()._harm(body)

func _backstep():
	if is_on_floor():
		velocity.x = -4000 * $Sprite.scale.x
	else:
		velocity.y = 0
		velocity.x = -900 * $Sprite.scale.x
	emit_signal("backstep")
	backsteps -= 1

remotesync func _die():
	$Sprite/head/eyes.show()
	$Sprite/head/eyes.modulate = Color(0,0,0)
	$Sprite/handR/weapon.hide()
	$Sprite/gun.hide()
	_animate2("die")
	SPEED = 0
	gun_mode = false
	set_process_input(false)
	set_collision_layer_bit(2, true)
	set_collision_layer_bit(1, false)
	set_collision_mask_bit(2, true)
	set_collision_mask_bit(1, false)
	get_parent().get_node("DeathTimer").start()

func _on_DeathTimer_timeout():
	#REDUCE LIFE BY ONE
	health = 100
	sp = sp/2
	if lives > 1:
		lives -= 1
	else:
		lives -= 1
		get_parent().queue_free()
	modulate.a = 1
	$Sprite/head/eyes.hide()
	$Sprite/head/eyes.modulate = Color(1,1,1)
	$Sprite/handR/weapon.show()
	SPEED = 400
	set_process_input(true)
	get_parent().set_process_input(true)
	set_collision_layer_bit(1, true)
	set_collision_layer_bit(2, false)
	set_collision_mask_bit(1, true)
	set_collision_mask_bit(2, false)
	get_node("/root/main/spawner")._respawn(self)
	get_parent().get_node("AnimationPlayer2").stop()
	pos_update_timer = 0.1

func _gay():
	gay_timer = 10
	gay = true
