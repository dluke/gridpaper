extends Node2D

class_name NoteGrid

signal selected

# generic behaviour
var grabbed: bool = 0
var focused: bool = 0

# 
export var gridcolor = Color(0,0,0)
export var extents = Vector2(1,1) setget set_extents
var gridsize: Vector2 = 2*extents + Vector2(1,1)

export var size = 80
export var tick_size_factor = Vector2(0.2,0.2)
var tick_size: Vector2
var square_size = Vector2(size, size)
var grid = []  # 2d tile grid
var boardsize: Vector2 = gridsize * square_size

#
var marker_idx: Vector2 = extents
var last_marker_idx: Vector2


var nn_basis = [Vector2(1,0), Vector2(1,1), Vector2(0,1), Vector2(-1,1), Vector2(-1,0), 
			Vector2(-1,1), Vector2(0,-1), Vector2(1,-1)]


# dep
var default_extension = Vector2(3,3)


func set_size(size_):
	size = size_
	square_size = Vector2(size, size)
	tick_size = tick_size_factor * square_size
	boardsize = size * gridsize

func set_extents(extents_):
	extents = extents_
	gridsize = 2*extents + Vector2(1,1)
	boardsize = size * gridsize

func _ready():
	set_size(size)
	set_extents(extents)

	marker_idx = extents
	last_marker_idx = marker_idx
	grid = _new_grid(gridsize)

	# need to re-center this object because it is on a separate canvas layer
	# center_view()
	
	$CharacterMarker.set_idx(marker_idx)

	# Sig
	var signpost = $SignPostGlyph
	signpost.center_at(get_pos(extents) + signpost.uv*square_size)



func center_view():
	position = get_viewport_rect().size/2

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
	var new_extents = extents + size
	var new_grid = _new_grid(2*new_extents + Vector2(1,1))
	# copy tiles over
	var transform = new_extents - extents
	for i in range(gridsize.x):
		for j in range(gridsize.y):
			var t_idx = Vector2(i,j) + transform
			new_grid[t_idx.x][t_idx.y] = grid[i][j]
	grid = new_grid
	marker_idx += size
	set_extents(new_extents)
	if has_node('CursorMarker'):
		$CursorMarker.idx += transform
	update()

func move_marker(target):
	marker_idx = target
	assert(check_idx(target))
	if has_node('CharacterMarker'):
		$CharacterMarker.set_idx(target)
		

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

func get_pos(idx) -> Vector2:
	return idx*square_size - boardsize/2

func get_idx(pos) -> Vector2:
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
	# for i in range(gridsize.x+1):
	# 	var ix = (i-extents.x-0.5)*size
	# 	draw_line(Vector2(ix, -y_edge), Vector2(ix, y_edge), gridcolor, 1)
		
	# for i in range(gridsize.y+1):
	# 	var iy = (i-extents.y-0.5)*size
	# 	draw_line(Vector2(-x_edge, iy), Vector2(x_edge, iy), gridcolor, 1)
	var vpr = get_viewport_rect()
	var lpos = to_local(vpr.position)
	var xpos = to_local(vpr.end)
	var start = (lpos/square_size).floor() - Vector2(1,1)
	var end = (xpos/square_size).ceil() + Vector2(1,1)

	for i in range(start.x, end.x+1):
		var ix = (i-0.5)*size
		for j in range(start.y, end.y+1):
			var iy = (j-0.5)*size
			_draw_cross(Vector2(ix, iy), tick_size)

func _draw_cross(xy:Vector2, tick_size: Vector2):
	var x_m = Vector2(-tick_size.x/2,0)
	var x_p = Vector2(tick_size.x/2,0)
	var y_m = Vector2(0, -tick_size.y/2)
	var y_p = Vector2(0, tick_size.y/2)

	draw_line(xy+x_m, xy+x_p, gridcolor, 1)
	draw_line(xy+y_m, xy+y_p, gridcolor, 1)

func _input_event(event):
	if event is InputEventMouseButton and event.button == BUTTON_LEFT:
		emit_signal('selected', get(get_idx(event.position)))

func _unhandled_input(event):

	for action in ['ui_right', 'ui_left', 'ui_down', 'ui_up']:
		if event.is_action(action) and event.pressed:
			last_marker_idx = marker_idx
			move_marker(marker_idx + constants.Direction[action.trim_prefix('ui_')])



class TileObject:
	extends Node2D

	# TileObjects may create instances of GridNode
	var gridnode_factory = preload('res://GUI/GridNode.tscn')

	var tile
	var idx
	var visited = 0
	var upref
	var node 
	var description: String 

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
		var gnode = gridnode_factory.instance()
		var grect = upref.get_rect(idx)
		gnode.position = grect.position + grect.size/2
		var nodesize = (0.2 * grect.size).ceil()
		gnode.idle_radius = int(nodesize.x/2)
		gnode.ixy = idx
		node = gnode
		gnode.tile = self
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

