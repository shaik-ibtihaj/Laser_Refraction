extends StaticBody2D
class_name BlackHole

var _frames_since_hit: int = 0
var is_hitting_laser: bool = false

func receive_laser(_incoming_color: Color):
	_frames_since_hit = 0
	if not is_hitting_laser:
		is_hitting_laser = true
		_on_hit_start()

func _physics_process(_delta):
	if is_hitting_laser:
		_frames_since_hit += 1
		if _frames_since_hit > 2:
			is_hitting_laser = false

func _process(delta):
	rotation += delta * 1.2

func _on_hit_start():
	var levels = get_tree().get_nodes_in_group("level_manager")
	if levels.size() > 0:
		levels[0].lose_life()

