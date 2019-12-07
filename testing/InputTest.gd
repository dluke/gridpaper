extends Control



func _ready():
	find_node('SafeLineEdit').grab_focus()

func _input(event):
	if event is InputEventKey:
		print('input ', event, event.as_text(), ' ', event.pressed)

func _gui_input(event):
	if event is InputEventKey:
		print('gui ', event, event.as_text(), ' ', event.pressed)