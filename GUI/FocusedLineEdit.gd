extends LineEdit

class_name SafeLineEdit

func _input(event):
	if event is InputEventMouseButton || event is InputEventMouseMotion:
		return 
	print ('?intercept key? ', event.as_text(), ' ', event.pressed)
	if event is InputEventKey and event.unicode >= 32 and event.scancode != KEY_DELETE:
		print ('intercept key ', event.as_text(), ' ', event.pressed)
		_gui_input(event)

# func _gui_input(event):
# 	._gui_input(event)
# 	if event is InputEventKey:
# 		# this prevent text input
# 		accept_event()
