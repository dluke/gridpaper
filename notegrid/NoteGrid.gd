extends Node2D

class_name NoteGrid

export var gridcolor = Color(0,0,0)
# offset relative to the viewport
export var gridsize = Vector2(11,11)

var background_color = Color('#4d4d4d')
var background_lighter = background_color.lightened(0.3)


# grabable members
var _grabbed: bool

export var size = 80
var square_size = Vector2(size, size)
var grid = []
var boardsize = size * gridsize


func _ready():
	#	 construct an array of arrays
	for i in range(gridsize.x):
		var col = []
		col.resize(gridsize.y)
		grid.append(col)

	# set the default offset so that the grid center is the center of the screen
	var viewrect = get_viewport_rect()
	center_at( (viewrect.position + viewrect.end)/2 )

	# set background_color
	VisualServer.set_default_clear_color(background_color)

	# add a forest tile
	var newtile = ForestTile.new(Vector2(1,1), self)
	newtile.faded = 1
	grid[1][1] = newtile
	add_child(TileObject.new(newtile))

	var origin = TileObject.new()
	origin.visited = 1
	grid[0][0] = origin


func center_at(pos):
	position = pos - boardsize/2

func get_pos(grididx):
	# get the position of the grididx
	return size * grididx

func get_rect(grididx):
	return Rect2(get_pos(grididx), square_size)

func get_grididx(pos):
	var fidx = ( pos ) / size
	return fidx.floor()
	
func _draw():
	assert(size > 0)
	# var viewrect = get_viewport_rect()
	# gridsize = viewrect.size / size
	
	for i in range(gridsize.x+1):
		draw_line(Vector2(i*size, 0), Vector2(i*size, gridsize.y*size), gridcolor, 1)
		
	for i in range(gridsize.y+1):
		draw_line( Vector2(0, i*size), Vector2(gridsize.x*size, i*size), gridcolor, 1)

	# # center marker
	# var white = Color(255,255,255)
	# var centeridx = Vector2(int(gridsize.x/2), int(gridsize.y/2))
	# var cpos = get_pos(centeridx)
	# var poly = [cpos, Vector2(cpos.x,cpos.y+size), 
	# 		Vector2(cpos.x+size,cpos.y+size), Vector2(cpos.x+size,cpos.y)]
	# var colors = [white, white, white, white]
	# draw_polygon(poly, colors)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			_grabbed = 1 
		elif !event.pressed:
			_grabbed = 0 

	if event is InputEventMouseMotion and _grabbed == true:
		position += event.relative
		#
		update()

	var marker = get_node('CharacterMarker')	
	if Input.is_action_just_pressed("ui_right"):
		if (marker.grididx.x + 1 < gridsize.x):
			marker.grididx.x += 1
			marker.update()
	if Input.is_action_just_pressed("ui_left"):
		if (marker.grididx.x - 1 >= 0):
			marker.grididx.x += -1
			marker.update()
	if Input.is_action_just_pressed("ui_down"):
		if (marker.grididx.y + 1 < gridsize.y):
			marker.grididx.y += 1
			marker.update()
	if Input.is_action_just_pressed("ui_up"):
		if (marker.grididx.y -1 >= 0):
			marker.grididx.y += -1
			marker.update()



func _process(delta):
	pass


# dep this for GridNode
class PassNode:
	extends Node2D

	# use drawing functions
	var size

	# colors
	var outer = Color('#d39090')
	var inner = Color('#ffffff')

	func _init(_size):
		size = _size

	func _draw():
		pass
		# ..
		
class TileObject:
	extends Node2D

	var tile
	var visited = 0

	func _init(_tile=null):
		tile = _tile

	func _ready():
		# add the drawable object
		if tile != null:
			add_child(tile)

class Tile:
	extends Sprite 

	var upref # type inferred here ?

	var tilebkg: Color
	var bkg
	var idx: Vector2
	var passable = false
	var faded = 0

	func _init(i, tex, uref):
		idx = i
		texture = tex
		upref = uref
		#
		position = upref.get_pos(idx) + Vector2(0,1)
		centered = false
		scale = (upref.square_size - Vector2(1,1) )/ texture.get_size()
		#
		tilebkg = upref.background_color

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
		bkg.color = upref.background_color
		self_modulate = upref.background_lighter

class ForestTile:
	extends Tile 

	# converts to large raster texture
	var forest_texture = load('res://svg/two_pine-tree_nobkg.svg')
  
	func _init(i, upref).(i, forest_texture, upref):
		passable = false
		tilebkg = Color(0, 0.196078, 0.196078)

