extends Node2D

var USED_IP = "127.0.0.1"
var USED_PORT = 8088


func _ready():
	Network.connect("server_created", self, "_on_ready_to_play")
	Network.connect("server_creation_failed", self, "_on_create_fail")
	Network.connect("join_success", self, "_on_ready_to_play")
	Network.connect("join_fail", self, "_on_join_fail")
	$name/LineEdit.text = Gamestate.player_info.name

func _on_btnCreate_pressed():
	Gamestate.player_info.name = $name/LineEdit.text
	Network._create_server()

func _on_btnJoin_pressed():
	Gamestate.player_info.name = $name/LineEdit.text
	Network._join_server(USED_IP,USED_PORT)
	$JoinTimer.start()

func _on_ready_to_play():
	get_tree().change_scene("res://scenes/select.tscn")

func _on_create_fail():
	$create_error.show()
	_on_btnSettings_pressed()

func _on_join_fail():
	pass

func _on_btnSettings_pressed():
	$settings.show()
	$btnSettings.hide()

func _on_btnApply_pressed():
	Network.server_info.used_port = int($settings/port.text)
	USED_PORT = int($settings/port.text)
	Network.server_info.max_players = int($settings/maxConnects.value)
	USED_IP = str($settings/IP.text)

func _on_JoinTimer_timeout():
	$join_error.show()
	_on_btnSettings_pressed()
