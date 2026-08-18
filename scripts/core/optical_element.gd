extends StaticBody2D
class_name OpticalElement

enum Type { MIRROR, ABSORBER, PRISM, SPLITTER, FILTER, PORTAL }
@export var element_type: Type = Type.MIRROR
@export var interactable: bool = true
@export var tint_color: Color = Color(1.0, 1.0, 1.0, 1.0) # White = no change

var is_dragging: bool = false
var is_hovered: bool = false

func _ready():
	modulate = tint_color
	if interactable:
		input_pickable = true
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
		input_event.connect(_on_input_event)

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
	# Multiply the colors (e.g. White (1,1,1) * Red (1,0,0) = Red (1,0,0))
	return incoming_color * tint_color

# Returns the origin point for the next laser segment. Allows portals to teleport the beam.
func get_teleport_origin(hit_position: Vector2) -> Vector2:
	return hit_position

func _on_mouse_entered():
	is_hovered = true
	# Visually indicate hover (make it brighter)
	modulate = tint_color * Color(1.3, 1.3, 1.3, 1.0)

func _on_mouse_exited():
	is_hovered = false
	modulate = tint_color

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			rotation_degrees += 45.0
			AudioManager.play_rotate()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			rotation_degrees -= 45.0
			AudioManager.play_rotate()
