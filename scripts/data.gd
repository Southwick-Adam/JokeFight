extends Node

const SAVE_PATH = "res://save.json"

func _ready():
	_load_data()

func _save_data(port, ip):
#GET SAVE DATA
	var save_dict = {
		used_port = port,
		used_ip = ip
}
#CREATE / OPEN SAVE FILE
	var SaveFile = File.new()
	SaveFile.open(SAVE_PATH, File.WRITE)
#WRITE THE DATA INTO THE SAVE FILE
	SaveFile.store_line(to_json(save_dict))
#CLOSE THE FILE
	SaveFile.close()

func _load_data():
#TRY TO LOAD SAVE FILE
	var SaveFile = File.new()
	if not SaveFile.file_exists(SAVE_PATH):
		print("NO SAVED DATA AVAILABLE")
		return
	SaveFile.open(SAVE_PATH, File.READ)
	var data = parse_json(SaveFile.get_as_text())
	get_node("/root/server_screen").USED_PORT = data["used_port"]
	get_node("/root/server_screen").USED_IP = data["used_ip"]
