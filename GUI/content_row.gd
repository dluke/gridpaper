extends HBoxContainer

signal new_entry
signal discard_entry

var empty: bool = true

func _ready():
	$ItemName.connect('text_entered', self, '_on_text_entered')
	$ItemName.connect('text_changed', self, '_on_text_changed')
	$Quantity.connect('text_entered', self, '_on_quantity_text_entered')
	$Discard.connect('button_down', self, '_on_discard_button_down')
	# connect('focus_exited', self, '_on_focus_exited', [self])

# func _input(event):
# 	if event is InputEventKey:
# 		print('row input ', event.as_text(), ' ', event.pressed)

func _gui_input(event):
	pass # not called

## so text input on the line happens between _input and _gui_input

func _on_discard_button_down():
	# emit signal in high level nodes have their own handling
	emit_signal('discard_entry', self)
	# discard
	get_parent().remove_child(self)

func _on_quantity_text_entered(new_text):
	if new_text.strip_edges().empty():
		$Quantity.text = $Quantity.placeholder_text
		emit_signal('new_entry', self)

func _on_text_entered(new_text):
	if !new_text.strip_edges().empty():
		$Quantity.text = '1'
		emit_signal('new_entry', self)

func _on_text_changed(new_text):
	if !new_text.strip_edges().empty():
		$Quantity.placeholder_text = '1'
		empty = false
	else:
		empty = true



# func _on_focus_exited():
# 	if !$ItemName.text.strip_edges().empty():
# 		emit_signal('new_entry')
