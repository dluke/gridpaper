extends Control

class_name Draggable

var grabbed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	rect_position = Vector2(500,200)


func _gui_input(event):
	print('gui input click')

	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			grabbed = 1 
		elif !event.pressed:
			grabbed = 0 

	if event is InputEventMouseMotion and grabbed == true:
		rect_position += event.relative
