extends Node2D


func _input(event):
	if event is InputEventMouseButton:
		print('Main input event', event.as_text())
