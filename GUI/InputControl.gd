extends Control


signal clicked 

func _gui_input(event):
	if event is InputEventMouseButton:
		emit_signal('clicked', event)
