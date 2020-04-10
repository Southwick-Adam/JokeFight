extends Node2D


var colortime_count = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	for opponent in get_tree().get_nodes_in_group("player"):
			opponent.modulate = Color(1,1,1)
	queue_free()

func _on_ColorTimer_timeout():
	if colortime_count == 0:
		$ColorTimer.wait_time = 4.9
		$ColorTimer.start()
		for opponent in get_tree().get_nodes_in_group("player"):
			if opponent != get_node("/root/main/adam/KinematicBody2D"):
				opponent.modulate = Color(0,1,0)
				colortime_count = 1
	else:
		for opponent in get_tree().get_nodes_in_group("player"):
			if opponent != get_node("/root/main/adam/KinematicBody2D"):
				opponent.modulate = Color(1,0,0)
				opponent._damage(9 * opponent.health/10)
	
