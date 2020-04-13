extends Node

export (PackedScene) var Sean
export (PackedScene) var Adam
export (PackedScene) var Ray
export (PackedScene) var Andy

var lives
var players_left = Network.players.size()
var spawn_pos = 5

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')

func _spawn(choice):
	var node
	if choice == ("sean"):
		node = Sean.instance()
	elif choice == ("adam"):
		node = Adam.instance()
	elif choice == ("ray"):
		node = Ray.instance()
	elif choice == ("andy"):
		node = Andy.instance()
	if choice == Gamestate.player_info.character:
		node.set_network_master(Gamestate.player_info.net_id)
		print(str(choice) + " is master")
	get_node("/root/main").call_deferred("add_child", node)
	node.position = get_child(spawn_pos).position
	spawn_pos += 1

func _on_player_disconnected(id):
	get_node(str(id)).queue_free()

func _on_server_disconnected():
	get_tree().change_scene("res://scenes/server_screen.tscn")
	
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
		for child in $win.get_children():
			child.show()
