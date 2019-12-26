extends Control


var grabbed = false

onready var z_button = get_node('z_button')
onready var z_marker = get_node('z_marker')
onready var tilespace = get_parent()

var z_button_offset = Vector2(10,10)

var button_label_form = 'z = %d'
var level: int
var ylims: Vector2


func _init(level=0):
	level = level

func _ready():
	
	z_button.connect('focus_entered', self, '_on_focus_entered')
	z_button.connect('focus_exited', self, '_on_focus_exited')
	z_button.connect('button_down', self, '_on_button_down')
	z_button.connect('button_up', self, '_on_button_up')

	z_button.text = button_label_form % level
	# z_button.rect_position.z

func _on_button_down():
	grabbed = true

func _on_button_up():
	grabbed = false
	var l_mpos = tilespace.to_local(get_viewport().get_mouse_position())
	var gridpos = l_mpos.snapped(tilespace.square_size) 
	var y = gridpos.y + tilespace.gsize/2
	set_y(y)

func update_marker():
	ylims = tilespace.get_ylimits(level)
	set_y(ylims[1]+tilespace.gsize)

func set_y(yvalue):
	z_marker.rect_position.y = yvalue
	z_button.rect_position = Vector2(z_button.rect_position.x, yvalue-z_button_offset.y-z_button.rect_size.y)
	fix_label_x_position()
	update()

func fix_label_x_position():
	var vrect = get_viewport_rect()
	var vlp = tilespace.to_local(vrect.position)
	z_button.rect_position = Vector2(vlp.x + z_button_offset.x, z_button.rect_position.y)
	update()


func _on_focus_entered():
	pass

func _on_focus_exited():
	pass
