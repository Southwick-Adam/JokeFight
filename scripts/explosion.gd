extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Timer_timeout():
	queue_free()

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body._damage(14)
		get_node("/root/main/adam/KinematicBody2D").sp += 6
