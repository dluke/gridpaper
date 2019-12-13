extends Node2D

var gridnode = preload('res://GUI/GridNode.tscn')

class_name SpaceGraph

"""
A Graph and embedding in 2d grid. 

Should interact with NoteGrid (if that is child?)

# nodes draw themselves, SpaceGraph draws edges
"""

enum Dir {RIGHT, DOWN, LEFT, UP, DOWN_LAYER, UP_LAYER}
var Dir_opp = [Dir.LEFT, Dir.UP, Dir.RIGHT, Dir.DOWN, Dir.UP_LAYER, Dir.DOWN_LAYER]

var Str_map = {'right':0, 'down':1, 'left':2, 'up':3}
const e_x = Vector2(1,0)
const e_y = Vector2(0,1)
var Dir_basis = [e_x, e_y, -e_x, -e_y]

var nodes: Array = []
var edges: Array = []


# by selected node is the last to be added 
var selected_node

# variables for default spacing when adding new nodes outside of grid
var default_grid_spacing = 100

func _ready():
	pass

func add_edge(node_i, d_from, node_j, d_to):
	var edge = Edge.new(node_i, d_from, node_j, d_to)
	edge.idx = edges.size()
	edges.append(edge)
	node_i.edges[d_from] = edge.idx
	node_j.edges[d_to] = edge.idx
	add_child(edge)
	return edge

func create_node():
	return gridnode.instance()

func add_node(node):
	node.idx = nodes.size()
	nodes.append(node)
	add_child(node)
	selected_node = node
	return node.idx

func delete_edge(edge):
	edges.remove(edge.idx)
	for i in range(edge.idx, edges.size()):
		edges[i].idx -= 1
	remove_child(edge)
	edge.queue_free()

func delete_node(node):
	# O(n) operation since we update indices
	nodes.remove(node.idx)
	for i in range(node.idx, nodes.size()):
		nodes[i].idx -= 1
	remove_child(node)		
	node.queue_free()

func cardinal_create_from_node(origin, dir=Dir.RIGHT, spacing=default_grid_spacing):
	var new_node = create_node() 
	new_node.position = origin.position + default_grid_spacing * Dir_basis[dir]
	var new_idx = add_node(new_node)
	var edge = add_edge(origin, dir, new_node, Dir_opp[dir])
	edge.use_simple_line()

	return new_node

func _unhandled_input(event):
	# add new nodes 
	for action in ['ui_right', 'ui_left', 'ui_down', 'ui_up']:
		if event.is_action(action) and event.pressed:
			var dir = Str_map[action.trim_prefix('ui_')]
			cardinal_create_from_node(selected_node, dir)

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

