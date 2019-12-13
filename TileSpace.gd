extends Node2D

signal new_open_tile

var background_color = Color('#4d4d4d')

# Main references	
onready var graph = $SpaceGraph
onready var notegrid = find_node('NoteGrid')
onready var gsize = float(notegrid.size)

var open_tile # reference to the node whose description we are displaying

# node connection algorithm

export var node_box_size: int
export var edge_offset: int

enum Dir {RIGHT, DOWN, LEFT, UP, DOWN_LAYER, UP_LAYER}
var Dir_opp = [Dir.LEFT, Dir.UP, Dir.RIGHT, Dir.DOWN, Dir.UP_LAYER, Dir.DOWN_LAYER]
var e_x = constants.e_x
var e_y = constants.e_y
var Dir_basis = [e_x, e_y, -e_x, -e_y]
var diag = {}
var Str_map = {'right':0, 'down':1, 'left':2, 'up':3}

# temporary data, keys will be [Vector2(x,y), Dir.RIGHT/Dir.DOWN]
var _grid_edge  = {}
var _subgrid_edge = {}

onready var sub_origin = gsize/2 * e_x
onready var sub_x = Vector2(1,-1) * gsize/2
onready var sub_y = Vector2(1,1) * gsize/2
var sub_h = Vector2(1,1)
var sub_v = Vector2(-1,1)

onready var t_subgrid_xy = Transform2D(gsize/2 * Vector2(1,-1), gsize/2 * Vector2(1,1), Vector2(gsize/2,0))
onready var t_subgrid_idx = Transform2D(1/gsize * Vector2(1,1), 1/gsize * Vector2(-1,1), Vector2(-0.5,-0.5))

# grid idx to subgrid xy
func gidx_to_sub_xy(ixy, dir):
	return gsize*ixy + gsize/2 * Dir_basis[dir]

func to_sub_xy(pos, dir):
	return pos + gsize/2 * Dir_basis[dir]

# Called when the node enters the scene tree for the first time.

func _ready():

	# set background_color
	VisualServer.set_default_clear_color(background_color)

	# constant parameters
	gsize = notegrid.size
	node_box_size = int(5*gsize/16)
	edge_offset = int(gsize/20) 

	#
	center_view()

	# Take processing away from SpaceGraph so we can implement it here
	graph.set_process(false)
	graph.set_process_unhandled_input(false)


	# add a gridnode at the origin 
	var origin_idx = notegrid.extents
	var newtile = notegrid.new_tile(origin_idx)
	newtile.visited = true
	newtile.description = 'My point of origin.'
	var origin_node = add_node_to_tile(newtile)

	#
	open_tile = newtile

	# # add a forest tile
	# var ftile = ForestTile.new(newtile)
	# ftile.faded = 1
	# newtile.tile = ftile

# algorithm 
func compute_polyline(edge, tilespace): 
	# var nodes = tilespace.graph.nodes
	var grid_edge = tilespace._grid_edge
	var subgrid_edge = tilespace._subgrid_edge
	var p_from = edge.from.position
	var p_to = edge.to.position
	# 
	var subidx_p = t_subgrid_idx.xform(to_sub_xy(p_from, edge.direction_from))
	var subidx_t = t_subgrid_idx.xform(to_sub_xy(p_to, edge.direction_to))

	# l1 distance on the subgrid
	var sub_distance = l1_norm(subidx_p - subidx_t)
	if sub_distance == 0:
		# bookkeeping
		grid_edge[subidx_p] = 1 # todo
		return [p_from, p_to]
	# 
	var p_line = [p_from, p_from + node_box_size * Dir_basis[edge.direction_from]]
	var r_line = [p_to, p_to + node_box_size * Dir_basis[edge.direction_to]]
	if sub_distance <= 1:
		# bookkeeping
		grid_edge[subidx_t] = 1 # todo
		return append_reversed(p_line, r_line)

	# sub_distance > 1
	# pathing algorithm on subgrid
	# var pathline = subidx_t - subidx_p
	var path = _pathing(subidx_p, subidx_t)
	print(path)


	# bookkeeping
	return append_reversed(p_line, r_line)

# return the full path on the subgrid
# todo test cases
func _pathing(sub_p, sub_t):
	var path = [sub_p]
	var pathline = sub_t-sub_p
	var d = l1_norm(pathline)
	var remainder
	# set up heuristics
	var heuristic = []
	if pathline.x != 0:
		heuristic.append(sign(pathline.x)*e_x)
	if pathline.y != 0:
		heuristic.append(sign(pathline.y)*e_y)
	var shortcut = []
	var is_horizontal: bool
	if heuristic.size() > 1:
		shortcut = [heuristic[0]+heuristic[1]]
		is_horizontal = sign(shortcut[0].x * shortcut[0].y) == 1

	print('heuristics ', heuristic)
	print('shortcut ', shortcut)
	print('start stop ', sub_p, sub_t)
	print('is_horizontal ', is_horizontal)
	var maxiter = 10
	var used_shortcut: bool
	for i in range(maxiter):
		if d < 1:
			break
		#	
		used_shortcut = false
		if !shortcut.empty() && pathline.x != 0 && pathline.y != 0:
			var permit = false # permit shortcut
			if is_horizontal:
				permit = sgn_h(path[-1]) == 0
			else:
				permit = sgn_v(path[-1]) == 0
			#	
			print('permit shortcut ', permit)
			if permit:
				remainder = pathline - shortcut[0]
				print ('remainder ', remainder)
				if l1_norm(remainder) < d:
					pathline = remainder
					path.push_back(path[-1]+shortcut[0])
					used_shortcut = true
					_prune(heuristic, pathline)
		if !used_shortcut:
			pathline -= heuristic[0]
			path.push_back(path[-1]+heuristic[0])
			_prune(heuristic, pathline)
			
		d = l1_norm(pathline)
		# print (path[-1])
		print ('p ', path, pathline)

	assert(path[-1] == sub_t)
	return path

static func _prune(heuristic, pathline):
	if heuristic.size()>1:
		if pathline.x == 0:
			heuristic.remove(0)
		elif pathline.y == 0:
			heuristic.remove(1)

func joined(a, b):
	var norm = l1_norm(b-a)
	if (norm <= 1):
		return true
	else:
		if (b-a) == sub_v:
			return sgn_v(a) == 0
		elif (b-a) == sub_h:
			return sgn_h(a) == 0


func add_graph_node():
	pass

func add_graph_edge(from, d_from, to, d_to):
	var edge = graph.add_edge(from, d_from, to, d_to)
	edge.p_line = compute_polyline(edge, self)

func delete_graph_edge(from, to):
	pass

func delete_node(node):
	pass

func move_node(node, ixy):
	pass


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
			var new_tile = notegrid.new_tile(ixy)
			new_tile.node = node
			snap_to(node, ixy)
			snapped = true
		if tile != null:
			if tile.node == null:
				#1. there is a tile but it has no node
				tile.node = node
				snap_to(node, ixy)
				snapped = true
			# if there is a tile and it has a node
				# pass
	if !snapped:
		snap_to(node, node.ixy)

func snap_to(node, idx):
	var prev_tile = notegrid.get(node.ixy)
	var grect = notegrid.get_rect(idx)
	node.position = grect.position + grect.size/2
	if node.ixy == idx:
		return # snap back
	#
	node.ixy = idx
	if node == graph.selected_node:
		# update marker position
		notegrid.move_marker(idx)
		change_open_tile(prev_tile, notegrid.get(idx))

	prev_tile.node = null

	for edge_idx in node.edges:
		if edge_idx != null:
			var edge = graph.edges[edge_idx]
			print("recompute polyline")
			edge.p_line = compute_polyline(edge, self)
			edge.update()
	update()

func _on_selected(tile):
	# display
	pass

func _unhandled_input(event):

	for action in ['ui_right', 'ui_left', 'ui_down', 'ui_up']:
		if event.is_action(action) and event.pressed:
			# 
			var dir = Str_map[action.trim_prefix('ui_')]
			var step = Dir_basis[dir]
			var last_tile = notegrid.get(notegrid.last_marker_idx)
			# if !notegrid.check_idx(notegrid.marker_idx + step):
				# !this moves the marker! 
				# notegrid.extend() 
			# is there a tileobject here?
			var t_idx = notegrid.marker_idx 
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
				add_graph_edge(last_tile.node, dir, newnode, Dir_opp[dir])
			else:
				# Already a tileojbect here
				if oldtile.node != null:
					# update connections
					add_graph_edge(last_tile.node, dir, oldtile.node, Dir_opp[dir])
					change_open_tile(last_tile, oldtile)
				else:
					var newnode = add_node_to_tile(oldtile)
					add_graph_edge(last_tile.node, dir, newnode, Dir_opp[dir])
			get_tree().set_input_as_handled()

func center_view():
	position = get_viewport_rect().size/2
	# need to re-center this object because it is on a separate canvas layer
	notegrid.center_view()


# utils

func l1_norm(v):
	return abs(v.x) + abs(v.y)

func sgn_h(pt):
	return (int(pt.x + pt.y) + 1) % 2

func sgn_v(pt):
	return int(pt.x + pt.y) % 2

func append_reversed(p_line, r_line):
	for i in range(1, r_line.size()+1):
		p_line.push_back(r_line[-i])
	return p_line
