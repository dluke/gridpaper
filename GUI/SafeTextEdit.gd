extends TextEdit

class_name SafeTextEdit

var catch = [KEY_DELETE, KEY_LEFT, KEY_UP, KEY_RIGHT, KEY_DOWN]

func _input(event):
	if (has_focus() && !is_readonly() && event is InputEventKey 
		&& event.unicode >= 32 && !catch.has(event.scancode)):
		_gui_input(event)
		accept_event()
