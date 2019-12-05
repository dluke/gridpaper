extends Area2D

signal mouse_exited_dir

enum Dir {RIGHT, DOWN, LEFT, UP}

var quad = [-3*PI/4, -PI/4, PI/4, 3*PI/4]


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("mouse_exited", self, "_on_mouse_exited")

func _on_mouse_exited():
	# catch exit signal and pass a more detailed signal
	# no event argument so we need to retrieve the mouse position from global scope
	var mpos = get_viewport().get_mouse_position()
	# match quadrant
	var pos = get_parent().position
	var angle = mpos.angle_to_point(pos)
	# print('position', pos, mpos)
	# print('angle', angle)
	if (angle > quad[0]) && (angle <= quad[1]):
		emit_signal("mouse_exited_dir", Dir.UP)
	elif (angle > quad[1]) && (angle <= quad[2]):
		emit_signal("mouse_exited_dir", Dir.RIGHT)
	elif (angle > quad[2]) && (angle <= quad[3]):
		emit_signal("mouse_exited_dir", Dir.DOWN)
	else:
		emit_signal("mouse_exited_dir", Dir.LEFT)

