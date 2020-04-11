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

func _ready():
	var node = Bars.instance()
	node._set_player(self)
	get_node("/root/main").call_deferred("add_child", node)
	node.global_position = get_node("/root/main").get_node("bar1").position

func _process(_delta):
#GRAVITY
	velocity.y += GRAVITY
#RIGHT/LEFT MOVEMENT
	if Input.is_action_pressed("ui_right"):
		velocity.x = min(velocity.x + ACCELERATION, SPEED)
	elif Input.is_action_pressed("ui_left"):
		velocity.x = max(velocity.x - ACCELERATION, -SPEED)
	else:
		if is_on_floor():
			velocity.x = lerp(velocity.x, 0, 0.4)
		else:
			velocity.x = lerp(velocity.x, 0, 0.05)
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
		sp += num/2
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
	bars._backstep()
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
	get_node("/root/main/spawner")._respawn(get_parent().name)
	get_parent().get_node("bars").queue_free()
	queue_free()
