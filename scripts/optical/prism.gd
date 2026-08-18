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
		actual_normal = -hit_normal
		eta = index_of_refraction / 1.0
		
	var refracted = _refract_2d(incoming_direction, actual_normal, eta)
	
	if refracted == Vector2.ZERO:
		# Total internal reflection
		return [incoming_direction.bounce(actual_normal)]
		
	return [refracted]

# Implementation of 2D Snell's Law Vector Refraction
func _refract_2d(incident: Vector2, normal: Vector2, eta: float) -> Vector2:
	var i = incident.normalized()
	var n = normal.normalized()
	var cos_i = -n.dot(i)
	if cos_i < 0.0:
		n = -n
		cos_i = -n.dot(i)
	var k = 1.0 - eta * eta * (1.0 - cos_i * cos_i)
	if k < 0.0:
		# Total internal reflection
		return Vector2.ZERO
	return (eta * i + (eta * cos_i - sqrt(k)) * n).normalized()
