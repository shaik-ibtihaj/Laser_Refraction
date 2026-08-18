extends OpticalElement
class_name Prism

@export var index_of_refraction: float = 1.5

func _init():
	element_type = Type.PRISM

func get_outgoing_directions(incoming_direction: Vector2, hit_normal: Vector2) -> Array[Vector2]:
	var dot = incoming_direction.dot(hit_normal)
	
	var actual_normal: Vector2
	var eta: float
	
	if dot < 0:
		# Entering the prism (Air -> Glass)
		actual_normal = hit_normal
		eta = 1.0 / index_of_refraction
	else:
		# Exiting the prism (Glass -> Air)
		# Hit normal points OUT of the shape, away from ray. 
		# refracted() expects normal pointing against the ray.
		actual_normal = -hit_normal
		eta = index_of_refraction / 1.0
		
	var refracted = incoming_direction.refracted(actual_normal, eta)
	
	if refracted == Vector2.ZERO:
		# Total internal reflection
		return [incoming_direction.bounce(actual_normal)]
		
	return [refracted]
