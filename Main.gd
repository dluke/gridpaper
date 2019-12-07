extends Node2D


var grabbed: bool = 0

func _ready():
	$Inventory.rect_position = Vector2(50, 200)

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

func _process(delta):
	if Input.is_action_just_pressed("toggle_inventory"):
		if $Inventory.visible == true:
			$Inventory.visible = false
			$Inventory.release_focus()
			$Inventory.set_process_input(false)
		else:
			$Inventory.visible = true
			$Inventory.grab_focus()
			$Inventory.set_process_input(true)
