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
		body._damage(5)
		if sp:
			var node = Burn.instance()
			body.add_child(node)
			node.gloabl_position = body.global_position

	$AnimationPlayer.play("boom")

func _veloc(veloc):
	velocity.x += veloc

func _sp():
	modulate = Color(0.996078, 0.12549, 0.12549)
	sp = true
