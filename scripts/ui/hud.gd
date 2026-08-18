extends CanvasLayer

@onready var moves_label = $MarginContainer/HBoxContainer/VBoxMoves/MovesValue
@onready var lives_label = $MarginContainer/HBoxContainer/VBoxLives/LivesValue

func _process(_delta):
	var levels = get_tree().get_nodes_in_group("level_manager")
	if levels.size() > 0:
		var lm = levels[0]
		moves_label.text = str(lm.moves_remaining) + " / " + str(lm.max_moves)
		lives_label.text = str(lm.lives)
