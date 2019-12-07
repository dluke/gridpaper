extends LineEdit

class_name SafeLineEdit

func _input(event):
	if (has_focus() && is_editable() && event is InputEventKey 
		and event.unicode >= 32 and event.scancode != KEY_DELETE):
		_gui_input(event)
		accept_event()
