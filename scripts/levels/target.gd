extends StaticBody2D
class_name Target

signal power_state_changed(is_powered: bool)

var is_powered: bool = false
var _frames_since_hit: int = 0

@onready var visual = $ColorRect
@onready var power_particles = $PowerParticles if has_node("PowerParticles") else null

@export var required_color: Color = Color(1, 1, 1, 1) # Default to white (any color matches)
@export var is_level_goal: bool = true

func _ready():
	if is_level_goal:
		add_to_group("targets")
	_update_visuals()

var current_frame_color: Color = Color(0, 0, 0, 1)

func receive_laser(incoming_color: Color = Color(1,1,1,1)):
	current_frame_color.r = min(current_frame_color.r + incoming_color.r, 1.0)
	current_frame_color.g = min(current_frame_color.g + incoming_color.g, 1.0)
	current_frame_color.b = min(current_frame_color.b + incoming_color.b, 1.0)
	_frames_since_hit = 0

func _physics_process(_delta):
	if _frames_since_hit == 0:
		if required_color == Color(1,1,1,1) or current_frame_color.is_equal_approx(required_color):
			if not is_powered:
				_set_powered(true)
		else:
			if is_powered:
				_set_powered(false)
	else:
		if is_powered and _frames_since_hit > 2:
			_set_powered(false)
			
	_frames_since_hit += 1
	current_frame_color = Color(0, 0, 0, 1)

func _set_powered(state: bool):
	if is_powered != state:
		is_powered = state
		if is_powered:
			AudioManager.play_target_hit()
		power_state_changed.emit(is_powered)
		_update_visuals()

func _update_visuals():
	var active_color = required_color if required_color != Color(1,1,1,1) else Color(0.0, 1.0, 0.5, 1.0)
	if is_powered:
		visual.color = active_color
		if power_particles:
			power_particles.color = active_color
			power_particles.emitting = true
	else:
		visual.color = Color(0.2, 0.2, 0.2, 1.0)
		if power_particles:
			power_particles.emitting = false

