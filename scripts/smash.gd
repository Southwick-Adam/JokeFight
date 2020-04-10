extends Node2D

var SPEED = 600
const ACCELERATION = 90

var velocity = Vector2()
var rot = 0
var gravity = 50
var target = []
var started = false

func _ready():
	set_process_input(false)
	velocity.y = -800
	velocity.x = get_node("/root/main/ray/KinematicBody2D/Sprite").scale.x * 700


func _process(delta):
	position += velocity * delta
	velocity.y += gravity
	if started:
		$Area2D/Sprite.rotate(rot)
		if Input.is_action_pressed("ui_right"):
			velocity.x = min(velocity.x + ACCELERATION, SPEED)
		elif Input.is_action_pressed("ui_left"):
			velocity.x = max(velocity.x - ACCELERATION, -SPEED)
		else:
			velocity.x = 0
		if Input.is_action_pressed("ui_down"):
			velocity.y = min(velocity.y + ACCELERATION, SPEED)
		elif Input.is_action_pressed("ui_up"):
			velocity.y = max(velocity.y - ACCELERATION, -SPEED)
		else:
			velocity.y = 0

#DAMAGE
	if not target.empty():
		for targ in target:
			targ._damage(0.2)

func _on_StartTimer_timeout():
	rot = 0.4
	set_process_input(true)
	$Area2D.monitoring = true
	velocity = Vector2(0,0)
	started = true

func _delete():
	queue_free()


func _on_Area2D_body_entered(body):
	if body.is_in_group("player") and body != get_node("/root/main/ray/KinematicBody2D"):
		target.append(body)

func _on_Area2D_body_exited(body):
	if target.has(body):
		target.erase(body)
