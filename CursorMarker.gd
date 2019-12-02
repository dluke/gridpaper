extends Node2D

class_name CursorMarker

export var color = Color("#5a8fe6")

onready var notegrid = get_parent()
var grididx = Vector2(1,1)


func _ready():
	grididx = notegrid.get_grididx(get_viewport().get_mouse_position() - notegrid.position)

func _draw():

	var pos = notegrid.get_pos(grididx)

	var size = notegrid.size
	var rect = Rect2(pos, Vector2(size,size))

	var poly = [pos, Vector2(pos.x,pos.y+size), rect.end, Vector2(pos.x+size,pos.y), pos]
	draw_polyline(poly, color, 2)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		grididx = notegrid.get_grididx(event.position - notegrid.position)
	update()

func _process(delta):
	pass

