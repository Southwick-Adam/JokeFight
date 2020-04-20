extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_parent()._damage(.1)
	if get_parent().health <= 0:
		queue_free()

func _on_Timer_timeout():
	queue_free()
