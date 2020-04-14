extends Node2D

var back_lit = 2
var player
var max_value = 100.0
var current_value = 100.0
var percent = 1.0
var bar_num = 0
var dead = false
var parent

# Called when the node enters the scene tree for the first time.
func _ready():
	Network.connect("player_disconnect", self, "_on_player_disconnected")
	player.connect("backstep", self, "_backstep")
	var target = Network.players.keys()[bar_num]
	$Label.text = Network.players[target].name

func _process(_delta):
	if get_node("/root/main").get_children().has(parent):
		if not dead:
#HEALTH BAR
			current_value = clamp(player.health, 0, max_value)
			percent = float(current_value / max_value)
			$health/bar.set_scale(Vector2(percent, 1))
#SP BAR
			current_value = clamp(player.sp, 0, max_value)
			percent = float(current_value / max_value)
			$sp/bar.set_scale(Vector2(percent, 1))
			if player.sp >= 100:
				$sp/glow.show()
				$sp/"3".show()
			else:
				$sp/glow.hide()
				$sp/"3".hide()
			if player.sp >= 66:
				$sp/"2".show()
			else:
				$sp/"2".hide()
			if player.sp >= 33:
				$sp/"1".show() 
			else:
				$sp/"1".hide()
#BACKSTEP LIGHTS
			var back
			if back_lit == 0:
				back = $back2
			elif back_lit == 1:
				back = $back1
			if back_lit < 2:
				back.get_node("bar").scale += Vector2(0.0683,0.0683)
				if back.get_node("bar").scale.x > 8.2:
					back.get_node("bar").scale = Vector2(8.2, 8.2)
					back.get_node("glow").show()
					back_lit += 1
					player.backsteps += 1
#LIVES
			$Label2.text = ("x" + str(player.lives))
			if player.lives == 0:
				_dead()

func _backstep():
	var back
	if back_lit == 2:
		back = $back1
	elif back_lit == 1:
		back = $back2
		$back1/bar.scale = Vector2(0,0)
	back.get_node("bar").scale = Vector2(0,0)
	back.get_node("glow").hide()
	back_lit -= 1

func _set_player(person):
	player = person
	parent = person.get_parent()

func _set_num(num):
	bar_num = num

func _dead():
	dead = true
	for child in get_children():
		if child != get_child(0):
			child.hide()
	$Label3.show()
	get_node("/root/main")._player_died()

func _on_player_disconnected(id):
	if Network.players[id].character == parent.name:
		queue_free()
