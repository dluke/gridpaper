extends Control

func _input(event):
	print('Main input event', event.as_text())

func _gui_input(event):
	print('Main gui input event', event.as_text())

# experiment with this ...