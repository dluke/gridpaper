extends Node2D

enum Dir {RIGHT, DOWN, LEFT, UP, DOWN_LAYER, UP_LAYER}
var Dir_opp = [Dir.LEFT, Dir.UP, Dir.RIGHT, Dir.DOWN, Dir.UP_LAYER, Dir.DOWN_LAYER]

func _ready():

	var tilespace = $TileSpace
	var notegrid = tilespace.notegrid

	var origin_idx = notegrid.extents
	var disp =  Vector2(0,0)

	var start_node
	var newnode 


	# testing node connections
	# i
	print('test i')
	start_node = notegrid.get(origin_idx).node
	newnode = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + Vector2(1,1)))
	tilespace.add_graph_edge(start_node, Dir.RIGHT, newnode, Dir.UP)

	# ii
	print('test ii')
	disp = Vector2(1,0)
	start_node = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp))
	newnode = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp + Vector2(1,1)))
	tilespace.add_graph_edge(start_node, Dir.RIGHT, newnode, Dir.LEFT)

	# iii
	print('test iii')
	disp = Vector2(3,0)
	start_node = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp))
	newnode = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp + Vector2(0,1)))
	tilespace.add_graph_edge(start_node, Dir.RIGHT, newnode, Dir.LEFT)

	# iv
	print('test iv')
	disp = Vector2(0,2)
	start_node = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp))
	newnode = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp + Vector2(2,0)))
	tilespace.add_graph_edge(start_node, Dir.RIGHT, newnode, Dir.LEFT)

	# v
	print('test v')
	disp = Vector2(3,2)
	start_node = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp))
	newnode = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp + Vector2(2,0)))
	tilespace.add_graph_edge(start_node, Dir.DOWN, newnode, Dir.DOWN)

	# vi
	print('test vi')
	disp = Vector2(0,3)
	start_node = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp))
	newnode = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp + Vector2(2,1)))
	tilespace.add_graph_edge(start_node, Dir.RIGHT, newnode, Dir.LEFT)

	# vii
	print('test vii')
	disp = Vector2(6,3)
	start_node = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp))
	newnode = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp + Vector2(0,2)))
	tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp + Vector2(0,1)))
	tilespace.add_graph_edge(start_node, Dir.RIGHT, newnode, Dir.LEFT)

	# viii
	print('test viii')
	disp = Vector2(0,-1)
	start_node = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp))
	newnode = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp + Vector2(1,0)))
	tilespace.add_graph_edge(start_node, Dir.RIGHT, newnode, Dir.UP)

	# ix
	print('test ix')
	disp = Vector2(0,5)
	start_node = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp))
	newnode = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp + Vector2(2,0)))
	tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp + Vector2(1,0)))
	tilespace.add_graph_edge(start_node, Dir.RIGHT, newnode, Dir.LEFT)

	# x
	print('test x')
	disp = Vector2(-1,0)
	start_node = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp))
	newnode = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp + Vector2(-2,0)))
	tilespace.add_graph_edge(start_node, Dir.DOWN, newnode, Dir.RIGHT)

	# xi
	print('test xi')
	disp = Vector2(-1,2)
	start_node = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp))
	newnode = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp + Vector2(-3,-1)))
	tilespace.add_graph_edge(start_node, Dir.LEFT, newnode, Dir.RIGHT)

	# xii
	print('test xii')
	disp = Vector2(4,0)
	start_node = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp))
	newnode = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp + Vector2(2,1)))
	tilespace.add_graph_edge(start_node, Dir.RIGHT, newnode, Dir.LEFT)

	# xiii
	print('test xiii')
	disp = Vector2(-1,-1)
	start_node = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp))
	newnode = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp + Vector2(-2,-2)))
	tilespace.add_graph_edge(start_node, Dir.RIGHT, newnode, Dir.UP)

	# xiv
	print('test xiv')
	disp = Vector2(-2,-1)
	start_node = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp))
	newnode = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp + Vector2(-2,-2)))
	tilespace.add_graph_edge(start_node, Dir.DOWN, newnode, Dir.RIGHT)

	# xv
	print('test xv')
	disp = Vector2(0,-3)
	start_node = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp))
	newnode = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp + Vector2(1,1)))
	tilespace.add_graph_edge(start_node, Dir.UP, newnode, Dir.RIGHT)

	# xvi
	# unfixed
	print('test xvi')
	disp = Vector2(0,-4)
	start_node = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp))
	newnode = tilespace.add_node_to_tile(notegrid.new_tile(origin_idx + disp + Vector2(-3,-1)))
	tilespace.add_graph_edge(start_node, Dir.UP, newnode, Dir.UP)
