extends Node2D

func _process(_delta):
	get_parent()._damage(.1)
	if get_parent().health <= 0:
		queue_free()

func _on_Timer_timeout():
	queue_free()
