extends Node2D


var target = false
var target_list = []
var timeout = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Area2D_body_entered(body):
	if body.is_in_group("player") and body != get_node("/root/main/sean/KinematicBody2D"):
		target = true
		target_list.append(body)

func _on_Timer_timeout():
	$Area2D/Sprite.self_modulate = Color(1,0,0)
	for targ in target_list:
		targ._damage(100)

func _next():
	print("next")
	if target:
		$AnimationPlayer.play("next")
		get_node("/root/main/sean_ult")._delay()
		$Timer.start()
	else:
		$AnimationPlayer.play("finish")
