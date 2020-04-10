extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Timer_timeout():
	$AnimationPlayer.play("finish")
	get_node("/root/main/sean")._end_ult()

func _delay():
	$Timer.wait_time = 1.5
	$Timer.start()

func _on_animTimer_timeout():
	for marks in get_tree().get_nodes_in_group("sean_ult_mark"):
		marks._next()
