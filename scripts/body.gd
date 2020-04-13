extends KinematicBody2D

export (PackedScene) var Bars

const UP = Vector2(0,-1)
var GRAVITY = 50
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
var master_character = false
var lives

#SLAVE VARS
slave var slave_position = Vector2()
slave var slave_velocity = Vector2()

signal backstep
signal dead

func _ready():
	lives = get_node("/root/main").lives
	if Gamestate.player_info.character == get_parent().name:
		master_character = true
	var number = 0
	var n = 0
	while n < Network.players.size():
		var targ = Network.players.keys()[n]
		number = n
		if Network.players[targ].character == get_parent().name:
			break
		n += 1
	var node = Bars.instance()
	get_node("/root/main").call_deferred("add_child", node)
	node.position = get_node("/root/main").get_child(number + 1).position
	node._set_player(self)
	node._set_num(number)

func _process(_delta):
	#rset("slave_position", position)
#GRAVITY
	velocity.y += GRAVITY
#RIGHT/LEFT MOVEMENT
	if master_character:
		if Input.is_action_pressed("ui_right"):
			velocity.x = min(velocity.x + ACCELERATION, SPEED)
			#rset("slave_velocity", velocity)
		elif Input.is_action_pressed("ui_left"):
			velocity.x = max(velocity.x - ACCELERATION, -SPEED)
			#rset("slave_velocity", velocity)
		else:
			if is_on_floor():
				velocity.x = lerp(velocity.x, 0, 0.4)
			else:
				velocity.x = lerp(velocity.x, 0, 0.05)
	#else:
		#velocity = slave_velocity
		#position = slave_position
	velocity = move_and_slide(velocity, UP)
#ANIMATIONS
	if is_on_floor():
		doublejump = true
		if abs(velocity.x) >= 5 and (Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")):
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
	if master_character:
		if event.is_action_pressed("ui_left"):
			$Sprite.scale = Vector2(-1, 1)
		elif event.is_action_pressed("ui_right"):
			$Sprite.scale = Vector2(1, 1)
		if event.is_action_pressed("ui_up"):
			if is_on_floor():
				velocity.y = JUMP
			else:
				if doublejump:
					velocity.y = JUMP
					doublejump = false
	#BACK STEP
		if event.is_action_pressed("ui_down") and not get_parent().get_node("AnimationPlayer").current_animation == ("run") and backsteps > 0:
			_backstep()
	#PRESS Z
		if event.is_action_pressed("z"):
			if gun_mode:
				$Sprite/handR/weapon.show()
				gun_mode = false
				$Sprite/gun.hide()
				get_parent().get_node("AnimationPlayer2").stop()
			else:
				var rng = randf()
				if rng < 0.7:
					_animate2("attack")
				else:
					_animate2("stab")
	#PRESS X
		elif event.is_action_pressed("x") and not gun_mode:
			$Sprite/handR/weapon.hide()
			gun_mode = true
			$Sprite/gun.show()
	#PRESS C
		elif event.is_action_pressed("c"):
			get_parent()._ult()#TEST
			$Sprite/head/eyes.show()#TEST
		elif event.is_action_pressed("v"):
			get_parent()._sp_mini()#TEST
	#ULT
			if sp == 100:
				sp = 0
				$Sprite/head/eyes.show()
				get_parent()._ult()
	#SP MINI
			elif sp < 100 and sp >= 33 and gun_mode == req:
				sp -= 33
				get_parent()._sp_mini()

func _damage(num):
	if not get_parent().ult == true:
		health -= num
		sp += 2 * num/3
		if health <= 0:
			_die()

func _animate(anim):
	if get_parent().get_node("AnimationPlayer").current_animation != (anim):
		get_parent().get_node("AnimationPlayer").play(anim)

func _animate2(anim):
	var attack_anims = ["attack", "stab"]
	if attack_anims.has(anim):
		if not attack_anims.has(get_parent().get_node("AnimationPlayer2").current_animation):
			get_parent().get_node("AnimationPlayer2").play(anim)
	else:
		if get_parent().get_node("AnimationPlayer2").current_animation != (anim):
			get_parent().get_node("AnimationPlayer2").play(anim)

func _on_weapon_body_entered(body):
	if body != self:
		if body.is_in_group("player"):
			get_parent()._harm(body)

func _backstep():
	if is_on_floor():
		velocity.x = -4000 * $Sprite.scale.x
	else:
		velocity.y = 0
		velocity.x = -900 * $Sprite.scale.x
	emit_signal("backstep")
	backsteps -= 1

func _die():
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
		get_node("/root/main")._player_died()
		get_parent().queue_free()
	modulate.a = 1
	$Sprite/head/eyes.hide()
	$Sprite/head/eyes.modulate = Color(1,1,1)
	$Sprite/handR/weapon.show()
	SPEED = 400
	set_process_input(true)
	set_collision_layer_bit(1, true)
	set_collision_layer_bit(2, false)
	set_collision_mask_bit(1, true)
	set_collision_mask_bit(2, false)
	get_node("/root/main/spawner")._respawn(self)
	get_parent().get_node("AnimationPlayer2").stop()
