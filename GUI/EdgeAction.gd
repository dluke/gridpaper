extends Node2D

class_name EdgeAction


# connect is available, disconnect is available, incoming is available
enum State {Connect, Disconnect, Incoming}

const EMPTY_STATE: int = -1

var curr_state: int = EMPTY_STATE

var states: Array

func _ready():
	visible = false
	states = [$Connect, $Disconnect, $Incoming]
	set_state(State.Connect)

func _clear_state():
	for state in states:
		if state.is_inside_tree():
			remove_child(state)

func get_height():
	return states[State.Connect].texture.get_height()

func set_state(state):
	_clear_state()
	curr_state = state
	if state == EMPTY_STATE:
		return 
	else:
		add_child(states[state])

func highlight_on():
	for state in states:
		state.frame = 1

func highlight_off():
	for state in states:
		state.frame = 0

