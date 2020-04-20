extends Node

signal server_created
signal server_creation_failed
signal join_success
signal join_fail
signal player_list_changed
signal player_disconnect

var server_info = {
	name = "Server",
	max_players = 4,
	used_port = 8088
}

remote var players = {}

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	get_tree().connect("server_disconnected", self, "_on_disconnected_from_server")

#SERVER SIDE FUNCTIONS---------------------------@

func _create_server():
	var host = NetworkedMultiplayerENet.new()
	if (host.create_server(server_info.used_port, server_info.max_players) != OK):
		emit_signal("server_creation_failed")
		return
	get_tree().set_network_peer(host)
	emit_signal("server_created")
	register_player(Gamestate.player_info)

# Everyone gets notified whenever a new client joins the server
func _on_player_connected(id):
	emit_signal("join_success")
	# Update the player_info dictionary with the obtained unique network ID
	Gamestate.player_info.net_id = get_tree().get_network_unique_id()
	# Request the server to register this new player across all connected players
	rpc_id(1, "register_player", Gamestate.player_info)
	# And register itself on the local list
	register_player(Gamestate.player_info)

# Everyone gets notified whenever someone disconnects from the server
func _on_player_disconnected(id):
	print("Player ", players[id].name, " disconnected from server")
	# Update the player tables
	if (get_tree().is_network_server()):
		# Unregister the player from the server's list
		unregister_player(id)
		# Then on all remaining peers
		rpc("unregister_player", id)

remote func register_player(pinfo):
	players[pinfo.net_id] = pinfo
#SYNC PLAYER LISTS
	if (get_tree().is_network_server()):
		for id in players:
			if (id != 1):
				rpc_id(id, "sync_dict", players)
	emit_signal("player_list_changed")

remote func sync_dict(dict):
	players = dict
	emit_signal("player_list_changed")

func update_server():
	if (get_tree().is_network_server()):
		update_player_info(Gamestate.player_info)
	else:
		rpc_id(1, "update_player_info", Gamestate.player_info)

remote func update_player_info(pinfo):
	if (get_tree().is_network_server()):
		for id in players:
			if (id != 1):
				rpc_id(id, "update_player_info", pinfo)
	players[pinfo.net_id] = pinfo
	emit_signal("player_list_changed")

remote func unregister_player(id):
	print("Removing player ", players[id].name, " from internal table")
	if get_node("/root/main") != null:
		for child in get_node("/root/main").get_children():
			if child.name == players[id].character:
				get_node("/root/main")._player_died()
				child.queue_free()
	emit_signal("player_disconnect", id)
	
	# Remove the player from the list
	players.erase(id)
	# And notify the list has been changed
	emit_signal("player_list_changed")

#CLIENT SIDE FUNCTIONS-------------------------------------@

#JOIN SERVER
func _join_server(ip, port):
	var client = NetworkedMultiplayerENet.new()
	if (client.create_client(ip, port) != OK):
		print("Failed to create client")
		emit_signal("join_fail")
		return
	get_tree().set_network_peer(client)

func _on_connected_to_server():
	emit_signal("join_success")

func _on_connection_failed():
	emit_signal("join_fail")
	get_tree().set_network_peer(null)

func _on_disconnected_from_server():
	print("Disconnected from server")
	players.clear()
	Gamestate.player_info.net_id = 1
	for child in get_node("/root").get_children():
		child.queue_free()
	var node
	node = load("res://scenes/server_screen.tscn").instance()
	get_tree().get_root().add_child(node)
