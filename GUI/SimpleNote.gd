extends Control

# simple note that will display information about a space node

onready var Label = find_node('Label')
onready var TextEdit = find_node('TextEdit')

# func _ready():
# 	connect('mouse_exited', self, 'release')

func release():
	TextEdit.release_focus()

func get_text():
	return TextEdit.text 

func set_label(label):
	Label.text = label

func set_text(text):
	TextEdit.text = text

