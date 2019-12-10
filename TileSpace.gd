extends Node2D

signal new_open_tile

var background_color = Color('#4d4d4d')

# Main references	
onready var graph = $SpaceGraph
onready var notegrid = find_node('NoteGrid')

var open_tile # reference to the node whose description we are displaying

# Called when the node enters the scene tree for the first time.
func _ready():

	# set background_color
	VisualServer.set_default_clear_color(background_color)

	#
	center_view()

	# Take processing away from SpaceGraph so we can implement it here
	graph.set_process(false)

	# add a gridnode at the origin 
	var origin_idx = notegrid.extents
	var newtile = notegrid.new_tile(origin_idx)
	newtile.visited = true
	newtile.description = 'My point of origin.'
	var origin_node = add_node_to_tile(newtile)

	#
	open_tile = newtile
	# print('emit signal ', 'new_open_node')

	# # add a forest tile
	# var ftile = ForestTile.new(newtile)
	# ftile.faded = 1
	# newtile.tile = ftile

func change_open_tile(oldtile, tile):
	open_tile = tile
	emit_signal('new_open_tile', oldtile, tile)


func add_node_to_tile(tile):
	var space_node = tile.add_gridnode()
	space_node.connect('node_release', self, '_on_node_release') 
	graph.add_node(space_node)
	return space_node

func _on_node_release(node):
	# snap to grid position else snap_back
	var ixy = notegrid.get_idx(node.position)
	var snapped = false
	if ixy != node.ixy:
		var tile = notegrid.get(ixy)
		if tile == null:
			snap_to(node, ixy)
			var new_tile = notegrid.new_tile(ixy)
			new_tile.node = node
			notegrid.get_
			snapped = true
		if tile != null:
			if tile.node == null:
				#1. there is a tile but it has no node
				snap_to(node, ixy)
				tile.node = node
			# if there is a tile and it has a node
				# pass
	if !snapped:
		# snap_back
		snap_to(node, node.ixy)

func snap_to(node, idx):
	var grect = notegrid.get_rect(idx)
	node.position = grect.position + grect.size/2
	node.ixy = idx

func _on_selected(tile):
	# display
	pass

func _process(delta):

	for action in ['ui_right', 'ui_left', 'ui_down', 'ui_up']:
		if Input.is_action_just_pressed(action):
			# 
			var step = constants.Direction[action.trim_prefix('ui_')]
			var last_tile = notegrid.get(notegrid.marker_idx)
			# if !notegrid.check_idx(notegrid.marker_idx + step):
				# !this moves the marker! 
				# notegrid.extend() 
			# is there a tileobject here?
			var t_idx = notegrid.marker_idx + step
			var oldtile = notegrid.get(t_idx)
			if oldtile == null:
				var newtile = notegrid.new_tile(t_idx)
				# set newtile background here
				# ...
				newtile.visited = true
				var newnode = newtile.add_gridnode()
				newnode.connect('node_release', self, '_on_node_release') 
				change_open_tile(last_tile, newtile)

				graph.add_node(newnode)
				graph.add_edge(last_tile.node, newnode)
			else:
				# Already a tileojbect here
				if oldtile.node != null:
					# update connections
					graph.add_edge(last_tile.node, oldtile.node)
					change_open_tile(last_tile, oldtile)
				else:
					print("Warning: Found an old TileOjbect which has no node")

func center_view():
	position = get_viewport_rect().size/2
	# need to re-center this object because it is on a separate canvas layer
	notegrid.center_view()
