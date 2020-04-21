extends Node2D

export (PackedScene) var Smash

var ult = false
var damage_num = 0
var can_shoot = true
var smash_out = false
var rush = false
var list_anims = ["attack","stab","rush", "die"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(event):
	if is_network_master():
		var ev
		if event.is_action_pressed("x") and not ult:
			ev = ("x")
		if event.is_action_pressed("c") and ult:
			ev = ("c")
		if ev != null:
			rpc("_input_effect", ev)

remotesync func _input_effect(event):
	if event == ("x"):
		if smash_out:
			get_node("/root/main/smash")._delete()
			smash_out = false
			$AnimationPlayer2.stop()
			$ReloadTimer.start()
			$KinematicBody2D.set_process_input(true)
			$KinematicBody2D.SPEED = 400
		else:
			if can_shoot:
				_shoot()
				$KinematicBody2D.set_process_input(false)
				$KinematicBody2D.SPEED = 0
				can_shoot = false
				smash_out = true
	if event == ("c"):
		$KinematicBody2D._animate2("ult")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$KinematicBody2D/Sprite/handR/weapon/Sprite2.global_position = $KinematicBody2D/Sprite/handL.global_position
	$KinematicBody2D/Sprite/handR/weapon/Sprite2.rotation = $KinematicBody2D/Sprite/handL.rotation
	$KinematicBody2D/Sprite/handR/weapon/CollisionShape2D2.global_position = $KinematicBody2D/Sprite/handL.global_position
	if not ($AnimationPlayer2.current_animation == ("gun") and $AnimationPlayer2.is_playing()):
		$KinematicBody2D/Sprite/gun.global_position = $KinematicBody2D/Sprite/handL.global_position
#BOXING ANIMS
	if not (list_anims.has($AnimationPlayer2.current_animation) or $AnimationPlayer2.current_animation == ("ult")):
		if $AnimationPlayer.current_animation == ("idle"):
			_animate2("boxing_idle")
		else:
			_animate2("boxing")
	if smash_out:
		_animate2("gun")
	else:
		$KinematicBody2D/Sprite/gun.rotation_degrees = 18
		$KinematicBody2D/Sprite/gun.z_index = 1
#ATTACK
	if list_anims.has($AnimationPlayer2.current_animation):
		$KinematicBody2D/Sprite/handR/weapon.monitoring = true
	else:
		$KinematicBody2D/Sprite/handR/weapon.monitoring = false
	
	if $AnimationPlayer2.current_animation == ("attack"):
		damage_num = 4
	elif $AnimationPlayer2.current_animation == ("stab"):
		damage_num = 9
	elif $AnimationPlayer2.current_animation == ("rush"):
		damage_num = 4
#RUSH
	if rush:
		position.x += 600 * delta * $KinematicBody2D/Sprite.scale.x

func _animate2(anim):
	if $AnimationPlayer2.current_animation != (anim):
		$AnimationPlayer2.play(anim)

func _harm(body):
	body._damage(damage_num)
	$KinematicBody2D.sp += damage_num/2

func _shoot():
	var node = Smash.instance()
	get_node("/root/main").call_deferred("add_child", node)
	node.set_network_master(get_network_master())
	node.position = $KinematicBody2D/Sprite/gun.global_position
	$KinematicBody2D/Sprite/gun/dot.hide()

func _on_ReloadTimer_timeout():
	can_shoot = true
	$KinematicBody2D/Sprite/gun/dot.show()

func _sp_mini():
	$RushTimer.start()
	$KinematicBody2D.SPEED = 0
	$KinematicBody2D/Sprite/handR/weapon/Sprite.scale += Vector2(0.2,0.2)
	$KinematicBody2D/Sprite/handR/weapon/Sprite2.scale += Vector2(0.2,0.2)
	$KinematicBody2D.set_process_input(false)
	rush = true
	_animate2("rush")

func _ult():
	ult = true
	$KinematicBody2D/Sprite/ult.show()
	$KinematicBody2D/Sprite/head/eyes.show()
	$KinematicBody2D/Sprite/handL.hide()
	$KinematicBody2D/Sprite/handR.hide()
	$KinematicBody2D/Sprite/gun.hide()
	$KinematicBody2D.SPEED = 500
	$UltTimer.start()
	
func _on_RushTimer_timeout():
	$KinematicBody2D.SPEED = 400
	$KinematicBody2D.velocity.x = 0
	$KinematicBody2D/Sprite/handR/weapon/Sprite.scale -= Vector2(0.2,0.2)
	$KinematicBody2D/Sprite/handR/weapon/Sprite2.scale -= Vector2(0.2,0.2)
	rush = false
	$KinematicBody2D.set_process_input(true)

func _on_ult_body_entered(body):
	if body.is_in_group("player"):
		body._damage(50)

func _on_AnimationPlayer2_animation_finished(anim_name):
	if anim_name == ("ult"):
		get_node("/root/main/AnimationPlayer").play("shake")

func _on_UltTimer_timeout():
	ult = false
	$KinematicBody2D/Sprite/ult.hide()
	$KinematicBody2D/Sprite/head/eyes.hide()
	$KinematicBody2D/Sprite/handL.show()
	$KinematicBody2D/Sprite/handR.show()
	if $KinematicBody2D.gun_mode:
		$KinematicBody2D/Sprite/gun.show()
	$KinematicBody2D.SPEED = 400
	set_process_input(true)

func _on_DeathTimer_timeout():
	_on_ReloadTimer_timeout()
