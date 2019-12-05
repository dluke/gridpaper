extends Control

# class_name oldGridNode

# A graph node with 5 interactable components. The central node + possible 4 connections.

# load texture svgimage manipulation routines
var svgimage =  preload('res://global/image.gd')

var node_texture = preload('res://GUI/icons/node_circle.svg')
var arrow_texture = preload('res://GUI/icons/node_arrow.svg')

# anticlockwise arrows 
var card_arrows: Array = svgimage.texture_cardinal_directions(arrow_texture)

# properties
# target size of one grid element
export var gsize: Vector2 = node_texture.get_size()
var arrowsize = arrow_texture.get_size()


# margins
var small_margin: int = 0.05 * gsize.x
var even_margin: int = (gsize.x - arrowsize.x)/2
var big_margin: int = gsize.x - small_margin - arrowsize.x

var m_block = [even_margin, big_margin, even_margin, small_margin]

enum Dir {CENTER = 4, UP = 1, LEFT = 3, DOWN = 7, RIGHT = 5}

# node references
var center_button
var grid
var layoutmap = [Dir.UP, Dir.LEFT, Dir.DOWN, Dir.RIGHT]

class NineGridContainer:
	extends GridContainer
	var layout: Array

	func _init():
		columns = 3
		layout.resize(9)

func _new_texture_button():
	var tbutton = TextureButton.new()
	tbutton.expand = true
	tbutton.stretch_mode = 0
	return tbutton

	"""
	What if this object was part of a container which sets its rect_size
	resize should be called? So override set_rect_size / set_rect_min_size ?
	"""
func resize(size):
	# starting with the grid size, set margins
	gsize = (size/3).floor()
	var asize_f = arrow_texture.get_size()/node_texture.get_size()
	arrowsize = asize_f * gsize
	#
	small_margin = int(0.05 * gsize.x)
	even_margin = (gsize.x - arrowsize.x)/2
	big_margin = gsize.x - small_margin - arrowsize.x
	m_block = [even_margin, big_margin, even_margin, small_margin]
	# grid.queue_sort()

	# we set rect_min_size and let TextureButton scale the texture 
	center_button.rect_min_size = gsize
	for i in range(4):
		var ith_texture = card_arrows[i]
		var marginbox = grid.layout[layoutmap[i]]
		marginbox.get_child(0).rect_min_size = arrowsize
		margin_helper(marginbox, offset_array(m_block, -i))

	# Called when the node enters the scene tree for the first time.

func _init():
	pass

func _ready():

	# grid
	grid = NineGridContainer.new()
	add_child(grid)

	# Margins
	for i in range(9):
		var box = MarginContainer.new()
		grid.layout[i] = box
		grid.add_child(box)
	# Center 
	center_button = _new_texture_button()
	center_button.texture_normal = node_texture
	grid.layout[Dir.CENTER].add_child(center_button)

	# Arrows
	for i in range(4):
		var arrow_button = _new_texture_button()
		var ith_texture = card_arrows[i]
		arrow_button.texture_normal = ith_texture
		var marginbox = grid.layout[layoutmap[i]]
		marginbox.add_child(arrow_button)

	# later set expandable
	center_button.expand = true
	for i in range(4):
		grid.layout[layoutmap[i]].get_child(0).expand = true

	var sz = 150
	resize(Vector2(sz,sz))


static func offset_array(arr, offset):
	offset = wrapi(offset, 0, arr.size())
	if offset == 0:
		return arr
	var arr_ = Array() 
	arr_.resize(arr.size())
	for i in range(arr.size()):
		arr_[i] = arr[wrapi(i+offset, 0, arr.size())]
	return arr_

#
static func margin_helper(container, block):
	container.set("custom_constants/margin_right", block[0])
	container.set("custom_constants/margin_top", block[1])
	container.set("custom_constants/margin_left", block[2])
	container.set("custom_constants/margin_bottom", block[3])

# try stretching

class SpriteTextureButton:
	extends MarginContainer

	# In place of a raw texture like TextureRect
	var sprite: Sprite
	# for collision/input
	var area: Area2D

	func _ready():
		area = Area2D.new()


	func set_sprite(sprite_):
		sprite = sprite_
		sprite.offset.x = get("custom_constants/margin_right")
		sprite.offset.y = get("custom_constants/margin_top")

	func set_size(value):
		var inner_size = Vector2()
		inner_size.x = rect_size.x - get("custom_constants/margin_right") - get("custom_constants/margin_left")
		inner_size.y = rect_size.y - get("custom_constants/margin_top") - get("custom_constants/margin_bottom")
		sprite.scale = inner_size/sprite.texture.get_size()
		# area = sprite.
