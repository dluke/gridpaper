extends Control

export var color = Color('d4d4d4ff')
export var width: int = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	draw_line(Vector2(0, rect_size.y/2), Vector2(rect_size.x, rect_size.y/2), color, width)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
