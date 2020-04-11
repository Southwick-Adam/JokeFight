extends Node2D

export (PackedScene) var Selector
export (PackedScene) var Game


var selector
var choice = 0
var choice_name

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
			if choice < 3:
				choice += 1
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

remote func _start_game():
	var game = Game.instance()
	get_tree().get_root().add_child(game)
# Spawn all the people
	for id in Network.players:
		get_node("/root/main")._spawn(Network.players[id].character)
	queue_free()

func _choose(choice):
	_lock(choice)
	rpc("_lock", choice)
	if choice == 0:
		choice_name = ("sean")
	elif choice == 1:
		choice_name = ("adam")
	elif choice == 2:
		choice_name = ("ray")
	elif choice == 3:
		choice_name = ("andy")
	Gamestate.player_info.character = choice_name
	Network.update_server()

func _unchoose():
	get_child(choice).get_node("lock").hide()
	_spawn()
	Gamestate.player_info.character = null
	Network.update_server()

remote func _lock(num):
	get_child(num).get_node("lock").show()

func _spawn():
	selector = Selector.instance()
	add_child(selector)
	selector.global_position = get_child(choice).global_position



