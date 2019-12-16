extends Node2D

class_name EdgeAction

enum State {Connect, Disconnect}

# if State.Connect, disconnect option is available
# if State.Disconnect, connect option is available
var curr_state: int

func _ready():
	visible = false
	set_state(State.Disconnect)

func get_height():
	return $Connect.texture.get_height()

func set_state(state):
	curr_state = state
	match state:
		State.Connect:
			$Connect.visible = false
			$Disconnect.visible = true
		State.Disconnect:
			$Connect.visible = true
			$Disconnect.visible = false
