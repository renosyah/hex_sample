extends Node

signal on_tile_click(tile)

const sea_tile_scene = preload("res://map/hex/sea/sea.tscn")
const ground_tile_scene = preload("res://map/hex/ground/ground.tscn")
const mountain_tile_scene = preload("res://map/hex/mountain/mountain.tscn")

export var map_size :Vector2 = Vector2(8,8)
export var spacing :float = 2

onready var holder = $holder
onready var input_detection = $input_detection
onready var collision_shape = $Area/CollisionShape

var _odd_tiles :Array = []
var _obstacle_tiles :Array = []
var _tiles :Dictionary = {}

var _click_position :Vector3
var _navigation = AStar2D.new()
var _noise :OpenSimplexNoise = OpenSimplexNoise.new()

class TileData:
	var id :Vector2
	var position :Vector3
	var tile_scene :PackedScene
	var is_odd :bool
	var has_obstacle :bool
	
	func _init(a,b,c,d,e):
		id = a
		position = b
		tile_scene = c
		is_odd = d
		has_obstacle = e

func _ready():
	collision_shape.scale = Vector3(map_size.x,0,map_size.y)
	var datas = _generate_tiles()
	_spawn_tiles(datas)
	_init_navigations()
	
func _generate_tiles() -> Array:
	_noise.seed = 1
	_noise.octaves = 3
	_noise.period = 12.0
	_noise.persistence = 0.856
	_noise.lacunarity = 1.745
	
	var tile_datas :Array = []
	
	var id :Vector2 = Vector2.ZERO
	for x in range(-map_size.x, map_size.x + 1):
		for y in range(-map_size.y, map_size.y + 1):
			var x_offset = 0
			var is_odd :bool
			
			if y % 2 != 0:
				x_offset = 0.5
				is_odd = true
				
			var pos = Vector3(x + x_offset , 0, y * 0.75) * spacing
			var noise_value :Dictionary = _get_noise_value(id)
			var tile_scene :PackedScene = noise_value["scene"]
			var has_obstacle :bool =  noise_value["has_obstacle"]
			tile_datas.append(TileData.new(id, pos, tile_scene, is_odd, has_obstacle))
			id.y += 1
			
		id.y = 0
		id.x += 1
		
	return tile_datas
	
func _get_noise_value(pos :Vector2) -> Dictionary:
	var data :Dictionary = {
		"scene" : sea_tile_scene,
		"has_obstacle" : true,
	}
	var value = 2 * abs(_noise.get_noise_2dv(pos))
	
	if value > 0.8:
		data["scene"] = mountain_tile_scene
		data["has_obstacle"] = true
		return data
		
	elif value > 0.2 and value < 0.8:
		data["scene"] = ground_tile_scene
		data["has_obstacle"] = false
		return data
		
	return data
	
func _spawn_tiles(datas :Array):
	for i in datas:
		var data :TileData = i
		if data.is_odd:
			_odd_tiles.append(data.id)
			
		if data.has_obstacle:
			_obstacle_tiles.append(data.id)
		
		var tile = data.tile_scene.instance()
		tile.id = data.id
		holder.add_child(tile)
		tile.translation = data.position
		
		_tiles[data.id] = tile
	
func _init_navigations():
	_add_point(_tiles.keys(), _navigation)
	_connect_point(_tiles.keys(), _navigation)
	_set_obstacle(_obstacle_tiles, _navigation)

func get_navigation(start :Vector2, end :Vector2) -> PoolVector2Array:
	return _get_navigation(start, end, _navigation)
	
func _get_navigation(start :Vector2, end :Vector2, nav :AStar2D) -> PoolVector2Array:
	if not nav.has_point(_get_id(start)):
		return PoolVector2Array([])
		
	if not nav.has_point(_get_id(end)):
		return PoolVector2Array([])
		
	return nav.get_point_path(_get_id(start), _get_id(end))
	
func _add_point(groups :Array, nav :AStar2D):
	for cell in groups:
		nav.add_point(_get_id(cell), cell)
		
func _set_obstacle(groups :Array, nav :AStar2D, disabled: bool = true):
	for cell in groups:
		if nav.has_point(_get_id(cell)):
			nav.set_point_disabled(_get_id(cell), disabled)
			
func _connect_point(groups :Array, nav :AStar2D):
	for cell in groups:
		var neighbors = get_adjacent_tile(cell)
		if neighbors.empty():
			continue
			
		for next_cell in neighbors:
			if groups.has(next_cell):
				nav.connect_points(_get_id(cell), _get_id(next_cell), false)
				
func _get_id(point : Vector2) -> int:
	var a = point.x
	var b = point.y
	return (a + b) * (a + b + 1) / 2 + b
	
func get_tiles() -> Array:
	return _tiles.values()
	
func get_tile(id :Vector2) -> BaseTile:
	return _tiles[id]
	
func get_adjacent_tile(from :Vector2) -> Array:
	var neighbors = []
	var directions = [
		Vector2(-1, -1), Vector2(0, -1),
		Vector2(-1, 0), Vector2(1, 0),
		Vector2(-1, 1), Vector2(0, 1)
	]
	if _odd_tiles.has(from):
		directions = [
			Vector2(1,  0), Vector2(1, -1), Vector2( 0, -1),
			Vector2(-1,  0), Vector2( 0, 1), Vector2(1, +1)
		]
		
	for i in directions:
		var pos = from + i
		if _tiles.has(pos):
			neighbors.append(pos)
			
	return neighbors
	
func _on_Area_input_event(camera, event, position, normal, shape_idx):
	_click_position = position
	input_detection.check_input(event)

func _on_input_detection_any_gesture(_sig ,event):
	if event is InputEventSingleScreenTap:
		var tile : BaseTile = get_closes_tile(_click_position)
		emit_signal("on_tile_click", tile)
		
func get_closes_tile(from :Vector3) -> BaseTile:
	var current = holder.get_child(0)
	for i in holder.get_children():
		if i == current:
			continue
			
		var dist_1 = current.translation.distance_squared_to(from)
		var dist_2 = i.translation.distance_squared_to(from)
		if dist_2 < dist_1:
			current = i
			
	return current







