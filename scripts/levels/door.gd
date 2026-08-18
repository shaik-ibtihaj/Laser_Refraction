extends Absorber
class_name Door

@export var connected_switch: NodePath
var is_open: bool = false

@onready var visual = $ColorRect
@onready var col = $CollisionShape2D

func _ready():
	super._ready()
	if not connected_switch.is_empty():
		var node = get_node_or_null(connected_switch)
		if node and node.has_signal("power_state_changed"):
			node.power_state_changed.connect(_on_switch_toggled)

func _on_switch_toggled(is_powered: bool):
	is_open = is_powered
	if is_open:
		col.set_deferred("disabled", true)
		visual.color.a = 0.2
	else:
		col.set_deferred("disabled", false)
		visual.color.a = 1.0
