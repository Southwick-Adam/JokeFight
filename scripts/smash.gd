extends Node2D

var SPEED = 600
const ACCELERATION = 90

var velocity = Vector2()
var gravity = 3000
var target = []
var started = false
var slave_velocity = Vector2()
var slave_position = Vector2()

func _ready():
	set_process_input(false)
	velocity.y = -800
	velocity.x = get_node("/root/main/ray/KinematicBody2D/Sprite").scale.x * 700


func _process(delta):
	if get_node("/root/main/ray") == null:
		queue_free()
	if get_node("/root/main/ray/KinematicBody2D").health <= 0:
		queue_free()
	position += velocity * delta
	velocity.y += gravity * delta
	if started:
		$Area2D/Sprite.rotate(20 * delta)
		if is_network_master():
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
			rset("slave_velocity", velocity)
			rset("slave_position", position)
		else:
			velocity = slave_velocity
			if abs(position.x - slave_position.x) > 10 or abs(position.y - slave_position.y) > 10:
				position = slave_position
#DAMAGE
	if not target.empty():
		for targ in target:
			if not (get_node("/root/main/ray/KinematicBody2D").gay == true and targ == get_node("/root/main/hollis/KinematicBody2D")):
				targ._damage(0.4)
				get_node("/root/main/ray/KinematicBody2D").sp += 0.2

func _on_StartTimer_timeout():
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
