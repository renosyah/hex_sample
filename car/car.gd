extends Spatial

signal on_leave(id)
signal on_enter(id)
signal on_reach

# since both of this array size are same
var paths :Array # [Vector3]
var path_ids :Array # [Vector2]

func _process(delta):
	if paths.empty():
		return
		
	var pos = global_transform.origin
	var to = paths.front()
	if pos.distance_to(to) < 0.4:
		
		paths.pop_front()
		
		# return last path
		emit_signal("on_leave", path_ids.front())
		path_ids.pop_front()
		
		if paths.empty():
			emit_signal("on_reach")
		else:
			# return on next entered path
			emit_signal("on_enter", path_ids.front())
		return
	
	var dir = pos.direction_to(to)
	
	var t = transform.looking_at(dir * 100, Vector3.UP)
	transform = transform.interpolate_with(t, 25 * delta)
	
	translation += -transform.basis.z * 4 * delta
