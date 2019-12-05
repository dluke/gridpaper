extends Area2D

signal clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input_event(viewport, event, shape_idx):
	# print ('@circle input event', event.as_text())
	if event is InputEventMouseButton:
		emit_signal("clicked", event)