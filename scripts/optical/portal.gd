extends OpticalElement
class_name Portal

@export var linked_portal: NodePath

func _init():
	element_type = Type.PORTAL

func get_outgoing_directions(incoming_direction: Vector2, _hit_normal: Vector2) -> Array[Vector2]:
	if not linked_portal.is_empty():
		var node = get_node_or_null(linked_portal)
		if node and node is Portal:
			var angle_diff = node.global_rotation - self.global_rotation
			return [incoming_direction.rotated(angle_diff)]
	return [incoming_direction]

func get_teleport_origin(hit_position: Vector2) -> Vector2:
	if not linked_portal.is_empty():
		var node = get_node_or_null(linked_portal)
		if node and node is Portal:
			return node.global_position
	return hit_position

var _time: float = 0.0

func _process(delta):
	_time += delta * 3.5
	var aura = 0.75 + 0.25 * sin(_time)
	var visual = get_node_or_null("ColorRect")
	if visual:
		visual.color.a = aura

