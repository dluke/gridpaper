extends Control

export var centered_grid_idx: Vector2
export var grid_offset: Vector2 = Vector2(0.5,0.5)
var grid_idx

func _ready():
	grid_idx = centered_grid_idx + get_parent().extents 
	var grid_pos = get_parent().get_pos(grid_idx)
	rect_position = grid_pos + grid_offset*get_parent().square_size 
