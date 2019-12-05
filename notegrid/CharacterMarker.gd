extends Sprite

class_name CharacterMarker

# export var white = Color('#ffffff')
# var sizefactor = 0.55
# onready var width = int(notegrid.size/15)

onready var notegrid = get_parent()


var idx: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	centered = false
	texture = preload('res://svg/pencil.svg')
	scale = Vector2(0.5,0.5)
	set_idx(Vector2(0,0))

func set_idx(idx):
	var square = notegrid.get_rect(idx)
	var corner = Vector2(0.8*square.size.x, 0.7*square.size.y)
	position = square.position + corner 
	position.y -= scale.y * texture.get_size().y


# func _draw():
# 	var pos = (square.position + square.end)/2
# 	var radius = (sizefactor * square.size.x)/2
# 	draw_circle(pos, radius, white)
# 	draw_circle(pos, radius-width, notegrid.background_color)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
