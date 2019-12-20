extends Node2D

class_name GridNode

"""
 components:
5 distinct Areas which respond to input: node, right, down, left, up
"""


# release is opposite of grab
signal node_grabbed
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
enum State {Connect, Disconnect, Incoming}
var transition_to_incoming = {State.Connect:State.Incoming, State.Disconnect:-1}
var transition_to_normal = {-1:State.Disconnect, State.Incoming:State.Connect}

# var arrow_texture = preload('res://GUI/icons/arrow.png')
var arrows: Array

# node colors
export var base_color = Color('d4d4d4')
export var idle_border_color = Color('6f9dc5')

# unique gridnode index 
var idx: int
var z_level: int = 0
# index in the grid
var ixy: Vector2


var box_size = Vector2(100,100)  # this box size should be set by TileSpace

export var idle_radius: int = 16
export var select_margin: int = 1
export var idle_border_width: int = 3
var select_radius: int

var hovered: bool = 0
var grabbed: bool = 0 
var moved: Vector2
var selected: bool = 0  # multiple nodes can be selected
var grabbable: bool = 1
const moved_threshold_squared: int = 25


# flags
#
var make_edge_state = false
# triggered after mouse over
var activated = false

enum EdgeDir {RIGHT, UP, LEFT, DOWN}

var tile

var edges: Array

# child references
var inputcontrol: Control
var edgecontrol: Control

func _init():

	# new instance, new array	
	edges = []
	edges.resize(6)


func set_box_size(box_size):
	edgecontrol.rect_min_size = box_size
	edgecontrol.rect_position = -box_size/2

func _ready():
	# 
	inputcontrol = find_node('InputControl')
	edgecontrol = find_node('EdgeControl')

	# setup mouse collision
	set_box_size(box_size)

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
		action.position = 40 * direction[i] 
		action.rotation += i*PI/2
		arrows[i] = action 
		add_child(action)

	scale_with(idle_radius)

func scale_with(radius):
	idle_radius = radius
	select_radius = idle_radius + select_margin
	idle_border_width = max(int(radius/3),3)
	
	var input_box_size = 2*Vector2(select_radius, select_radius)
	inputcontrol.rect_min_size = input_box_size

func add_edge(dir, edge):
	edges[dir] = edge
	arrows[dir].set_state(State.Disconnect)

func remove_edge(dir):
	edges[dir] = null
	arrows[dir].set_state(State.Connect)

func _state_transition(transition):
	for arrow in arrows:
		if transition.has(arrow.curr_state):
			arrow.set_state(transition[arrow.curr_state])

func set_state_incoming():
	_state_transition(transition_to_incoming)
	make_edge_state = true
	set_activated()

func set_state_normal():
	_state_transition(transition_to_normal)
	make_edge_state = false
	set_unactivated()

func _on_hovered_quadrant(quadrant):
	for i in range(4):
		if i == quadrant:
			arrows[i].highlight_on()
		else:
			arrows[i].highlight_off()

func _on_clicked_quadrant(quadrant):
	print('clicked ', quadrant)
	var this_arrow = arrows[quadrant]
	if !make_edge_state:
		if this_arrow.curr_state == 1:
			emit_signal('break_edge', edges[quadrant])
		elif this_arrow.curr_state == 0:
			emit_signal('node_make_edge', self, quadrant)
	else:
		if this_arrow.curr_state == State.Incoming:
			emit_signal('node_make_edge', self, quadrant)

	
func _input(event):
	if event is InputEventMouseMotion and grabbed == true:
		position += event.relative
		moved += event.relative
		emit_signal('node_moved_relative', self, event.relative)

func _on_clicked(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			if grabbable:
				grab()
				# print('event.global_position, ', event.global_position)
				# print(to_local(event.global_position))
				emit_signal('node_grabbed', self)
		elif !event.pressed:
			if moved.length_squared() < moved_threshold_squared:
				print('toggle select after moving ', moved)
				toggle_select()
			ungrab()


func get_connected_node(dir):
	var edge = edges[dir]
	return edge.from if edge.from != self else edge.to

func attach(_tile):
	tile = _tile
	tile.node = self

func detach():
	tile.node = null
	tile = null


func grab():
	grabbed = 1
	set_unactivated()

func ungrab():
	grabbed = 0
	moved = Vector2(0,0)
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
	if !make_edge_state:
		set_unactivated()


func _draw():
	if hovered:
		draw_circle(Vector2(), idle_radius, colors.hovered_border_color)
		draw_circle(Vector2(), idle_radius-idle_border_width, base_color)
	else:
		draw_circle(Vector2(), idle_radius, idle_border_color)
		draw_circle(Vector2(), idle_radius-idle_border_width, base_color)
	if selected:
		draw_circle_custom(idle_radius + 2, colors.white, 2)

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
