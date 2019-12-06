extends Node2D


func _ready():
	pass
	# InputMap.add_action('toggle_inventory')
	# i_keydown = InputEventKey.new()
	# InputMap.add_action_event('toggle_inventory', )

var grabbed: bool = 0

func _unhandled_input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()


	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			grabbed = 1 
		elif !event.pressed:
			grabbed = 0 

	if event is InputEventMouseMotion and grabbed == true:
		position += event.relative
		#
		update()
