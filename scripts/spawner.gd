extends Node2D

func _respawn(character):
	var rng = randf()
	character.global_position.x = 130 + (940 * rng)
	character.global_position.y = -65
