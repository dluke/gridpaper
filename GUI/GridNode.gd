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

enum Dir {RIGHT, DOWN, LEFT, UP, DOWN_LAYER, UP_LAYER}

# put this in global scope ...
var e_x = Vector2(1,0)
var e_y = Vector2(0,1)
var Direction = {'right':e_x, 'down':e_y, 'left':-e_x, 'up':-e_y}

var arrow_factory = preload('res://GUI/GridNode/Arrow.tscn')
var arrows: Array = []

# node colors
export var base_color = Color('d4d4d4')
var idle_border_color = Color('6f9dc5')
var idle_border_width: int = 3

# var node_texture = preload('res://GUI/icons/node_circle.svg')
var arrow_texture = preload('res://GUI/icons/node_arrow.svg')

# the distance from the center of the node to the center of the arrow
var arrow_offset = 50 + 15.20

export var max_radius: int = 32
export var idle_radius: int = 16
export var grid_rect_size = Vector2(50,50)
# 
# unique gridnode index 
var idx: int
# index in the grid
var ixy: Vector2

# generic behaviour
# really need to distinguish hovered and focused?
var hovered: bool = 0
var grabbed: bool = 0 
var moved: Vector2
const moved_threshold_squared: int = 25
var selected: bool = 0  # multiple nodes can be selected
export var grabbable: bool = 1

# mimick area2d 
var position: Vector2 setget set_position, get_position

var edges: Array # index

enum EdgeDir {RIGHT, UP, LEFT, DOWN}

func _init():
	edges.resize(6)

func set_position(position):
	rect_position = position

func get_position():
	return rect_position

func _ready():

	# setup mouse collision
	var input_box_size = Vector2(idle_radius, idle_radius)
	$InputControl.rect_min_size = input_box_size
	$InputControl.rect_position = -input_box_size/2
	# var c_circle =  $c_collider.shape_owner_get_shape(0,0)
	# c_circle.radius = max_radius


	# connect 
	$InputControl.connect("mouse_entered", self, "_on_mouse_entered")
	$InputControl.connect("mouse_exited", self, "_on_mouse_exited")
	$InputControl.connect("clicked", self, "_on_clicked")
	# $c_collider.connect("input_event", self, "_on_catch_input")

	$limit_collider.shape_owner_get_shape(0,0).extents = (grid_rect_size/2).ceil()
	$limit_collider.connect("mouse_exited_dir", self, "_on_limit_exited")

	# setup arrows
	if false: # tmp disable arrows
		var direction = Direction.values()
		arrows.resize(4)
		for i in range(4):
			var arrow = arrow_factory.instance()
			 # needs scaling
			arrow.position = arrow.node_offset * direction[i] 
			arrow.rotation += i*PI/2
			arrows[i] = arrow
			arrow.visible = false
			add_child(arrow)
			# collision
			arrow.connect("clicked", self, '_on_arrow_clicked', [arrow])

	_scale_with(idle_radius)

func _input(event):
	if event is InputEventMouseMotion and grabbed == true:
		rect_position += event.relative
		moved += event.relative

func _on_clicked(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			if grabbable:
				grab()
		elif !event.pressed:
			if moved.length_squared() < moved_threshold_squared:
				toggle_select()
			ungrab()

func _on_arrow_clicked(event, arrow):
	print('clicked arrow at ', arrow.position)

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

func _set_hovered():
	pass
	$c_sprite.visible = true
	$c_sprite.z_index = 1
	for arrow in arrows:
		arrow.visible = true

func _set_unhovered():
	pass
	$c_sprite.visible = false
	for arrow in arrows:
		arrow.visible = false
		
func _on_mouse_entered():
	hovered = 1
	_scale_with(max_radius)
	# _set_hovered()
	update()

func _on_mouse_exited():
	hovered = 0
	update()
	# _set_unhovered()
	# _scale_with(idle_radius)

# sprite hovered animation ...


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
