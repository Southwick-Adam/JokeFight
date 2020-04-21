extends Node2D

var num = 1
onready var parent = get_parent().get_parent().get_parent()

func _process(delta):
	if parent.health <= 0:
		parent.SPEED = 400
		queue_free()

func _hit():
	if num < 7:
		num += 1
		$Sprite.frame += 1
		$Timer.start()
		parent.SPEED -= 40

func _on_Timer_timeout():
	parent.SPEED += 40
	if num > 1:
		num -= 1
		$Sprite.frame -= 1
	else:
		parent.smudge = false
		queue_free()
	
