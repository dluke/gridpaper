extends Node2D

class_name NoteGrid


# put this in global scope ...
var e_x = Vector2(1,0)
var e_y = Vector2(0,1)
var Direction = {'right':e_x, 'down':e_y, 'left':-e_x, 'up':-e_y}

var One = Vector2(1,1)


# generic behaviour
var grabbed: bool = 0
var focused: bool = 0

# 
export var gridcolor = Color(0,0,0)
export var extents = Vector2(1,1) setget set_extents
var gridsize: Vector2 = 2*extents + Vector2(1,1)

export var size = 80
var square_size = Vector2(size, size)
var grid = []
var boardsize: Vector2 = gridsize * square_size

#
var marker_idx: Vector2 = extents
var last_marker_idx = marker_idx

var default_extension = Vector2(5,5)

var nn_basis = [Vector2(1,0), Vector2(1,1), Vector2(0,1), Vector2(-1,1), Vector2(-1,0), 
			Vector2(-1,1), Vector2(0,-1), Vector2(1,-1)]

func set_extents(extents_):
	extents = extents_
	gridsize = 2*extents + Vector2(1,1)
	boardsize = size * gridsize

func _ready():
	grid = _new_grid(gridsize)

func get(idx):
	return grid[idx.x][idx.y]

func _new_grid(gridsize) -> Array:
	#	 construct an array of arrays
	var new_grid = []
	for i in range(gridsize.x):
		var col = []
		col.resize(gridsize.y)
		new_grid.append(col)
	return new_grid

func extend(size=default_extension):
	print ('extending grid')
	var extension = default_extension
	var new_extents = extents + extension
	var new_grid = _new_grid(2*new_extents + Vector2(1,1))
	# copy tiles over
	var transform = new_extents - extents
	for i in range(gridsize.x):
		for j in range(gridsize.y):
			var t_idx = Vector2(i,j) + transform
			new_grid[t_idx.x][t_idx.y] = grid[i][j]
	grid = new_grid
	marker_idx += extension
	set_extents(new_extents)
	if has_node('CursorMarker'):
		$CursorMarker.idx += transform
	update()

func move_marker(move):
	marker_idx += move
	if !check_idx(marker_idx):
		# marker is now outside the grid, so make it bigger
		extend()

func set_focused():
	# todo
	focused = true

func new_tile(tile_idx):
	var tile_object = TileObject.new(tile_idx, self)
	_insert_tile(tile_object)
	return tile_object

func get_boardsize():
	return size * gridsize

func _insert_tile(tileobj):
	var tile_idx = tileobj.idx
	grid[tile_idx.x][tile_idx.y] = tileobj
	add_child(tileobj)

### grid behaviour

func check_idx(idx):
	# check that the index is in the graph
	return idx.x >= 0 && idx.y >= 0 && idx.x < gridsize.x && idx.y < gridsize.y
	# return idx.x <= extents.x && idx.x >= -extents.y && idx.y <= extents.y && idx.y >= -extents.y

func get_pos(idx):
	# return (idx-extents+One)*square_size - square_size/2
	return idx*square_size - boardsize/2

func get_idx(pos):
	# return ((pos+square_size/2)/square_size).floor() + extents-One
	return ((pos+boardsize/2)/square_size).floor()

func get_rect(idx):
	return Rect2(get_pos(idx), square_size)

func get_neighbours(idx) -> Array:
	var neighbours = []
	for nv in nn_basis:
		var candidate = idx + nv
		if check_idx(candidate):
			neighbours.push_back(candidate)
	return neighbours

func _draw():
	assert(size > 0)
	# we might like to draw tile by tile 

	var y_edge = (extents.y + 0.5)*size
	var x_edge = (extents.x + 0.5)*size
	for i in range(gridsize.x+1):
		var ix = (i-extents.x-0.5)*size
		draw_line(Vector2(ix, -y_edge), Vector2(ix, y_edge), gridcolor, 1)
		
	for i in range(gridsize.y+1):
		var iy = (i-extents.y-0.5)*size
		draw_line(Vector2(-x_edge, iy), Vector2(x_edge, iy), gridcolor, 1)


func _process(delta):

	for action in ['ui_right', 'ui_left', 'ui_down', 'ui_up']:
		if Input.is_action_just_pressed(action):
			last_marker_idx = marker_idx
			move_marker(Direction[action.trim_prefix('ui_')])

	if has_node('CharacterMarker'):
		$CharacterMarker.set_idx(marker_idx)


class TileObject:
	extends Node2D

	# TileObjects may create instances of GridNode
	var gridnode = preload('res://GUI/GridNode.tscn')

	var tile
	var idx
	var visited = 0
	var upref
	var node 

	func _init(i, upref_, tile_=null):
		idx = i
		upref = upref_
		if tile_ != null:
			tile = tile_

	func get_pos():
		return upref.get_pos(idx)

	func get_size():
		return upref.square_size

	func _ready():
		# add the drawable object
		if tile != null:
			add_child(tile)

	func add_gridnode():
		# put the node inside a panel box and center it 
		var gnode = gridnode.instance()
		var grect = upref.get_rect(idx)
		var center = grect.position + grect.size/2
		var nodesize = (0.2 * grect.size).ceil()
		gnode.idle_radius = int(nodesize.x/2)
		gnode.max_radius = int(0.25 * grect.size.x/2)
		gnode.position = center
		node = gnode
		return gnode


class Tile:
	extends Sprite 

	var upref # type inferred here ?

	# also a property of NoteGrid
	var background_color = Color('#4d4d4d')
	var background_lighter = background_color.lightened(0.3)

	var tilebkg: Color
	var bkg
	var passable = false
	var faded = 0

	func _init(tex, upref_):
		texture = tex
		upref = upref_
		#
		position = upref.get_pos() + Vector2(0,1)
		centered = false
		scale = (upref.get_size() - Vector2(1,1) )/ texture.get_size()
		#
		tilebkg = background_color

	func _ready():
		bkg = ColorRect.new()
		if faded:
			fade()
		else:
			bkg.color = tilebkg
		bkg.rect_size = texture.get_size()
		bkg.show_behind_parent = true
		add_child(bkg)

	func fade():
		# only makes sense if object is in scene
		faded = 1
		bkg.color = background_color
		self_modulate = background_lighter

class ForestTile:
	extends Tile 

	# converts to large raster texture
	var forest_texture = load('res://svg/two_pine-tree_nobkg.svg')
  
	func _init(upref).(forest_texture, upref):
		passable = false
		tilebkg = Color(0, 0.196078, 0.196078)

