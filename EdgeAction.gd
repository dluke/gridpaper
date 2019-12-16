extends Node2D


enum State {connect, disconnect}

var curr_state: int

func _ready():
	visible = false

func set_state(state):
	curr_state = state
	match state:
		State.connect:
			$Connect.visible = true
			$Disconnect.visible = false
		State.disconnect:
			$Control.visible = false
			$Disconnect.visible = true
