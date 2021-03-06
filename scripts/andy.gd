extends Node2D

export (PackedScene) var Ult
export (PackedScene) var Fireball

var can_shoot = true
var clip = 7 #TEMP
var ult = false
onready var sp = $KinematicBody2D.sp
var sp_true = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$KinematicBody2D.req = true#TEMP


func _process(_delta):
	if $KinematicBody2D.gun_mode == true:
		$KinematicBody2D/Sprite/gun.global_position = $KinematicBody2D/Sprite/handR.global_position
		$KinematicBody2D/Sprite/gun.rotation = $KinematicBody2D/Sprite/handR.rotation
	var not_gun_anims = ["ult", "fire"]
	if $KinematicBody2D.gun_mode == true and not not_gun_anims.has($AnimationPlayer2.current_animation):
		$AnimationPlayer2.play("gun")

func _input(event):
	if is_network_master():
		if event.is_action_pressed("x") and can_shoot and $KinematicBody2D.gun_mode:
			var ev = ("shoot") 
			if ev != null:
				rpc("_input_effect", ev)

remotesync func _input_effect(event):
	if event == ("shoot"):
		_shoot()

func _on_ReloadTimer_timeout():
	sp_true = false
	for child in $KinematicBody2D/Sprite/gun.get_children():
		child.show()
		child.modulate = Color(1,1,1)
	can_shoot = true
	clip = 7

func _on_UltTimer_timeout():
	ult = false
	$KinematicBody2D/Sprite/head/eyes.hide()
	$KinematicBody2D.set_process_input(true)
	$KinematicBody2D.SPEED = 400
	$KinematicBody2D.GRAVITY = 3000
	$KinematicBody2D/Sprite/head/eyes.hide()
	if $KinematicBody2D.gun_mode:
		$KinematicBody2D/Sprite/gun.show()
	else:
		$KinematicBody2D/Sprite/handR/weapon.show()

func _ult():
	ult = true
	$KinematicBody2D/Sprite/gun.hide()
	$KinematicBody2D/Sprite/handR/weapon.hide()
	$AnimationPlayer2.play("ult")
	$KinematicBody2D.set_process_input(false)
	$KinematicBody2D.SPEED = 0
	$KinematicBody2D.GRAVITY = 0
	$KinematicBody2D.velocity = Vector2(0,0)
	var node = Ult.instance()
	get_node("/root/main").call_deferred("add_child", node)
	node.global_position = $KinematicBody2D.global_position - Vector2(0,30)
	$UltTimer.start()

func _sp_mini():
	sp_true = true
	for child in $KinematicBody2D/Sprite/gun.get_children():
		child.modulate = Color(0.509804, 0.058824, 0.058824)

func _shoot():
	$AnimationPlayer2.play("fire")
	clip -= 1
	if clip == 0:
		can_shoot = false
		$ReloadTimer.start()
	$KinematicBody2D/Sprite/gun.get_child(clip).hide()
	var node = Fireball.instance()
	get_node("/root/main").call_deferred("add_child", node)
	node.position = $KinematicBody2D/Sprite/gun/Position2D.global_position
	node._veloc($KinematicBody2D.velocity.x)
	if sp_true:
		node._sp()

#WEAPON DAMAGING OTHERS
func _harm(body):
	body._damage(5)
	$KinematicBody2D.sp += 2.5

func _on_DeathTimer_timeout():
	_on_ReloadTimer_timeout()
