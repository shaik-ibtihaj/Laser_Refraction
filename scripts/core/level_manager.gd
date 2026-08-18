extends Node
class_name LevelManager

var total_targets: int = 0
var powered_targets: int = 0
var level_completed: bool = false
var game_over: bool = false

@export var level_number: int = 1
@export var max_moves: int = 20
@export var max_lives: int = 4

var moves_remaining: int
var lives: int

func _ready():
	add_to_group("level_manager")
	moves_remaining = max_moves
	lives = max_lives
	call_deferred("_initialize_targets")

func lose_life():
	if game_over or level_completed: return
	lives -= 1
	print("Lost a life! Lives remaining: ", lives)
	if lives <= 0:
		_on_game_over()

func consume_move():
	if game_over or level_completed: return
	moves_remaining -= 1
	print("Move consumed! Moves remaining: ", moves_remaining)
	if moves_remaining <= 0:
		_on_game_over()

func _on_game_over():
	game_over = true
	print("GAME OVER")


func _initialize_targets():
	var targets = get_tree().get_nodes_in_group("targets")
	total_targets = targets.size()
	powered_targets = 0
	
	for target in targets:
		if target.is_powered:
			powered_targets += 1
		target.power_state_changed.connect(_on_target_state_changed)
	
	_check_completion()

func _on_target_state_changed(is_powered: bool):
	if is_powered:
		powered_targets += 1
	else:
		powered_targets -= 1
		
	_check_completion()

func _check_completion():
	if not level_completed and total_targets > 0 and powered_targets >= total_targets:
		level_completed = true
		_on_level_complete()
	elif level_completed and powered_targets < total_targets:
		# If a mirror is moved away, un-complete the level
		level_completed = false
		print("LEVEL INCOMPLETE")

func _on_level_complete():
	var stars = 1
	if moves_remaining >= max_moves * 0.5:
		stars = 3
	elif moves_remaining >= max_moves * 0.2:
		stars = 2
	print("LEVEL COMPLETE! All targets powered. Stars earned: ", stars)
	if get_node_or_null("/root/SaveManager"):
		get_node("/root/SaveManager").save_level_completion(level_number, stars)

