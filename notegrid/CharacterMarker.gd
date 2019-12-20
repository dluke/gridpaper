extends Sprite

class_name CharacterMarker

# should be called "draw marker"

# TODO move out of this gridlayer

onready var notegrid = get_parent()

var fade_offset = Vector2(0,-20)
var color_fade = Color(1,1,1,0.4)
var color_normal = Color(1,1,1,1)

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


func _process(delta):
	if Input.is_key_pressed(KEY_SHIFT):
		self_modulate = color_fade
		offset = fade_offset
	else:
		self_modulate = color_normal
		offset = Vector2(0,0)


