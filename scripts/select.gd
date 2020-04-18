extends Node2D

export (PackedScene) var Selector
export (PackedScene) var Game


var selector
var choice = 0
var choice_name
var made_change = true
var first = true

# Called when the node enters the scene tree for the first time.
func _ready():
	Network.connect("player_list_changed", self, "_on_player_list_changed")
	# Update the lblLocalPlayer label widget to display the local player name
	$V/Label.text = (str(Gamestate.player_info.name) + " - Spectating")
	_spawn()

func _input(event):
	#START GAME
	if event.is_action_pressed("ui_accept") and Gamestate.player_info.character != null:
		rpc("_start_game")
		_start_game()
	if Gamestate.player_info.character == null:
		if event.is_action_pressed("ui_left"):
			if choice > 0:
				choice -= 1
		elif event.is_action_pressed("ui_right"):
			if choice < 5:
				choice += 1
		elif event.is_action_pressed("ui_up"):
			if choice > 2:
				choice -= 3
		elif event.is_action_pressed("ui_down"):
			if choice < 3:
				choice += 3
	if event.is_action_pressed("x"):
		if Gamestate.player_info.character != null:
			_unchoose()

func _on_player_list_changed():
# First remove all children from the list of names
	for c in $V.get_children():
		c.queue_free()
# Now iterate through the player list creating a new entry into the list
	for p in Network.players:
		var nlabel = Label.new()
		if Network.players[p].character == null:
			nlabel.text = (str(Network.players[p].name) + " - Spectating")
		else:
			nlabel.text = (str(Network.players[p].name) + " - " + str(Network.players[p].character))
		$V.add_child(nlabel)
#PRE SELECT OTHER PLAYERS CHOICES
	if first and Gamestate.player_info.net_id != 1:
		first = false
		var n = 0
		while n < (Network.players.size()):
			var targ = Network.players.keys()[n]
			for child in get_children():
				if child.name == Network.players[targ].character:
					child.get_node("lock").show()
			n += 1

remote func _start_game():
	var game = Game.instance()
	get_tree().get_root().add_child(game)
	game._set_lives($SpinBox.value)
# Spawn all the people
	for id in Network.players:
		get_node("/root/main")._spawn(Network.players[id].character)
	queue_free()

func _choose(choice):
	rpc("_lock", choice)
	if choice == 0:
		choice_name = ("sean")
	elif choice == 1:
		choice_name = ("adam")
	elif choice == 2:
		choice_name = ("ray")
	elif choice == 3:
		choice_name = ("hollis")
	elif choice == 4:
		choice_name = ("andy")
	elif choice == 5:
		choice_name = ("charlotte")
	Gamestate.player_info.character = choice_name
	Network.update_server()

func _unchoose():
	get_child(choice).get_node("lock").hide()
	_spawn()
	Gamestate.player_info.character = null
	Network.update_server()

remotesync func _lock(num):
	get_child(num).get_node("lock").show()

func _spawn():
	selector = Selector.instance()
	add_child(selector)
	selector.global_position = get_child(choice).global_position

func _on_SpinBox_value_changed(value):
	if made_change:
		rpc("life_change", value)

remotesync func life_change(value):
	made_change = false
	$SpinBox.value = value
	made_change = true
