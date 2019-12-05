extends Node2D

class_name CursorMarker

export var color = Color("#5a8fe6")

onready var notegrid = get_parent()
onready var idx = notegrid.extents


func _ready():
	pass

func _draw():
	# 
	var pos = notegrid.get_pos(idx)
	var size = notegrid.size
	var rect = Rect2(pos, Vector2(size,size))
	var poly = [pos, Vector2(pos.x,pos.y+size), rect.end, Vector2(pos.x+size,pos.y), pos]
	draw_polyline(poly, color, 2)

func _input(event):
	if event is InputEventMouseMotion:
		idx = notegrid.get_idx(to_local(event.position))
	update()

func _process(delta):
	pass

