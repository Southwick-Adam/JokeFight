extends Node2D

export (PackedScene) var Sean
export (PackedScene) var Adam
export (PackedScene) var Ray
export (PackedScene) var Andy

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _respawn(character):
	var node
	print(character)
	if character == ("Sean"):
		node = Sean.instance()
	elif character == ("Adam"):
		node = preload("res://scenes/adam.tscn").instance()
	elif character == ("Ray"):
		node = Ray.instance()
	elif character == ("Andy"):
		name = Andy
		node = Andy.instance()
	get_node("/root/main").call_deferred("add_child", node)
	node.position = position
