extends Area2D


func _ready():
	# connect('input_event', self, '_input_event')
	pass

# func _on_input_event(viewbox, event, shape_idx):
# 	print('connect input event ', event.as_text(), ' ', shape_idx)

func _input(event):
	if event is InputEventMouseButton:
		print('_input event at area2d ', event.as_text())

	
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		print('input event at area2d ', event.as_text(), ' ', shape_idx)
