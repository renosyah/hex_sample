extends Spatial

var move_speed := 0.015        # base pan speed
var zoom_speed := 0.02         # zoom sensitivity

var touches := {}
var is_pinch_zoom := false
var last_pinch_distance := 0.0

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = event.position
		else:
			touches.erase(event.index)
			if touches.size() < 2:
				is_pinch_zoom = false

	elif event is InputEventScreenDrag:
		touches[event.index] = event.position

		if touches.size() == 1:
			# Single finger drag (pan camera)
			var delta = event.relative

			# Adjust pan speed based on current zoom level (Y height)
			var zoom_factor = clamp(translation.y / 10.0, 0.2, 3.0)
			var adjusted_move_speed = move_speed * zoom_factor

			translate(Vector3(-delta.x * adjusted_move_speed, 0, -delta.y * adjusted_move_speed))

		elif touches.size() == 2:
			# Pinch zoom
			var keys = touches.keys()
			var pos1 = touches[keys[0]]
			var pos2 = touches[keys[1]]

			var current_distance = pos1.distance_to(pos2)

			if !is_pinch_zoom:
				is_pinch_zoom = true
				last_pinch_distance = current_distance
			else:
				var delta_distance = current_distance - last_pinch_distance
				translate(Vector3(0, -delta_distance * zoom_speed, 0))
				last_pinch_distance = current_distance

func _process(delta):
	# Clamp Y zoom height
	translation.y = clamp(translation.y, 2, 50)

