extends Control

var quad = [-3*PI/4, -PI/4, PI/4, 3*PI/4]

signal clicked_quadrant
signal hovered_quadrant

var quadrant = -1
var Dir = constants.Dir
var active = false
var hovered_quadrant: int
# var color_quadrant: Array

var blue_hl = Color( 0, 0.81, 0.82, 0.3 )
var color_quadrant = [blue_hl, blue_hl, blue_hl]

func _ready():
	# var blue_hl = colors.blue_hightlight
	# blue_hl.a = 0.5

	# set_mouse_filter(MOUSE_FILTER_IGNORE)
	# connect('mouse_motion')
	pass

func activate():
	set_mouse_filter(MOUSE_FILTER_PASS)
	active = true
	update()

func deactivate():
	set_mouse_filter(MOUSE_FILTER_IGNORE)
	active = false
	update()

func _gui_input(event):
	if event is InputEventMouseMotion:
		quadrant = _get_quadrant(event.position)
		emit_signal('hovered_quadrant', quadrant)
		update()

	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.pressed:
		assert(quadrant != -1)
		quadrant = _get_quadrant(event.position)
		emit_signal('clicked_quadrant', quadrant)
		accept_event()


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


func _draw():
	if active:
		var cpt = rect_min_size/2
		if quadrant >= 0:
			_draw_quadrant(quadrant)

		for diagonal in constants.Diagonal.values():
			var sized_diagonal = rect_min_size.x/2 * sqrt(2.0) * diagonal
			draw_line(cpt + 0.3*sized_diagonal, cpt + 0.8*sized_diagonal, colors.black, 1)

func _draw_quadrant(quadrant):
	print('polygon colors', color_quadrant)
	var cpt = rect_min_size/2
	var corners = get_rect_corners(Rect2(Vector2(0,0), rect_size))
	var poly = [cpt, corners[wrapi(quadrant-1,0,4)], corners[quadrant]]
	draw_polygon(poly, color_quadrant)

static func get_rect_corners(rect):
	return [rect.end, Vector2(rect.position.x, rect.end.y), rect.position, Vector2(rect.end.x, rect.position.y)]


