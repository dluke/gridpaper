extends Node2D

class_name CharacterMarker

export var white = Color('#ffffff')
var sizefactor = 0.55

onready var notegrid = get_parent()
onready var width = int(notegrid.size/15)

var grididx: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	var idx = (notegrid.gridsize - Vector2(1,1))/2
	set_grididx(idx.floor())


func set_grididx(idx):
	grididx = idx
	update()

func _draw():
	var square = notegrid.get_rect(grididx)
	var pos = (square.position + square.end)/2
	var radius = (sizefactor * square.size.x)/2
	draw_circle(pos, radius, white)
	draw_circle(pos, radius-width, notegrid.background_color)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
