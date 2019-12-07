extends Control

var invlist


# Called when the node enters the scene tree for the first time.
func _ready():

	invlist = find_node('InvList')


func _input(event):
	# any touch will start the inventory

	if event is InputEventKey and invlist.started == false and has_focus():
		# if !Input.is_action_pressed('toggle_inventory'):
		if !event.scancode == KEY_I:
			print('start inventory')
			invlist._on_start_inventory()

	pass

