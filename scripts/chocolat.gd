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
		velocity.y += 2900 * delta
	position += velocity * delta

func _on_Area2D_body_entered(body):
	if body != get_node("/root/main/charlotte/KinematicBody2D"):
		if body.is_in_group("player"):
			if not (get_node("/root/main/charlotte/KinematicBody2D").gay == true and body == get_node("/root/main/hollis/KinematicBody2D")):
				get_node("/root/main/charlotte/KinematicBody2D").sp += 4
				if body.smudge == false:
					body.smudge = true
					var node = Smudge.instance()
					body.get_node("Sprite/body").add_child(node)
					node.global_position = body.global_position
					body.SPEED -= 40
				else:
					body.get_node("Sprite/body/smudge")._hit()
				body._damage(8)
		queue_free()

func _veloc(veloc):
	velocity.x += veloc

