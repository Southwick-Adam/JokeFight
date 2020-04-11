extends Node

export (PackedScene) var Sean
export (PackedScene) var Adam
export (PackedScene) var Ray
export (PackedScene) var Andy

var player_num = 0

var spawn_pos = 5

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')

func _spawn(choice):
	var node
	if choice == ("Sean"):
		node = Sean.instance()
	elif choice == ("Adam"):
		node = Adam.instance()
	elif choice == ("Ray"):
		node = Ray.instance()
	elif choice == ("Andy"):
		node = Andy.instance()
	get_node("/root/main").call_deferred("add_child", node)
	node.position = get_child(spawn_pos).position
	spawn_pos += 1

func _on_player_disconnected(id):
	get_node(str(id)).queue_free()

func _on_server_disconnected():
	get_tree().change_scene("res://scenes/select.tscn")
