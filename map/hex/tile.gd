extends Spatial
class_name BaseTile

export var id :Vector2
export var nav_id :int

onready var label_3d = $Label3D
onready var highlight = $highlight

func _ready():
	label_3d.text = "(%s)\n%s" % [nav_id, id]
	highlight.visible = false

func highlight(_show :bool):
	highlight.visible = _show
