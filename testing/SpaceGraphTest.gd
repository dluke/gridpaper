extends Node2D


func _ready():
	# initilise some nodes and edges
	var graph = $SpaceGraph
	var node_1 = graph.create_node()
	node_1.position = Vector2(100,100)
	graph.add_node(node_1)

	var node_2 = graph.cardinal_create_from_node(node_1)
	graph.cardinal_create_from_node(node_2, 1)
	graph.cardinal_create_from_node(node_2)
