extends Node2D

signal new_edge

var gridnode = preload('res://GUI/GridNode.tscn')

class_name SpaceGraph

"""
A Graph and embedding in 2d grid. 

Should interact with NoteGrid (if that is child?)

# nodes draw themselves, SpaceGraph draws edges
"""

var enable_cardinal_add_nodes = true
var make_edge_state = false
var make_edge_from: GridNode
var make_edge_from_direction: int

enum Dir {RIGHT, DOWN, LEFT, UP, DOWN_LAYER, UP_LAYER}
var Dir_opp = [Dir.LEFT, Dir.UP, Dir.RIGHT, Dir.DOWN, Dir.UP_LAYER, Dir.DOWN_LAYER]

var Str_map = {'right':0, 'down':1, 'left':2, 'up':3}
const e_x = Vector2(1,0)
const e_y = Vector2(0,1)
var Dir_basis = [e_x, e_y, -e_x, -e_y]

var nodes: Array = []
var edges: Array = []
# dictionary of arrays of references to nodes
var levels: Dictionary = {}

# by selected node is the last to be added 
var head_node 

# variables for default spacing when adding new nodes outside of grid
var default_grid_spacing = 100

func new_level(n):
	levels[n] = []

func get_level(n):
	return levels[n]

func _ready():
	new_level(0)

func add_edge(node_i, d_from, node_j, d_to):
	var edge = Edge.new(node_i, d_from, node_j, d_to)
	edge.idx = edges.size()
	edges.append(edge)
	node_i.add_edge(d_from, edge)
	node_j.add_edge(d_to, edge)
	add_child(edge)
	return edge

func create_node():
	var newnode = gridnode.instance()
	newnode.connect('break_edge', self, '_on_break_edge')
	newnode.connect('node_make_edge', self, '_on_node_make_edge')
	newnode.connect('node_grabbed', self, '_on_node_grabbed')
	return newnode

func add_node(node):
	node.idx = nodes.size()
	nodes.append(node)
	levels[node.z_level].append(node)
	add_child(node)
	head_node = node
	return node.idx
	
func delete_node(node):
	# O(n) operation since we update indices
	nodes.remove(node.idx)
	for i in range(node.idx, nodes.size()):
		nodes[i].idx -= 1
	levels[node.z_level].remove(node)
	remove_child(node)		
	node.queue_free()

func _on_node_grabbed(node):
	node.position = to_local(get_viewport().get_mouse_position())
	# node.moved 

func _on_break_edge(edge):
	delete_edge(edge)

func activate_incoming(excluded):
	for node in nodes:
		if node != excluded:
			node.set_state_incoming()

func deactivate_incoming(excluded):
	for node in nodes:
		if node != excluded:
			node.set_state_normal()

func _on_node_make_edge(node, quadrant):
	if !make_edge_state:
		make_edge_state = true
		make_edge_from = node
		make_edge_from_direction = quadrant
		# active nodes
		activate_incoming(node)
	else:
		if node != make_edge_from:
			# connect
			var edge = add_edge(make_edge_from, make_edge_from_direction, node, quadrant)
			edge.use_simple_line()
			emit_signal('new_edge', edge)
		make_edge_state = false
		deactivate_incoming(make_edge_from)


func delete_edge(edge):
	edge.from.remove_edge(edge.direction_from)
	edge.to.remove_edge(edge.direction_to)
	edges.remove(edge.idx)
	for i in range(edge.idx, edges.size()):
		edges[i].idx -= 1
	remove_child(edge)
	edge.queue_free()


func cardinal_create_from_node(origin, dir=Dir.RIGHT, spacing=default_grid_spacing):
	var new_node = create_node() 
	new_node.position = origin.position + default_grid_spacing * Dir_basis[dir]
	var new_idx = add_node(new_node)
	var edge = add_edge(origin, dir, new_node, Dir_opp[dir])
	edge.use_simple_line()
	return new_node

func _unhandled_input(event):
	if make_edge_state && event is InputEventMouseButton:
		make_edge_state = false
		deactivate_incoming(make_edge_from)

		# unhandled input goes from root -> leaves
		# if event is InputEventMouseButton:
			# get_tree().set_input_as_handled()
		# if event is InputEventMouseMotion:
			# get_tree().set_input_as_handled()

	# add new nodes 
	if enable_cardinal_add_nodes:
		for action in ['ui_right', 'ui_left', 'ui_down', 'ui_up']:
			if event.is_action(action) and event.pressed:
				var dir = Str_map[action.trim_prefix('ui_')]
				cardinal_create_from_node(head_node, dir)


class Edge:
	extends Node2D

	# var edge_base_color = Color('d4d4d4ff')
	export var edge_base_color: Color

	var idx: int
	# 
	var from: GridNode
	var to: GridNode
	var direction_from: int
	var direction_to: int
	var p_line: Array

	const edge_width_f = 0.2
	var edge_width: float
	
	# for debugging
	var draw_points = false


	func _init(from_, d_from, to_, d_to):
		from = from_
		to = to_
		edge_base_color = from.base_color
		edge_width = edge_width_f * from.idle_radius
		direction_from = d_from
		direction_to = d_to

	func use_simple_line():
		p_line = [from.position, to.position]

	func _draw():
		draw_polyline(p_line, edge_base_color, edge_width)
		if draw_points:
			for i in range(1, p_line.size()-1):
				draw_circle(p_line[i], 3, colors.red_highlight)

