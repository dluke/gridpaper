extends Node2D

class_name GridNode

"""
 components:
2 types of animated sprites, 5 sprites total
5 distinct Areas which respond to input
"""


# tmp
var red = Color(1,0,0)
var white = Color(1,1,1)

# node colors
export var base_color = Color('d4d4d4')
var idle_border_color = Color('6f9dc5')
var idle_border_width: int = 3

# make this global
enum Dir {RIGHT, UP, LEFT, DOWN}

# load texture svgimage manipulation routines
var svgimage =  preload('res://global/image.gd')

# var node_texture = preload('res://GUI/icons/node_circle.svg')
var arrow_texture = preload('res://GUI/icons/node_arrow.svg')

# anticlockwise arrows 
var card_arrows: Array = svgimage.texture_cardinal_directions(arrow_texture)
# the distance from the center of the node to the center of the arrow
var arrow_offset = 50 + 15.20

export var max_radius: int = 32
export var idle_radius: int = 16
export var grid_rect_size = Vector2(50,50)
# 
var idx: int

# really need to distinguish hovered and focused?
var hovered: bool = 0
var focused: bool = 0
var grabbed: bool = 0 
export var grabbable: bool = 0

var edges: Array # int

func _init():
	pass
	# tmp

func _ready():

	# setup mouse collision
	var c_circle =  $c_collider.shape_owner_get_shape(0,0)
	c_circle.radius = max_radius

	$limit_collider.shape_owner_get_shape(0,0).extents = (grid_rect_size/2).ceil()

	# connect 
	$c_collider.connect("mouse_entered", self, "_on_mouse_entered")
	$c_collider.connect("mouse_exited", self, "_on_mouse_exited")
	$c_collider.connect("clicked", self, "_on_clicked")

	$limit_collider.connect("mouse_exited_dir", self, "_on_limit_exited")

	_scale_with(idle_radius)

func _scale_with(radius):
	# scale sprite 
	idle_border_width = max(int(idle_radius/4),3)
	var c_scale = (2*radius)/$c_sprite.texture.get_size().x
	$c_sprite.scale = Vector2(c_scale,c_scale)

func _snap_back():
	$c_sprite.offset = Vector2(0,0)

func grab():
	grabbed = 1
	$c_sprite.self_modulate = red

func ungrab():
	grabbed = 0
	$c_sprite.self_modulate = white

func _draw():
	draw_circle(Vector2(), idle_radius, idle_border_color)
	draw_circle(Vector2(), idle_radius-idle_border_width, base_color)

func _unhandled_input(event):
	# print ('@gridnode. event ', event.as_text())
	if event is InputEventMouseMotion and grabbed == true:
		$c_sprite.offset += event.relative
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		ungrab()

func _on_limit_exited(dir):
	ungrab()
	_snap_back()

func _on_clicked(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			if grabbable:
				grab()


func _set_focused():
	focused = true
	$c_sprite.visible = true
	$c_sprite.z_index = 1

func _set_unfocused():
	focused = false
	$c_sprite.visible = false
		
func _on_mouse_entered():
	hovered = 1
	_scale_with(max_radius)
	_set_focused()

func _on_mouse_exited():
	hovered = 0
	_set_unfocused()
	# _scale_with(idle_radius)

# spirte hovered animation
