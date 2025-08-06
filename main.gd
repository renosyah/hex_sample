extends Node

onready var map = $map
onready var car = $car

var from :Vector2
var to :Vector2
var state :int

func _on_map_on_tile_click(tile):
	if state == 0:
		_unshow()
		from = tile.id
		car.paths.clear()
		car.translation = tile.global_transform.origin
		map.get_tile(from).highlight(true)
		state = 1
		return
		
	if state == 1:
		to = tile.id
		if from == to:
			_show_adjacent(from)
			
		else:
			var paths = map.get_navigation(from, to)
			car.paths = _get_hex_positions(paths)
			car.path_ids = paths
			_show_path(paths)
			
		state = 2
		return
		
	if state == 2:
		_unshow()
		state = 0
		return
		
func _unshow():
	var tiles = map.get_tiles()
	for t in tiles:
		t.highlight(false)
		
func _show_adjacent(from :Vector2):
	var tiles = map.get_astar_adjacent_tile(from, 2)
	for id in tiles:
		map.get_tile(id).highlight(true)
		
	map.get_tile(from).highlight(true)
	
func _get_hex_positions(paths :PoolVector2Array) -> Array:
	var datas = []
	for id in paths:
		datas.append(map.get_tile(id).global_transform.origin)
		
	return datas
	
func _show_path(paths :PoolVector2Array):
	for id in paths:
		map.get_tile(id).highlight(true)

func _on_car_on_reach():
	_unshow()
	state = 0
	
func _on_car_on_enter(id):
	print("car enter : ",id)
	
func _on_car_on_leave(id):
	print("car leave : ",id)
	map.get_tile(id).highlight(false)












