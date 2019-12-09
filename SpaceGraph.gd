extends Node2D

var gridnode = preload('res://GUI/GridNode.tscn')

class_name SpaceGraph

"""
A Graph and embedding in 2d grid. 

Should interact with NoteGrid (if that is child?)

# nodes draw themselves, SpaceGraph draws edges
"""


export var nodes: Array
export var edges: Array

# by selected node is the last to be added 
var selected_node

# variables for default spacing when adding new nodes outside of grid
var default_grid_spacing = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_edge(node_i, node_j):
	var edge = Edge.new(node_i, node_j)
	edge.idx = edges.size()
	edges.append(edge)
	add_child(edge)
	return edge.idx

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

func cardinal_create_from_node(origin, dir=constants.Direction['right'], spacing=default_grid_spacing):
	var new_node = create_node() 
	new_node.position = origin.position + default_grid_spacing * dir
	var new_idx = add_node(new_node)
	add_edge(origin, new_node)
	return new_node

func _process(delta):
	# add new nodes 
	for action in ['ui_right', 'ui_left', 'ui_down', 'ui_up']:
		if Input.is_action_just_pressed(action):
			cardinal_create_from_node(selected_node, constants.Direction[action.trim_prefix('ui_')])

class Edge:
	extends Node2D

	# var edge_base_color = Color('d4d4d4ff')
	export var edge_base_color: Color

	var idx: int
	var from: GridNode
	var to 

	var edge_width: float
	var edge_width_f = 0.2

	func _init(from_, to_):
		from = from_
		to = to_
		edge_base_color = from.base_color
		edge_width = edge_width_f * from.idle_radius

	func _draw():
		draw_line(from.position, to.position, edge_base_color, edge_width)

