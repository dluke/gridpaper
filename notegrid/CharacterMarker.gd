extends Sprite

class_name CharacterMarker

# "draw marker"

# TODO move out of this gridlayer

onready var notegrid = get_parent()


var idx: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	centered = false
	texture = preload('res://svg/pencil.svg')
	scale = Vector2(0.5,0.5)

func set_idx(idx):
	var square = notegrid.get_rect(idx)
	var corner = Vector2(0.8*square.size.x, 0.7*square.size.y)
	position = square.position + corner 
	position.y -= scale.y * texture.get_size().y
	update()


# func _draw():
# 	var pos = (square.position + square.end)/2
# 	var radius = (sizefactor * square.size.x)/2
# 	draw_circle(pos, radius, white)
# 	draw_circle(pos, radius-width, notegrid.background_color)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
