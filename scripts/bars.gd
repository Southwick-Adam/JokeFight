extends Node2D

var back_lit = 2
var player
var max_value = 100.0
var current_value = 100.0
var percent = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = Gamestate.player_info.name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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
	
