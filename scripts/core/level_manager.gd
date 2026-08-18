extends Node
class_name LevelManager

var total_targets: int = 0
var powered_targets: int = 0
var level_completed: bool = false

func _ready():
	call_deferred("_initialize_targets")

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
	print("LEVEL COMPLETE! All targets powered.")
