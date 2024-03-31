extends Node

onready var map = $map

var from :Vector2
var to :Vector2
var state :int

func _on_map_on_tile_click(tile):
	if state == 0:
		_unshow()
		from = tile.id
		map.get_tile(from).highlight(true)
		state = 1
		return
		
	if state == 1:
		to = tile.id
		if from == to:
			_show_adjacent(from)
			
		else:
			_show_path(map.get_navigation(from, to))
			
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
	var tiles = map.get_adjacent_tile(from)
	for id in tiles:
		map.get_tile(id).highlight(true)
		
	map.get_tile(from).highlight(true)
	
func _show_path(paths :PoolVector2Array):
	for id in paths:
		map.get_tile(id).highlight(true)
