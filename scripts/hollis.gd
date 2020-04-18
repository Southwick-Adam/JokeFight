extends Node2D

export (PackedScene) var Ult

var sing_target = []
var can_shoot = true
var ult = false
onready var sp = $KinematicBody2D.sp

# Called when the node enters the scene tree for the first time.
func _ready():
	$ReloadTimer.start()
	$ReloadTimer.paused = true
	
func _input(event):
	if is_network_master():
		var ev
		if event.is_action_pressed("x") and can_shoot:
			ev = ("fire")
		if event.is_action_released("x"):
			ev = ("release")
		if ev != null:
			rpc("_input_effect", ev)

remotesync func _input_effect(event):
	if event == ("fire"):
		$KinematicBody2D/Sprite/head/gun.show()
		$KinematicBody2D/Sprite/head/gun/beam.monitoring = true
		$ReloadTimer.paused = false
	elif event == ("release"):
		$KinematicBody2D/Sprite/head/gun.hide()
		$KinematicBody2D/Sprite/head/gun/beam.monitoring = false
		$ReloadTimer.paused = true

func _process(_delta):
	$KinematicBody2D/Sprite/head/gun/beam/Sprite.rotate(0.06)
	$KinematicBody2D/Sprite/head/gun/beam/Sprite2.rotate(-0.04)
	if can_shoot == false:
		$ReloadTimer.paused = false
#	else:
#		$KinematicBody2D/Sprite/gun/glow.scale = Vector2($ReloadTimer.time_left/3,$ReloadTimer.time_left/3)
#BEAM
	if not sing_target.empty():
		for targ in sing_target:
			targ._damage(0.4)
			$KinematicBody2D.sp += 0.2

func _harm(body):
	body._damage(8)
	$KinematicBody2D.sp += 4

func _on_beam_body_entered(body):
	if body.is_in_group("player") and body != get_node("/root/main/hollis/KinematicBody2D"):
		sing_target.append(body)

func _on_beam_body_exited(body):
	if sing_target.has(body):
		sing_target.erase(body)

func _on_ReloadTimer_timeout():
	if can_shoot:
		$KinematicBody2D/Sprite/head/gun/beam.hide()
		$KinematicBody2D/Sprite/head/gun/beam.monitoring = false
		can_shoot = false
		$ReloadTimer.wait_time = 2
		$ReloadTimer.start()
	else:
		can_shoot = true
		$ReloadTimer.wait_time = 3
		$ReloadTimer.start()

func _ult():
	ult = true
#IMMOBALIZE PLAYERS
	for opponent in get_tree().get_nodes_in_group("player"):
		opponent.set_process_input(false)
		opponent.SPEED = 0
	$KinematicBody2D/Sprite/head/gun.hide()
	$KinematicBody2D/Sprite/handR/weapon.hide()
	$AnimationPlayer2.play("ult")
	var node = Ult.instance()
	get_node("/root/main").call_deferred("add_child", node)
	node.position = Vector2(0,0)
	$UltTimer.start()

func _sp_mini():
	pass

func _on_UltTimer_timeout():
	_end_ult()

func _end_ult():
	ult = false
	$KinematicBody2D/Sprite/head/eyes.hide()
	for opponent in get_tree().get_nodes_in_group("player"):
		opponent.set_process_input(true)
		opponent.SPEED = 400
	if $KinematicBody2D.gun_mode:
		$KinematicBody2D/Sprite/head/gun.show()
	else:
		$KinematicBody2D/Sprite/handR/weapon.show()
	$AnimationPlayer2.stop()

func _on_DeathTimer_timeout():
	_on_ReloadTimer_timeout()
