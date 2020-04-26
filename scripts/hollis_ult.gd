extends Node2D

export (PackedScene) var Bleed

var num = 0

var done = false
onready var hollis = get_node("/root/main/hollis/KinematicBody2D")

func _on_Timer_timeout():
	if num == 0:
		_bleed()
		$Timer.wait_time = 2
		$Timer.start()
		num += 1
	elif num == 1:
		for opponent in get_tree().get_nodes_in_group("player"):
			if opponent != hollis:
				opponent._damage(100)
				$Timer.wait_time = 1
				$Timer.start()
				num += 1
	elif num == 2:
		for opponent in get_tree().get_nodes_in_group("player"):
			if opponent != hollis:
					opponent.get_node("Sprite/head/eye_bleed").queue_free()
		queue_free()

func _bleed():
	for opponent in get_tree().get_nodes_in_group("player"):
		if opponent != hollis:
			var node = Bleed.instance()
			opponent.get_node("Sprite/head").add_child(node)
			node.global_position = opponent.get_node("Sprite/head").global_position
