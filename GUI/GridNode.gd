extends Control

class_name GridNode

"""
 components:
5 distinct Areas which respond to input: node, right, down, left, up
"""

# release is opposite of grab
signal node_release
# the opposite of 'select' is 'unselect'
signal node_select
#
signal node_hovered
signal node_unhovered
signal node_moved_relative
#
signal node_make_edge
signal break_edge

enum Dir {RIGHT, DOWN, LEFT, UP, DOWN_LAYER, UP_LAYER}


var EdgeAction_factory = preload('res://GUI/EdgeAction.tscn')
# var arrow_texture = preload('res://GUI/icons/arrow.png')
var arrows: Array

# node colors
export var base_color = Color('d4d4d4')
var idle_border_color = Color('6f9dc5')
var idle_border_width: int = 3

# var node_texture = preload('res://GUI/icons/node_circle.svg')
# var arrow_texture = preload('res://GUI/icons/node_arrow.svg')

# the distance from the center of the node to the center of the arrow
var arrow_offset = 50 + 15.20

export var idle_radius: int = 16
export var select_radius: int = idle_radius + 1
export var grid_rect_size: Vector2 =  Vector2(50,50)
# 
# unique gridnode index 
var idx: int
# index in the grid
var ixy: Vector2

var hovered: bool = 0
var grabbed: bool = 0 
var moved: Vector2
const moved_threshold_squared: int = 25
var selected: bool = 0  # multiple nodes can be selected
export var grabbable: bool = 1

# state triggered after mouse over
var activated = false

# mimick area2d 
var position: Vector2 setget set_position, get_position

enum EdgeDir {RIGHT, UP, LEFT, DOWN}

var tile

var edges: Array

# child references
var inputcontrol: Control
var edgecontrol: Control

func _init():
	rect_min_size = Vector2(0,0)

	# new instance, new array	
	edges = []
	edges.resize(6)

func add_edge(dir, edge):
	edges[dir] = edge
	arrows[dir].set_state(0)

func remove_edge(dir):
	edges[dir] = null
	arrows[dir].set_state(1)

func set_position(position):
	rect_position = position

func get_position():
	return rect_position

func set_box_size(box_size):
	edgecontrol.rect_min_size = box_size
	edgecontrol.rect_position = -box_size/2

func _ready():
	# 
	inputcontrol = find_node('InputControl')
	edgecontrol = find_node('EdgeControl')

	# setup mouse collision
	var box_size = Vector2(100,100)  # this box size should be set by TileSpace
	set_box_size(box_size)

	var input_box_size = 2*Vector2(select_radius, select_radius)
	inputcontrol.rect_min_size = input_box_size

	# connect 
	edgecontrol.connect("mouse_exited", self, "_on_mouse_exit_box")
	edgecontrol.connect("hovered_quadrant", self, "_on_hovered_quadrant")
	edgecontrol.connect("clicked_quadrant", self, "_on_clicked_quadrant")

	inputcontrol.connect("mouse_entered", self, "_on_mouse_entered")
	inputcontrol.connect("mouse_exited", self, "_on_mouse_exited")
	inputcontrol.connect("clicked", self, "_on_clicked")

	# setup arrows
	var direction = constants.Direction.values()
	arrows = []
	arrows.resize(4)
	for i in range(4):
		var action = EdgeAction_factory.instance()
		 # needs scaling
		action.position = 40 * direction[i] 
		action.rotation += i*PI/2
		arrows[i] = action 
		add_child(action)
		# collision
		# arrow.connect("clicked", self, '_on_arrow_clicked', [arrow])

	_scale_with(idle_radius)


func _on_hovered_quadrant(quadrant):
	for i in range(4):
		if i == quadrant:
			arrows[i].modulate = Color(1,1,1)
		else:
			arrows[i].modulate = colors.black

func _on_clicked_quadrant(quadrant):
	var this_arrow = arrows[quadrant]
	if this_arrow.curr_state == 0:
		emit_signal('break_edge', edges[quadrant])
	elif this_arrow.curr_state == 1:
		emit_signal('node_make_edge', self, quadrant)
	
func _input(event):
	if event is InputEventMouseMotion and grabbed == true:
		rect_position += event.relative
		moved += event.relative
		emit_signal('node_moved_relative', self, event.relative)

func _on_clicked(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			if grabbable:
				grab()
		elif !event.pressed:
			if moved.length_squared() < moved_threshold_squared:
				toggle_select()
			ungrab()

func _scale_with(radius):
	idle_border_width = max(int(radius/4),3)
	
func _draw():
	# border_color = idle_border_color
	if hovered:
		draw_circle(Vector2(), idle_radius, colors.hovered_border_color)
		draw_circle(Vector2(), idle_radius-idle_border_width, base_color)
	else:
		draw_circle(Vector2(), idle_radius, idle_border_color)
		draw_circle(Vector2(), idle_radius-idle_border_width, base_color)
	if selected:
		draw_circle_custom(idle_radius + 2, colors.white, 2)


# func snap_back():
# 	position = get_position(get_idx(ixy))

func grab():
	grabbed = 1

func ungrab():
	grabbed = 0
	moved = Vector2(0,0)
	# snap_back()
	emit_signal('node_release', self)


func toggle_select():
	if selected:
		unselect()
	else:
		select()

func select():
	selected = true
	emit_signal('node_select', self)
	update()

func unselect():
	selected = false
	update()

func set_hovered():
	hovered = 1
	update()

func set_unhovered():
	hovered = 0
	update()

func set_activated():
	activated = true
	edgecontrol.activate()
	for arrow in arrows:
		arrow.visible = true
	update()

func set_unactivated():
	activated = false
	edgecontrol.deactivate()
	for arrow in arrows:
		arrow.visible = false
	update()

func _on_mouse_entered():
	set_hovered()
	set_activated()
	emit_signal('node_hovered', self)

func _on_mouse_exited():
	set_unhovered()
	emit_signal('node_unhovered', self)
	
func _on_mouse_exit_box():
	set_unactivated()
	emit_signal('node_unhovered', self)


### 

func draw_circle_custom(radius, color, width, maxerror = 0.25):

    if radius <= 0.0:
        return

    var maxpoints = 1024 - 1 # I think this is renderer limit

    var numpoints = ceil(PI / acos(1.0 - maxerror / radius))
    numpoints = clamp(numpoints, 3, maxpoints)

    var points = PoolVector2Array([])

    for i in numpoints:
        var phi = i * PI * 2.0 / numpoints
        var v = Vector2(sin(phi), cos(phi))
        points.push_back(v * radius)
    points.push_back(points[0])

    draw_polyline(points, color, width)
