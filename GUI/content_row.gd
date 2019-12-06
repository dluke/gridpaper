extends HBoxContainer

signal new_entry

var empty: bool = true

func _ready():
	$ItemName.connect('text_entered', self, '_on_text_entered')
	$ItemName.connect('text_changed', self, '_on_text_changed')
	# connect('focus_exited', self, '_on_focus_exited', [self])

func _on_text_entered(new_text):
	if !new_text.strip_edges().empty():
		$Quantity.text = '1'
		emit_signal('new_entry', self)

func _on_text_changed(new_text):
	if !new_text.strip_edges().empty():
		$Quantity.placeholder_text = '1'
		empty = false

# func _on_focus_exited():
# 	if !$ItemName.text.strip_edges().empty():
# 		emit_signal('new_entry')
