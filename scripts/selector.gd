extends Node2D

onready var choice = get_parent().choice

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	choice = get_parent().choice
	global_position = get_parent().get_child(choice).global_position
#CHOOSE
	#if is_network_master():
	if event.is_action_pressed("z"):
			get_parent()._choose(choice)
			queue_free()
