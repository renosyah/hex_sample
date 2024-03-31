extends Spatial
class_name BaseTile

export var id :Vector2

onready var label_3d = $Label3D
onready var highlight = $highlight

func _ready():
	label_3d.text = "%s" % id
	highlight.visible = false

func highlight(_show :bool):
	highlight.visible = _show
