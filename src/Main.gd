extends Node2D


func _ready() -> void:
	var new_dialog = Dialogic.start('Test')
	add_child(new_dialog)
