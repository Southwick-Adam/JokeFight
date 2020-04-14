extends Node2D

export (PackedScene) var Ult
export (PackedScene) var Marks

var beam_target = []
var can_shoot = true
var boomstate = 1
var ult = false
onready var sp = $KinematicBody2D.sp
onready var ult_shots = get_tree().get_nodes_in_group("player").size() - 1
var can_ult_shoot = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$ReloadTimer.start()
	$ReloadTimer.paused = true
	_boom_state(1)
	
func _input(event):
	if is_network_master():
		var ev
		if event.is_action_pressed("x") and can_shoot:
			ev = ("fire")
		if event.is_action_released("x"):
			ev = ("release")
	#ULT SHOOTING
		if event.is_action_pressed("c") and can_ult_shoot and ult_shots > 0:
			ev = ("c")
		if ev != null:
			rpc("_input_effect", ev)

remotesync func _input_effect(event):
	if event == ("fire"):
		$KinematicBody2D/Sprite/gun/beam.show()
		$KinematicBody2D/Sprite/gun/beam.monitoring = true
		$ReloadTimer.paused = false
	elif event == ("release"):
		$KinematicBody2D/Sprite/gun/beam.hide()
		$KinematicBody2D/Sprite/gun/beam.monitoring = false
		$ReloadTimer.paused = true
#ULT SHOOTING
	if event == ("c"):
		var node = Marks.instance()
		get_node("/root/main/sean_ult").add_child(node)
		node.global_position = Vector2(get_node("/root/main/sean_ult/bar").global_position.x, 690)
		ult_shots -= 1

func _process(_delta):
	if can_shoot == false:
		$ReloadTimer.paused = false
	else:
		$KinematicBody2D/Sprite/gun/glow.scale = Vector2($ReloadTimer.time_left/3,$ReloadTimer.time_left/3)
#BEAM
	if not beam_target.empty():
		for targ in beam_target:
			targ._damage(0.2)
#ANIMATE GUN
	if $KinematicBody2D.gun_mode == true and ult == false:
		$AnimationPlayer2.play("gun")

func _harm(body):
	var rng = randf()
	body._damage(4 + (3 * rng))

func _on_beam_body_entered(body):
	if body.is_in_group("player"):
		beam_target.append(body)

func _on_beam_body_exited(body):
	if beam_target.has(body):
		beam_target.erase(body)

func _on_ReloadTimer_timeout():
	if can_shoot:
		$KinematicBody2D/Sprite/gun/beam.hide()
		$KinematicBody2D/Sprite/gun/beam.monitoring = false
		$KinematicBody2D/Sprite/gun/dot.show()
		can_shoot = false
		$ReloadTimer.wait_time = 2
		$ReloadTimer.start()
	else:
		can_shoot = true
		$KinematicBody2D/Sprite/gun/dot.hide()
		$ReloadTimer.wait_time = 3
		$ReloadTimer.start()

func _boom_state(state):
	var sprite = $KinematicBody2D/Sprite/handR/weapon/Sprite
	if state == 1:
		sprite.texture = preload("res://assets/players/sean/boom.png")
		sprite.position = Vector2(26,-7)
		$KinematicBody2D/Sprite/handR/weapon/CollisionShape2D.scale = Vector2(25,6)
	elif state == 2:
		sprite.texture = preload("res://assets/players/sean/boom2.png")
		sprite.position = Vector2(33,-18)
		$KinematicBody2D/Sprite/handR/weapon/CollisionShape2D.scale = Vector2(38,8.33)
	elif state == 3:
		sprite.texture = preload("res://assets/players/sean/boom3.png")
		sprite.position = Vector2(32,-28)
		$KinematicBody2D/Sprite/handR/weapon/CollisionShape2D.scale = Vector2(58,9)

func _on_BoomTimer_timeout():
	boomstate -= 1
	_boom_state(boomstate)
	if boomstate == 2:
		$BoomTimer.start()

func _ult():
	ult = true
#IMMOBALIZE PLAYERS
	for opponent in get_tree().get_nodes_in_group("player"):
		opponent.set_process_input(false)
		opponent.SPEED = 0
	$KinematicBody2D/Sprite/gun.hide()
	$KinematicBody2D/Sprite/handR/weapon.hide()
	$AnimationPlayer2.play("ult")
	var node = Ult.instance()
	get_node("/root/main").call_deferred("add_child", node)
	node.position = Vector2(0,0)
	$UltTimer.start()

func _sp_mini():
	if boomstate < 3:
		boomstate += 1
		_boom_state(boomstate)
		$BoomTimer.start()

func _on_UltTimer_timeout():
	can_ult_shoot = true
	$UltTimer.wait_time = 6
	$UltTimer.start()

func _end_ult():
	ult = false
	$KinematicBody2D/Sprite/head/eyes.hide()
	for opponent in get_tree().get_nodes_in_group("player"):
		opponent.set_process_input(true)
		opponent.SPEED = 400
	if $KinematicBody2D.gun_mode:
		$KinematicBody2D/Sprite/gun.show()
	else:
		$KinematicBody2D/Sprite/handR/weapon.show()
	$AnimationPlayer2.stop()

func _on_DeathTimer_timeout():
	_on_ReloadTimer_timeout()
