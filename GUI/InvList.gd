extends VBoxContainer


var content_row_factory = preload('res://GUI/ContentRow.tscn')
# the content row at the bottom of the inventory
var started: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$StartMarker.connect('start_inventory', self, "_on_start_inventory")
	$content_row.connect('new_entry', self, "_on_new_entry")
	$content_row.visible = false

func _on_new_entry(row_container):
	var next_idx = row_container.get_index() + 1
	if next_idx < get_child_count():
		var child_row = get_child(next_idx)
		if child_row.empty == true:
			child_row.get_node('ItemName').grab_focus()
			return
	var new_row = _new_content_row()
	add_child_below_node(row_container, new_row)
	new_row.get_node('ItemName').grab_focus()


func _on_start_inventory():
	remove_child($StartMarker)
	$content_row.visible = true
	var item_text = $content_row.get_node('ItemName')
	item_text.grab_focus()
	started = true

func _new_content_row():
	var new_row = content_row_factory.instance()
	new_row.connect('new_entry', self, "_on_new_entry")
	return new_row


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
