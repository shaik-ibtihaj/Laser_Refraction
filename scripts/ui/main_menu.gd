extends Control

@onready var button_l1 = $VBoxContainer/ButtonL1
@onready var button_l2 = $VBoxContainer/ButtonL2
@onready var button_l3 = $VBoxContainer/ButtonL3

func _ready():
	_update_level_buttons()

func _update_level_buttons():
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr:
		_setup_button(button_l1, 1, "LEVEL 1", save_mgr)
		_setup_button(button_l2, 2, "LEVEL 2", save_mgr)
		_setup_button(button_l3, 3, "LEVEL 3", save_mgr)

func _setup_button(btn: Button, level_num: int, label_text: String, save_mgr: Node):
	if btn:
		var unlocked = save_mgr.is_level_unlocked(level_num)
		btn.disabled = not unlocked
		var stars = save_mgr.get_level_stars(level_num)
		var star_str = ""
		if stars > 0:
			for i in range(3):
				star_str += " ★" if i < stars else " ☆"
		btn.text = label_text + ((" " + star_str) if star_str != "" else "")

func _on_level_1_pressed():
	AudioManager.play_button()
	get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")

func _on_level_2_pressed():
	AudioManager.play_button()
	get_tree().change_scene_to_file("res://scenes/levels/Level2.tscn")

func _on_level_3_pressed():
	AudioManager.play_button()
	get_tree().change_scene_to_file("res://scenes/levels/Level3.tscn")
