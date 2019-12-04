extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	texture = load('res://icon.png')
	offset = Vector2(50,50)
	print(get_rect())

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
