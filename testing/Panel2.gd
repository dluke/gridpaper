extends Panel


func _ready():
	pass
	# $Area2D.connect('input_event', self, '_on_input_event')

func _on_input_event(viewport, event, shape_idx):
	print('connected panel input event', event.as_text())


func _input(event):
	print('panel input event', event.as_text())

func _gui_input(event):
	print('panel gui input event', event.as_text())