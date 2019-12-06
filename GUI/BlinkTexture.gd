extends TextureRect

export var delay = 0.8

var hold_texture
var state = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = Timer.new()
	timer.wait_time = delay
	timer.autostart = true
	timer.one_shot = true
	timer.connect('timeout', self, '_on_blink')
	add_child(timer)

	hold_texture = texture
	texture = null

func _on_blink():
	print('blink')
	state = 1
	texture = hold_texture

func _process(delta):
	pass
