extends Node

export (PackedScene) var Sean
export (PackedScene) var Adam
export (PackedScene) var Ray
export (PackedScene) var Hollis
export (PackedScene) var Andy
export (PackedScene) var Charlotte

var lives
var players_left = Network.players.size()
var spawn_pos = 5

func _ready():
	pass

func _spawn(choice):
	var node
	if choice == ("sean"):
		node = Sean.instance()
	elif choice == ("adam"):
		node = Adam.instance()
	elif choice == ("ray"):
		node = Ray.instance()
	elif choice == ("hollis"):
		node = Hollis.instance()
	elif choice == ("andy"):
		node = Andy.instance()
	elif choice == ("charlotte"):
		node = Charlotte.instance()
	var n = 0
	while n < Network.players.size():
		var targ = Network.players.keys()[n]
		if Network.players[targ].character == choice:
			node.set_network_master(targ)
			print(targ, " is master")
			break
		n += 1
	get_node("/root/main").call_deferred("add_child", node)
	node.position = get_child(spawn_pos).position
	spawn_pos += 1

func _set_lives(value):
	lives = value

func _on_Button_pressed():
	var node = load("res://scenes/select.tscn").instance()
	get_tree().get_root().add_child(node)
	node.get_child(node.get_child_count() - 2).value = lives
	Gamestate.player_info.character = null
	queue_free()
	
func _player_died():
	if players_left >= 3:
		players_left -= 1
	else:
		var win_char
		var winner = ("Nobody")
		for bar in get_tree().get_nodes_in_group("bar"):
			if not bar.dead:
				win_char = bar.player.get_parent().name
		var n = 0
		while n < Network.players.size():
			var targ = Network.players.keys()[n]
			if Network.players[targ].character == win_char:
				winner = Network.players[targ].name
				break
			n += 1
		$win/Label.text = (str(winner) + " Wins \n Everybody Else Suck It!")
		for child in $win.get_children():
			child.show()
