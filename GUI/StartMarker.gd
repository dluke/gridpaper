extends HBoxContainer

signal start_inventory


# Called when the node enters the scene tree for the first time.
# func _ready():
	# pass

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT && event.pressed:
		# visible = false
		# set_process_input(false)
		emit_signal('start_inventory')

