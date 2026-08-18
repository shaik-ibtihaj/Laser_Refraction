extends Node

const SAVE_PATH = "user://save_data.json"

var save_data = {
	"unlocked_level": 1,
	"stars": {}
}

func _ready():
	load_data()

func is_level_unlocked(level_num: int) -> bool:
	return level_num <= save_data.get("unlocked_level", 1)

func get_level_stars(level_num: int) -> int:
	var stars_dict = save_data.get("stars", {})
	return stars_dict.get(str(level_num), 0)

func save_level_completion(level_num: int, stars: int):
	var current_stars = get_level_stars(level_num)
	if stars > current_stars:
		save_data["stars"][str(level_num)] = stars
		
	var current_unlocked = save_data.get("unlocked_level", 1)
	if level_num >= current_unlocked:
		save_data["unlocked_level"] = level_num + 1
		
	save_data_to_file()

func load_data():
	if not FileAccess.file_exists(SAVE_PATH):
		save_data_to_file()
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		if parse_result == OK and json.data is Dictionary:
			save_data = json.data

func save_data_to_file():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
