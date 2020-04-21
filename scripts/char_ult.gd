extends Node2D

func _on_Area2D_body_entered(body):
	if body.is_in_group("player") and body != get_node("/root/main/charlotte/KinematicBody2D"):
		body._damage(75)
