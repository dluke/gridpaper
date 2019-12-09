extends Control

func _gui_input(event):
	if event is InputEventMouseButton:
		print('gui_input event ', event.as_text())