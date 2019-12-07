extends TextEdit

class_name SafeTextEdit

func _input(event):
	if (has_focus() && !is_readonly() && event is InputEventKey 
		and event.unicode >= 32 and event.scancode != KEY_DELETE):
		_gui_input(event)
		accept_event()
