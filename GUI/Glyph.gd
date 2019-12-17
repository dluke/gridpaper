extends Control

class_name Glyph

var hl_material = preload("res://svgmaterial/2d_outline_material.tres")

var idx: Vector2
var is_highlighted: bool = false

export var uv = Vector2(0,0)
onready var sprite 

# func _init():
	# add_child(sprite)

func _ready():
	if get_child_count() > 0:
		set_sprite(get_child(0))
		highlight_off()

	connect('mouse_entered', self, '_on_mouse_entered')
	connect('mouse_exited', self, '_on_mouse_exited')

func _on_mouse_entered():
	highlight_on()

func _on_mouse_exited():
	highlight_off()

func set_sprite(sprite_):
	sprite = sprite_
	rect_min_size = sprite.scale * sprite.texture.get_size()

func center_at(cpt):
	rect_position = cpt-rect_min_size/2

func set_grid_idx(_idx):
	idx = _idx

func highlight_on():
	is_highlighted = true
	sprite.set_material(hl_material)

func highlight_off():
	is_highlighted = false
	sprite.set_material(null)
