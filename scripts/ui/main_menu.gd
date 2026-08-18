extends Control

func _on_level_1_pressed():
	AudioManager.play_button()
	get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")

func _on_level_2_pressed():
	AudioManager.play_button()
	get_tree().change_scene_to_file("res://scenes/levels/Level2.tscn")

func _on_level_3_pressed():
	AudioManager.play_button()
	get_tree().change_scene_to_file("res://scenes/levels/Level3.tscn")
