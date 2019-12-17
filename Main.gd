extends Node2D


onready var notegrid = $TileSpace.notegrid
onready var note = find_node("SimpleNote")
onready var inventory = find_node("Inventory")
onready var sidepanel = find_node("SidePanel")

func _ready():
	inventory.rect_position = Vector2(50, 200)
	$TileSpace.connect('new_open_tile', self, '_on_new_open_tile')

	# initialise SimpleNote
	var open_tile =	$TileSpace.open_tile
	note.set_label(node_label_format(open_tile.node))
	note.set_text(open_tile.description)


func node_label_format(node):
	var coord = node.ixy - get_node('TileSpace').notegrid.extents
	return ("(%d, %d)" % [coord.x, coord.y])

func _on_new_open_tile(oldtile, tile):
	oldtile.description = note.get_text()
	note.set_label(node_label_format(tile.node))
	note.set_text(tile.description)

func _input(event):
	pass
	# print('input ', event.as_text())

func _unhandled_input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()

	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			note.release()
		# get_tree().set_input_as_handled()

	if event.is_action("toggle_inventory") and event.pressed:
		if $Inventory.visible == true:
			$Inventory.visible = false
			$Inventory.release_focus()
		else:
			$Inventory.visible = true
			$Inventory.grab_focus()
		get_tree().set_input_as_handled()

	if event.is_action("toggle_sidepanel") and event.pressed:
		sidepanel.visible = !sidepanel.visible
		get_tree().set_input_as_handled()

	