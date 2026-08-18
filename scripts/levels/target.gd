extends StaticBody2D
class_name Target

signal power_state_changed(is_powered: bool)

var is_powered: bool = false
var _frames_since_hit: int = 0

@onready var visual = $ColorRect

@export var required_color: Color = Color(1, 1, 1, 1) # Default to white (any color matches)
@export var is_level_goal: bool = true

func _ready():
	if is_level_goal:
		add_to_group("targets")
	_update_visuals()

func receive_laser(incoming_color: Color = Color(1,1,1,1)):
	# If required color is white, accept anything. Else check for exact match.
	if required_color == Color(1,1,1,1) or incoming_color.is_equal_approx(required_color):
		_frames_since_hit = 0
		if not is_powered:
			_set_powered(true)

func _physics_process(_delta):
	_frames_since_hit += 1
	if is_powered and _frames_since_hit > 2:
		_set_powered(false)

func _set_powered(state: bool):
	if is_powered != state:
		is_powered = state
		if is_powered:
			AudioManager.play_target_hit()
		power_state_changed.emit(is_powered)
		_update_visuals()

func _update_visuals():
	if is_powered:
		visual.color = required_color if required_color != Color(1,1,1,1) else Color(0.0, 1.0, 0.5, 1.0)
	else:
		visual.color = Color(0.2, 0.2, 0.2, 1.0)
