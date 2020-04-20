extends Node2D

var num = 1

func _hit():
	num += 1
	$Sprite.frame += 1
	$Timer.start()

func _on_Timer_timeout():
	get_parent().SPEED += 50
	if num > 1:
		num -= 1
		$Sprite.frame -= 1
	else:
		get_parent().smudge = false
		queue_free()
	
