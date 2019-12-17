extends PanelContainer

var label_font = preload('res://font/roboto.tres').duplicate()

var label_font_size = 1
onready var label1 = find_node('GlyphLabel')
onready var label2 = find_node('TerrainLabel')

func _ready():
	pass
	# label1.add_font_override('font', label_font)
	# label2.add_font_override('font', label_font)
	# set_label_font_size(label_font_size)


func set_label_font_size(size):
	label_font.set_size(size)

func hide():
	set_visible(false)

func unhide():
	set_visible(true)
