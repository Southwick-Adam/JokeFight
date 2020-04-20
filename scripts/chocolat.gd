extends Node2D

export (PackedScene) var Smudge

var velocity = Vector2(0,0)
onready var grav_timer = .4

func _ready():
	velocity.x += get_node("/root/main/charlotte/KinematicBody2D/Sprite").scale.x * 600

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if grav_timer >= 0:
		grav_timer -= delta
	else:
		velocity.y += 50
	position += velocity * delta

func _on_Area2D_body_entered(body):
	if body != get_node("/root/main/charlotte/KinematicBody2D"):
		if body.is_in_group("player"):
			if not (get_node("/root/main/charlotte/KinematicBody2D").gay == true and body == get_node("/root/main/hollis/KinematicBody2D")):
				if body.smudge == false:
					body.smudge = true
					var node = Smudge.instance()
					body.add_child(node)
					node.position = body.global_position
				else:
					body.get_node("smudge")._hit()
				body.SPEED -= 50
		queue_free()

func _veloc(veloc):
	velocity.x += veloc

