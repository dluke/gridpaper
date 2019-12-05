extends Node2D


var background_color = Color('#4d4d4d')

# Main references	
onready var graph = $SpaceGraph
onready var notegrid = $SpaceGraph.get_node('NoteGrid')

# Called when the node enters the scene tree for the first time.
func _ready():

	# set background_color
	VisualServer.set_default_clear_color(background_color)

	center_view()

	# add a gridnode at the origin 
	var origin_idx = Vector2(0,0)
	var newtile = notegrid.new_tile(origin_idx)
	newtile.visited = true
	var space_node = newtile.add_gridnode()
	graph.add_node(space_node)

func center_view():
	var viewrect = get_viewport_rect()
	var cpt = (viewrect.position + viewrect.end)/2
	var grid_cpt = notegrid.get_boardsize()/2
	graph.position = cpt - grid_cpt

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _unhandled_input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
