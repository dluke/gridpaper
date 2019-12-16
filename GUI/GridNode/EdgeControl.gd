extends Control

var quad = [-3*PI/4, -PI/4, PI/4, 3*PI/4]

signal clicked_quadrant
signal hovered_quadrant

var quadrant = -1
var Dir = constants.Dir

func _ready():
	# set_mouse_filter(MOUSE_FILTER_IGNORE)
	# connect('mouse_motion')
	pass

func activate():
	set_mouse_filter(MOUSE_FILTER_PASS)

func deactivate():
	set_mouse_filter(MOUSE_FILTER_IGNORE)


func _gui_input(event):
	if event is InputEventMouseMotion:
		quadrant = _get_quadrant(event.position)
		emit_signal('hovered_quadrant', quadrant)

	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.pressed:
		assert(quadrant != -1)
		quadrant = _get_quadrant(event.position)
		emit_signal('clicked_quadrant', quadrant)


func _get_quadrant(pos):
	var angle = (pos - rect_position.abs()).angle()

	if (angle > quad[0]) && (angle <= quad[1]):
		quadrant = Dir.UP
	elif (angle > quad[1]) && (angle <= quad[2]):
		quadrant = Dir.RIGHT
	elif (angle > quad[2]) && (angle <= quad[3]):
		quadrant = Dir.DOWN
	else:
		quadrant = Dir.LEFT

	return quadrant



