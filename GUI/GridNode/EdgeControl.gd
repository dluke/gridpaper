extends Control

# func _ready():
# 	set_mouse_filter(MOUSE_FILTER_IGNORE)

func activate():
	set_mouse_filter(MOUSE_FILTER_PASS)

func deactivate():
	set_mouse_filter(MOUSE_FILTER_IGNORE)

