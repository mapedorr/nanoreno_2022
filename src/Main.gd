extends Node2D
#warning-ignore-all:return_value_discarded

signal continued

var _animating := false

onready var _continue: TextureButton = find_node('Continue')
onready var _label: Label = find_node('Label')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Godot methods ░░░░
func _ready() -> void:
	_label.modulate.a = 0.0
	
	_continue.connect('pressed', self, '_next_message')
	
	yield(get_tree().create_timer(0.5), 'timeout')
	
	yield(run(
		[
			'Érase una vez',
			'En la capital de un país del tercer mundo',
			'La historia que conectaba al pasado y al presente',
			'En una repetición sin fin',
			'...',
			'1815'
		]
	), 'completed')
	
	var new_dialog = Dialogic.start('TestPast')
	new_dialog.connect('timeline_end', self, '_goto_present')
	
	add_child(new_dialog)


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ public methods ░░░░
func run(commands: Array) -> void:
	for c in commands:
		if c == '...':
			yield(get_tree().create_timer(1.0), 'timeout')
		else:
			_show_message(c)
			yield(self, 'continued')
	
	yield(get_tree(), 'idle_frame')



# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ private methods ░░░░
func _next_message() -> void:
	if _animating: return
	
	_animating = true
	
	$Tween.interpolate_property(
		_label, 'modulate:a',
		1.0, 0.0,
		0.9, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	$Tween.start()
	yield($Tween, 'tween_all_completed')
	
	_animating = false
	_label.text = ''
	emit_signal('continued')


func _show_message(msg: String) -> void:
	_animating = true
	_label.text = msg
	
	$Tween.interpolate_property(
		_label, 'modulate:a',
		0.0, 1.0,
		1.2, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	$Tween.start()
	yield($Tween, 'tween_all_completed')
	
	_animating = false


func _goto_present(timeline_name: String) -> void:
	yield(run(['2006']), 'completed')
	
	var new_dialog = Dialogic.start('Test')
#	new_dialog.connect('timeline_end', self, '_goto_present')
	
	add_child(new_dialog)
