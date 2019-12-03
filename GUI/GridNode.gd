extends Control

class_name GridNode

"""
A graph node with 5 interactable components. The central node + possible 4 connections.
"""

# load texture svgimageulation routines
var svgimage =  preload('res://global/image.gd')

var node_texture = preload('res://GUI/icons/node_circle.svg')
var arrow_texture = preload('res://GUI/icons/node_arrow.svg')

# anticlockwise arrows 
var card_arrows: Array = svgimage.texture_cardinal_directions(arrow_texture)

# properties
var gsize = node_texture.get_size()
var arrowsize = arrow_texture.get_size()

# margins
var small_margin: int = 0.05 * gsize.x
var even_margin: int = (gsize.x - arrowsize.x)/2
var big_margin: int = gsize.x - small_margin - arrowsize.x

var m_block = [even_margin, big_margin, even_margin, small_margin]

enum Dir {CENTER = 4, UP = 1, LEFT = 3, DOWN = 7, RIGHT = 5}

class NineGridContainer:
	extends GridContainer
	var layout: Array

	func _init():
		columns = 3
		layout.resize(9)

# Called when the node enters the scene tree for the first time.
func _ready():
	# grid
	var grid = NineGridContainer.new()

	add_child(grid)
	# Margins
	for i in range(9):
		var box = MarginContainer.new()
		grid.layout[i] = box
		grid.add_child(box)
	# Center 
	var center_button = TextureButton.new()
	center_button.texture_normal = node_texture
	grid.layout[Dir.CENTER].add_child(center_button)
	# Arrows
	var layoutmap = [Dir.UP, Dir.LEFT, Dir.DOWN, Dir.RIGHT]
	for i in range(4):
		var arrow_button = TextureButton.new()
		arrow_button.texture_normal = card_arrows[i]
		var marginbox = grid.layout[layoutmap[i]]
		marginbox.add_child(arrow_button)
		margin_helper(marginbox, offset_array(m_block, -i))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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
