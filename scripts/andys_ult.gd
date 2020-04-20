extends Node2D


var end = false
var targets = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _beat():
	if not targets.empty():
		for target in targets:
			target._damage(10)

func _on_Area2D_body_entered(body):
	if body.is_in_group("player") and body != get_node("/root/main/andy/KinematicBody2D"):
		targets.append(body)
		body.set_process_input(false)
		body.SPEED = 0

func _on_Timer_timeout():
	$BeatTimer.stop()
	$AnimationPlayer.play_backwards("load")

func _on_AnimationPlayer_animation_finished(anim_name):
	if end:
		for target in targets:
			target.set_process_input(true)
			target.SPEED = 400
		queue_free()
	else:
		$BeatTimer.start()
		$AnimationPlayer.play("go")
		end = true

func _on_BeatTimer_timeout():
	_beat()
