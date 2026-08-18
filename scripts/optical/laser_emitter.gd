extends Node2D
class_name LaserEmitter

@onready var default_beam_line = $BeamLine

@export var max_distance: float = 2000.0
@export var max_bounces: int = 10
@export var laser_color: Color = Color(1.0, 1.0, 1.0, 1.0) # Default to white

var line_pool: Array[Line2D] = []
var spark_scene = preload("res://scenes/effects/LaserSparks.tscn")
var spark_pool: Array[CPUParticles2D] = []

func _ready():
	line_pool.append(default_beam_line)

func get_line(index: int) -> Line2D:
	while index >= line_pool.size():
		var new_line = default_beam_line.duplicate()
		add_child(new_line)
		line_pool.append(new_line)
	return line_pool[index]

func get_spark(index: int) -> CPUParticles2D:
	while index >= spark_pool.size():
		var new_spark = spark_scene.instantiate()
		add_child(new_spark)
		spark_pool.append(new_spark)
	return spark_pool[index]

func hide_unused_lines(active_count: int):
	for i in range(line_pool.size()):
		line_pool[i].visible = (i < active_count)

func hide_unused_sparks(active_count: int):
	for i in range(spark_pool.size()):
		spark_pool[i].emitting = (i < active_count)
		spark_pool[i].visible = (i < active_count)

func _physics_process(_delta):
	calculate_laser_path()

func calculate_laser_path():
	var space_state = get_world_2d().direct_space_state
	
	var active_line_count = 0
	var active_spark_count = 0
	
	# Queue stores dictionaries: { pos, dir, bounces, line_idx, color }
	var queue = [{
		"pos": global_position,
		"dir": global_transform.x.normalized(),
		"bounces": 0,
		"line_idx": active_line_count,
		"color": laser_color
	}]
	
	active_line_count += 1
	var current_line = get_line(0)
	current_line.clear_points()
	current_line.default_color = queue[0].color
	current_line.add_point(to_local(queue[0].pos))
	
	while queue.size() > 0:
		var current = queue.pop_front()
		
		var current_pos = current.pos
		var current_dir = current.dir
		var bounces = current.bounces
		var line_idx = current.line_idx
		var current_color = current.color
		
		var line = get_line(line_idx)
		
		while bounces <= max_bounces:
			var query = PhysicsRayQueryParameters2D.create(
				current_pos, 
				current_pos + current_dir * max_distance
			)
			
			var result = space_state.intersect_ray(query)
			
			if result:
				var hit_pos = result.position
				line.add_point(to_local(hit_pos))
				
				var spark = get_spark(active_spark_count)
				active_spark_count += 1
				spark.global_position = hit_pos
				spark.rotation = result.normal.angle()
				spark.color = current_color
				spark.emitting = true
				
				var collider = result.collider
				if collider is OpticalElement:
					var outgoing = collider.get_outgoing_directions(current_dir, result.normal)
					
					if outgoing.size() == 0:
						break # Absorbed
					
					current_color = collider.get_outgoing_color(current_color)
					var new_origin = collider.get_teleport_origin(hit_pos)
						
					# The first direction continues on the current line
					current_dir = outgoing[0]
					current_pos = new_origin + current_dir * 0.1
					line.default_color = current_color
					
					# Any additional directions spawn new branches (and new lines)
					for i in range(1, outgoing.size()):
						var new_dir = outgoing[i]
						var new_pos = new_origin + new_dir * 0.1
						
						var new_line_idx = active_line_count
						active_line_count += 1
						
						var new_line = get_line(new_line_idx)
						new_line.clear_points()
						new_line.default_color = current_color
						new_line.add_point(to_local(hit_pos)) # branch starts here
						
						queue.append({
							"pos": new_pos,
							"dir": new_dir,
							"bounces": bounces + 1,
							"line_idx": new_line_idx,
							"color": current_color
						})
						
				else:
					if collider.has_method("receive_laser"):
						collider.receive_laser(current_color)
					break 
			else:
				var end_pos = current_pos + current_dir * max_distance
				line.add_point(to_local(end_pos))
				break
				
			bounces += 1
			
	sync_line_cores(active_line_count)
	hide_unused_lines(active_line_count)
	hide_unused_sparks(active_spark_count)

func sync_line_cores(active_count: int):
	for i in range(active_count):
		var line = line_pool[i]
		if line.get_child_count() > 0:
			var core = line.get_child(0) as Line2D
			if core:
				core.points = line.points
