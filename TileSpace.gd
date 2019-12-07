extends Node2D

var background_color = Color('#4d4d4d')

# Main references	
onready var graph = $SpaceGraph
onready var notegrid = $NoteGrid

# put this in global scope ...
var e_x = Vector2(1,0)
var e_y = Vector2(0,1)
var Direction = {'right':e_x, 'down':e_y, 'left':-e_x, 'up':-e_y}

# Called when the node enters the scene tree for the first time.
func _ready():

	# set background_color
	VisualServer.set_default_clear_color(background_color)

	center_view()

	# 
	# don't process actions
	graph.set_process(false)

	# add a gridnode at the origin 
	var origin_idx = notegrid.extents
	var newtile = notegrid.new_tile(origin_idx)
	newtile.visited = true
	var space_node = newtile.add_gridnode()
	graph.add_node(space_node)

	# # add a forest tile
	# var ftile = ForestTile.new(newtile)
	# ftile.faded = 1
	# newtile.tile = ftile

func center_view():
	position = get_viewport_rect().size/2

func _on_selected(tile):
	# display
	pass

func _process(delta):

	for action in ['ui_right', 'ui_left', 'ui_down', 'ui_up']:
		if Input.is_action_just_pressed(action):
			# 
			var step = Direction[action.trim_prefix('ui_')]
			var last_tile = notegrid.get(notegrid.marker_idx)
			if !notegrid.check_idx(notegrid.marker_idx + step):
				# !this moves the marker! 
				notegrid.extend() 
			# is there a tileobject here?
			var t_idx = notegrid.marker_idx + step
			var oldtile = notegrid.get(t_idx)
			if oldtile == null:
				var newtile = notegrid.new_tile(t_idx)
				# set newtile background here
				# ...
				newtile.visited = true
				var newnode = newtile.add_gridnode()
				graph.add_node(newnode)
				graph.add_edge(last_tile.node, newnode)
			else:
				# Already a tileojbect here
				if oldtile.node != null:
					# update connections
					graph.add_edge(last_tile.node, oldtile.node)
				else:
					print("Warning: Found an old TileOjbect which has no node")

