extends Spatial

var paths :Array

func _process(delta):
	if paths.empty():
		return
		
	var pos = global_transform.origin
	var to = paths.front()
	if pos.distance_to(to) < 0.4:
		paths.pop_front()
		return
	
	var dir = pos.direction_to(to)
	
	var t = transform.looking_at(dir * 100, Vector3.UP)
	transform = transform.interpolate_with(t, 25 * delta)
	
	translation += -transform.basis.z * 4 * delta
