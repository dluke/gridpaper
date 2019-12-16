extends Node2D

signal new_open_tile

var background_color = Color('#4d4d4d')

#
var grabbed: bool = 0
var moved = Vector2()
const moved_threshold_squared: int = 25
#
var drag_select = false
var drag_rect: Rect2
var drag_from: Vector2

const THRESHOLD = 0.0001
func is_float_zero(a):
	return abs(a) < THRESHOLD

# Main references	
onready var graph = $SpaceGraph
onready var notegrid = find_node('NoteGrid')
onready var gsize = float(notegrid.size)

var open_tile # reference to the node whose description we are displaying

# node connection algorithm

export var node_box_size: int
export var edge_offset: int
export var corner_offset: int

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

onready var t_subgrid_xy = Transform2D(gsize/2 * Vector2(1,-1), gsize/2 * Vector2(1,1), Vector2(gsize/2,0))
onready var t_subgrid_idx = Transform2D(1/gsize * Vector2(1,1), 1/gsize * Vector2(-1,1), Vector2(-0.5,-0.5))

#
var selected_nodes = []

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
	corner_offset = int(3*gsize/20)

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
	var subgrid_p = to_sub_xy(p_from, edge.direction_from)
	var subgrid_t = to_sub_xy(p_to, edge.direction_to)
	var subidx_p = t_subgrid_idx.xform(subgrid_p)
	var subidx_t = t_subgrid_idx.xform(subgrid_t)

	var grid_v = edge.to.ixy - edge.from.ixy
	var is_direct = false
	var is_cardinal = grid_v.x == 0 or grid_v.y == 0
	var is_blocked = false
	var is_facing = false
	if is_cardinal:
		is_facing = (edge.direction_from == Dir_opp[edge.direction_to]
						&& is_float_zero(cross(Dir_basis[edge.direction_from], grid_v))
						)
		if is_facing:
			var direct_path_blocked = _check_direct_path(edge.from, edge.to)
			is_blocked = direct_path_blocked.has(true)
			is_direct = (!direct_path_blocked.empty() and !is_blocked)

	# l1 distance on the subgrid
	var sub_distance = l1_norm(subidx_p - subidx_t)
	if sub_distance == 0 || is_direct:
		# bookkeeping
		grid_edge[subidx_p] = 1 # todo
		return [p_from, p_to]
	# 
	var p_line = [p_from, p_from + node_box_size * Dir_basis[edge.direction_from]]
	var r_line = [p_to, p_to + node_box_size * Dir_basis[edge.direction_to]]
	var grid_distance = l1_norm(edge.from.ixy - edge.to.ixy)
	if sub_distance <= 1 && grid_distance > 1:
		# bookkeeping
		grid_edge[subidx_t] = 1 # todo
		return append_reversed(p_line, r_line)

	#
	var path = _pathing(subidx_p, subidx_t)
	var path_pidx = 0
	var path_ridx = path.size()-1
	var next_subidx = path[path_pidx+1]
	var next_subidx_r = path[path_ridx-1]
	var next_subpt = t_subgrid_xy.xform(next_subidx)
	var next_subpt_r = t_subgrid_xy.xform(next_subidx_r)
	#
	var pathline: Vector2
	var pathline_r: Vector2
	var targetline: Vector2
	var sub_pathline: Vector2
	var uf: Vector2
	var ut: Vector2
	var this_subpt: Vector2
	var this_subpt_r: Vector2
	var this_subidx: Vector2
	var this_subidx_r: Vector2
	var npt: Vector2 # result
	var sgn
	var sgn_critical_pair: int
	var u_diag
	var u_diag_r
	var skip
	var proceed
	var subpt_f
	var subidx_f
	var subpt_r
	var subidx_r
	#
	var is_vertical: bool
	var maxiter = 10
	uf = Dir_basis[edge.direction_from]
	ut = Dir_basis[edge.direction_to]
	this_subpt = subgrid_p
	this_subpt_r = subgrid_t
	this_subidx = subidx_p
	this_subidx_r = subidx_t
	pathline = r_line[-1] - p_line[-1]
	pathline_r = p_line[-1] - r_line[-1]
	var last_subpt: Vector2
	var last_subpt_r: Vector2
	var proceed_condition = !is_blocked || !is_facing
	for i in range(2):
		# sgn_critical_pair = 0

		# forward
		proceed = (i > 0) && (abs(uf.angle_to(pathline)) < PI/8) && proceed_condition
		targetline = r_line[-1] - p_line[-1]
		# print('uf ', uf, ' pathline ', pathline)
		# print('proceed angle ', rad2deg(abs(uf.angle_to(pathline))) )
		if proceed:
			print('proceed pt')
			p_line.append(p_line[-1] + 2*corner_offset * uf)
		else:
			# sgn = cross_sgn(uf, pathline)
			sgn = cross_sgn(uf, pathline)
			if sgn == 0:
				sgn = cross_sgn(uf, targetline)
				if sgn == 0:
					sgn = cross_sgn(uf, next_subpt-this_subpt)
			#
			u_diag = uf.rotated(sgn*PI/4)
			skip = i == 0 && is_float_zero(cross(u_diag, next_subpt-this_subpt)) && grid_distance > 1
			subpt_f = next_subpt if skip else this_subpt
			subidx_f = next_subidx if skip else this_subidx
			npt = _next_pt(p_line[-1], u_diag, subidx_f, subpt_f, 1)
			p_line.append(npt)
			if skip:
				print('skip')
				path_pidx += 1

		# reverse
		# pathline = p_line[-1] - r_line[-1]
		# sub_pathline = next_subpt_r - this_subpt_r
		targetline = p_line[-1] - r_line[-1]
		proceed = i > 0 && abs(uf.angle_to(pathline_r)) < PI/8 && proceed_condition
		if proceed:
			p_line.append(p_line[-1] + 2*corner_offset * ut)
		else:
			sgn = cross_sgn(ut, pathline_r)
			if sgn == 0:
				sgn = cross_sgn(ut, targetline)
			u_diag_r = ut.rotated(sgn*PI/4)
			skip = i == 0 && is_float_zero(cross(u_diag_r, next_subpt_r-this_subpt_r)) && grid_distance > 1
			subpt_r = next_subpt_r if skip else this_subpt_r
			subidx_r = next_subidx_r if skip else this_subidx_r 
			npt = _next_pt(r_line[-1], u_diag_r, subidx_r, subpt_r, 1)
			r_line.append(npt)
			if skip:
				print('skip')
				path_ridx -= 1

		# forward
		is_vertical = int(l1_norm(subidx_f)) % 2 == 0
		uf = sign(u_diag.y)*e_y if is_vertical else sign(u_diag.x)*e_x
		#

		# reverse
		is_vertical = int(l1_norm(subidx_r)) % 2 == 0
		ut = sign(u_diag_r.y)*e_y if is_vertical else sign(u_diag_r.x)*e_x
		#

		if line_identity(p_line[-1], uf, r_line[-1], ut):
			print('break 1')
			break

		# forward
		path_pidx += 1
		npt = _project_ray_to_box(p_line[-1], uf)
		p_line.append(npt)


		if path_pidx > path_ridx:
			print('break 2, ', path_pidx, ' ', path_ridx)
			break
		#
		# reverse
		path_ridx -= 1
		npt = _project_ray_to_box(r_line[-1], ut)
		r_line.append(npt)

		if path_pidx > path_ridx:
			print('break 3, ', path_pidx, ' ', path_ridx)
			break

		# 
		last_subpt = this_subpt
		last_subpt_r = this_subpt_r
		# 
		# TODO respect /skip/ when choosing new subgrid targets 
		this_subpt = next_subpt
		this_subpt_r = next_subpt_r
		this_subidx = next_subidx
		this_subidx_r = next_subidx_r
		#
		next_subidx = path[path_pidx+1]
		next_subidx_r = path[path_ridx-1]
		next_subpt = t_subgrid_xy.xform(next_subidx)
		next_subpt_r = t_subgrid_xy.xform(next_subidx_r)
		#
		pathline = this_subpt - last_subpt
		pathline_r = this_subpt_r - last_subpt_r

	# bookkeeping
	return append_reversed(p_line, r_line)


func _next_pt(lpt, u_diag, subidx, subpt, track_sgn):
	var line: Array # pair
	if int(l1_norm(subidx)) % 2 == 0:
		line = _get_vertical_support(subpt, track_sgn)
	else:
		line = _get_horizontal_support(subpt, track_sgn)
	return _project_ray_to_line(lpt, u_diag, line[0], line[1])

func _get_vertical_support(subpt, sgn):
	return [Vector2(subpt.x-sgn*edge_offset, 0), e_y]

func _get_horizontal_support(subpt, sgn):
	return [Vector2(0, subpt.y-sgn*edge_offset), e_x]

func _project_ray_to_line(lpt, u, ref, v):
	# using Cramer's rule
	var div = v.x*u.y - v.y*u.x
	if div == 0:
		# critical case
		return lpt 
	var c = ref-lpt
	var b = (v.x*c.y - c.x*v.y)/div
	return lpt + b*u

func _project_ray_to_box(lpt, u):
	# assert u is either vertical or horizonatal
	var p = notegrid.get_pos(notegrid.get_idx(lpt)) + notegrid.square_size/2
	if u.x == 0: # vertical
		return Vector2(lpt.x,  p.y + sign(u.y)*(gsize/2 - corner_offset) )
	elif u.y == 0: # horizontal
		return Vector2(p.x + sign(u.x)*(gsize/2 - corner_offset), lpt.y)

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
			if permit:
				remainder = pathline - shortcut[0]
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
		# print ('p ', path, pathline)

	assert(path[-1] == sub_t)
	return path

static func _prune(heuristic, pathline):
	if heuristic.size()>1:
		if pathline.x == 0:
			heuristic.remove(0)
		elif pathline.y == 0:
			heuristic.remove(1)

func _check_direct_path(from, to):
	var direct_path_blocked = []
	var grid_v = to.ixy - from.ixy
	if grid_v.x == 0:
		var sgn = sign(grid_v.y)
		for dy in range(1, abs(grid_v.y)):
			var tile = notegrid.get(from.ixy + Vector2(0,sgn*dy))
			var empty = false
			if tile == null:
				empty = true
			elif tile.node == null:
				empty = true
			direct_path_blocked.push_back(!empty)
	elif grid_v.y == 0:
		var sgn = sign(grid_v.x)
		for dx in range(1, abs(grid_v.x)):
			var tile = notegrid.get(from.ixy + Vector2(sgn*dx,0))
			var empty = false
			if tile == null:
				empty = true
			elif tile.node == null:
				empty = true
			direct_path_blocked.push_back(!empty)
	return direct_path_blocked

### ###

func add_graph_node(node):
	graph.add_node(node)
	node.connect('node_release', self, '_on_node_release') 
	node.connect('node_select', self, '_on_node_select') 
	node.connect('node_hovered', self, '_on_node_hovered') 
	node.connect('node_unhovered', self, '_on_node_unhovered') 
	node.connect('node_moved_relative', self, '_on_node_moved_relative') 

func _on_node_hovered(node):
	if node.selected:
		for node in selected_nodes:
			node.set_hovered()

func _on_node_moved_relative(node, relative):
	if node.selected:
		for nd in selected_nodes:
			if nd == node:
				continue
			nd.position += relative

func _on_node_unhovered(node):
	for node in selected_nodes:
		node.set_unhovered()

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
	add_graph_node(space_node)
	return space_node

func _on_node_select(node):
	unselect_nodes()
	node.selected = true
	selected_nodes = [node]

func unselect_nodes():
	for nd in selected_nodes:
		nd.selected = false
		nd.update()
	selected_nodes = []

func _on_node_release(node):
	if node.selected:
		for node in selected_nodes:
			node.tile.node = null
			node.tile = null
		for node in selected_nodes:
			_release_node(node)
		update_edges(selected_nodes)
	else:
		node.tile.node = null
		node.tile = null
		_release_node(node)
		update_edges([node])

func _release_node(node):
	# snap to grid position else snap_back
	var ixy = notegrid.get_idx(node.position)
	var snapped = false
	if ixy != node.ixy:
		var tile = notegrid.get(ixy)
		if tile == null:
			var new_tile = notegrid.new_tile(ixy)
			new_tile.node = node
			node.tile = new_tile
			snap_to(node, ixy)
			snapped = true
		elif tile != null:
			if tile.node == null:
				#1. there is a tile but it has no node
				tile.node = node
				node.tile = tile
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
	if node == graph.head_node:
		# update marker position
		notegrid.move_marker(idx)
		change_open_tile(prev_tile, notegrid.get(idx))
	update()

func update_edges(nodes):	
	for node in nodes:
		# TODO this will recompute edges twice
		for edge_idx in node.edges:
			if edge_idx != null:
				var edge = graph.edges[edge_idx]
				# TODO cannot recompute edges until all nodes are released
				print("recompute polyline")
				edge.p_line = compute_polyline(edge, self)
				edge.update()

func _on_selected(tile):
	# display
	pass

func _start_drag(mpos):	
	drag_select = true
	drag_from = mpos
	unselect_nodes()

func _release_drag():	
	drag_select = false
	update()

func _update_drag(mpos):
	drag_rect = make_rectangle(drag_from, mpos)
	unselect_nodes()
	for node in graph.nodes:
		if drag_rect.has_point(node.position):
			node.selected = true
			selected_nodes.push_back(node)
			node.update()

	update()

static func make_rectangle(p,q):
	var min_x = min(p.x, q.x)
	var max_x = max(p.x, q.x)
	var min_y = min(p.y, q.y)
	var max_y = max(p.y, q.y)
	return Rect2(min_x, min_y, max_x-min_x, max_y-min_y)

func select_tile(tile_idx):
	var tile = notegrid.get(tile_idx)
	if tile != null:
		#
		if tile.node != null:
			notegrid.move_marker(tile_idx)
			graph.head_node = tile.node

func _draw():
	if drag_select:
		draw_rect(drag_rect, colors.white, false)

func _unhandled_input(event):

	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			grabbed = 1 
		else:
			if moved.length_squared() < moved_threshold_squared:
				# select tile with node on it
				var idx = notegrid.get_idx(notegrid.to_local(event.position))
				select_tile(idx)
			grabbed = 0 
			moved = Vector2()

	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if event.pressed:
			_start_drag(to_local(event.position))
		else:
			_release_drag()

	if event is InputEventMouseMotion: 
		if grabbed == true:
			position += event.relative
			find_node('NoteGrid').position += event.relative
			moved += event.relative
			update()
			get_tree().set_input_as_handled()
		if drag_select == true:
			_update_drag(to_local(event.position))

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
				change_open_tile(last_tile, newtile)

				add_graph_node(newnode)
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

static func line_identity(ref_u, u, ref_v, v):
	# is second condition sufficient?
	return u.abs() == v.abs() and (ref_v - ref_u).normalized().abs() == u.abs()

static func l1_norm(v):
	return abs(v.x) + abs(v.y)

static func sgn_h(pt):
	return (int(pt.x + pt.y) + 1) % 2

static func sgn_v(pt):
	return int(pt.x + pt.y) % 2

static func cross(v, u):
	return (v.x*u.y - v.y*u.x)

static func cross_sgn(v, u):
	return sign(v.x*u.y - v.y*u.x)


static func append_reversed(p_line, r_line):
	for i in range(1, r_line.size()+1):
		p_line.push_back(r_line[-i])
	return p_line
