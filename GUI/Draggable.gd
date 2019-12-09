extends Control

class_name Draggable

var grabbed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# rect_position = Vector2(500,200)
	pass


func _gui_input(event):
	# print('drag input')
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			grabbed = true
		elif !event.pressed:
			grabbed = false 

	if event is InputEventMouseMotion and grabbed == true:
		rect_position += event.relative
