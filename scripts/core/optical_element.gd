extends StaticBody2D
class_name OpticalElement

enum Type { MIRROR, ABSORBER, PRISM, SPLITTER, FILTER, PORTAL }
@export var element_type: Type = Type.MIRROR
@export var interactable: bool = true
@export var tint_color: Color = Color(1.0, 1.0, 1.0, 1.0) # White = no change
@export var draggable: bool = true

var is_dragging: bool = false
var is_hovered: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var click_start_pos: Vector2 = Vector2.ZERO

func _ready():
	modulate = tint_color
	# Recursively set mouse_filter = MOUSE_FILTER_IGNORE on all Control children so they don't block physics clicks
	_ignore_control_mouse_filter(self)
	
	if interactable:
		input_pickable = true
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
		input_event.connect(_on_input_event)

func _ignore_control_mouse_filter(node: Node):
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ignore_control_mouse_filter(child)

func _unhandled_input(event: InputEvent):
	if is_dragging and event is InputEventMouseMotion:
		global_position = get_global_mouse_position() + drag_offset
	elif is_dragging and event is InputEventMouseButton and not event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = false

func _on_mouse_entered():
	is_hovered = true
	modulate = tint_color * Color(1.3, 1.3, 1.3, 1.0)

func _on_mouse_exited():
	is_hovered = false
	if not is_dragging:
		modulate = tint_color

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int):
	_handle_input(event)

func _on_input_event(_viewport, event, _shape_idx):
	_handle_input(event)

func _handle_input(event: InputEvent):
	if not interactable: return
	var levels = get_tree().get_nodes_in_group("level_manager")
	if levels.size() > 0 and levels[0].game_over:
		return
		
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				click_start_pos = event.position
				if draggable:
					is_dragging = true
					drag_offset = global_position - get_global_mouse_position()
				else:
					_rotate_element(45.0)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				_rotate_element(-45.0)
		else:
			if event.button_index == MOUSE_BUTTON_LEFT and is_dragging:
				is_dragging = false
				# If mouse barely moved (was a click instead of a drag), perform rotation
				if click_start_pos.distance_to(event.position) < 5.0:
					_rotate_element(45.0)

func _rotate_element(angle_deg: float):
	rotation_degrees += angle_deg
	AudioManager.play_rotate()
	var levels = get_tree().get_nodes_in_group("level_manager")
	if levels.size() > 0:
		levels[0].consume_move()

# Calculates the new direction(s) of a laser after hitting this element
func get_outgoing_directions(incoming_direction: Vector2, hit_normal: Vector2) -> Array[Vector2]:
	if element_type == Type.MIRROR:
		return [incoming_direction.bounce(hit_normal)]
	elif element_type == Type.SPLITTER:
		return [incoming_direction.bounce(hit_normal), incoming_direction]
	elif element_type == Type.ABSORBER:
		return []
	return [incoming_direction]

# Calculates the new color of the laser after passing/bouncing
func get_outgoing_color(incoming_color: Color) -> Color:
	var new_color = Color(
		min(incoming_color.r + tint_color.r, 1.0),
		min(incoming_color.g + tint_color.g, 1.0),
		min(incoming_color.b + tint_color.b, 1.0),
		1.0
	)
	return new_color

# Returns the origin point for the next laser segment. Allows portals to teleport the beam.
func get_teleport_origin(hit_position: Vector2) -> Vector2:
	return hit_position
