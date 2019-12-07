extends Control

# simple note that will display information about a space node

func set_label(label):
	find_node('Label').text = label

func set_text(text):
	find_node('TextEdit').text = text


