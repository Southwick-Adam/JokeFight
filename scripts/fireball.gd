extends Node2D

export (PackedScene) var Burn

var velocity = Vector2(0,0)
var sp = false

func _ready():
	velocity.x += get_node("/root/main/andy/KinematicBody2D/Sprite").scale.x * 800

func _process(delta):
	position += velocity * delta

func _on_Area2D_body_entered(body):
	velocity.x = 0
	if body.is_in_group("player"):
		if not (get_node("/root/main/andy/KinematicBody2D").gay == true and body == get_node("/root/main/hollis/KinematicBody2D")):
			body._damage(6)
			get_node("/root/main/andy/KinematicBody2D").sp += 3
			if sp:
				for child in body.get_children():
					if child.name == ("burn"):
						return
				var node = Burn.instance()
				body.add_child(node)
				node.global_position = body.global_position
	$AnimationPlayer.play("boom")

func _veloc(veloc):
	velocity.x += veloc

func _sp():
	modulate = Color(0.996078, 0.12549, 0.12549)
	sp = true
