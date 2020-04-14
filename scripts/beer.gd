extends Node2D

export (PackedScene) var Boom

var velocity = Vector2(0,0)

func _ready():
	velocity.y = -600

func _set_vel_x(num):
	velocity.x += num

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta
	velocity.y += 50
	

func _on_Area2D_body_entered(body):
	if body != get_node("/root/main/adam/KinematicBody2D"):
		var node = Boom.instance()
		get_node("/root/main").call_deferred("add_child", node)
		node.position = global_position
		queue_free()

func _veloc(veloc):
	velocity.x += veloc

