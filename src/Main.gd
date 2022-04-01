extends Node2D
#warning-ignore-all:return_value_discarded

signal continued

const Constants := preload('Constants.gd')

var _animating := false
var _timelines_json := {}

onready var _continue: TextureButton = find_node('Continue')
onready var _label: Label = find_node('Label')
onready var _next_indicator: TextureRect = find_node('NextIndicator')
onready var _next_animation: AnimationPlayer = _next_indicator.get_node('AnimationPlayer')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Godot methods ░░░░
func _ready() -> void:
	_label.text = ''
	_label.modulate.a = 0.0
	
	_continue.connect('pressed', self, '_next_message')
	
#	yield(get_tree().create_timer(0.5), 'timeout')
#	goto_timeline('Test', 'Test')
	
	yield(run(Constants.Intro), 'completed')
	goto_timeline('Meeting', 'Past')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ public methods ░░░░
func run(commands: Array) -> void:
	for c in commands:
		if c == '...':
			yield(get_tree().create_timer(1.0), 'timeout')
		else:
			_show_message(c)
			yield(self, 'continued')
	
	yield(get_tree(), 'idle_frame')


func goto_timeline(timeline: String, next_timeline := '') -> void:
	var new_dialog = Dialogic.start(timeline)
	
	if next_timeline:
		new_dialog.connect('timeline_end', self, '_timeline_ended', [next_timeline])

	add_child(new_dialog)



# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ private methods ░░░░
func _next_message() -> void:
	if _animating:
		$Tween.remove_all()

		_label.modulate.a = 1.0
		_next_animation.play('UpDown')
		_animating = false
		
		return
	
	_next_animation.play('RESET')
	
	_animating = false
	_label.text = ''
	_label.modulate.a = 0.0
	emit_signal('continued')


func _show_message(msg: String) -> void:
	_animating = true
	_label.text = msg
	
	$Tween.interpolate_property(
		_label, 'modulate:a',
		0.0, 1.0,
		1.5, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	$Tween.start()
	yield($Tween, 'tween_all_completed')
	
	_next_animation.play('UpDown')
	_animating = false


func _timeline_ended(timeline_json: String, next_timeline := '') -> void:
	prints('---', DialogicUtil.get_timeline_dict()[timeline_json].name)
	match DialogicUtil.get_timeline_dict()[timeline_json].name:
		'Vision':
			yield(run(Constants.Past), 'completed')
			goto_timeline(next_timeline, 'Stake')
		'Past':
			yield(run(Constants.Murder), 'completed')
			goto_timeline(next_timeline, 'Promise')
		'Stake':
			yield(run(Constants.Promise), 'completed')
			goto_timeline(next_timeline, 'xxx')
		'Revenge':
			yield(run(Constants.Revenge), 'completed')
			# TODO: volver al menú principal
		'Forgiveness':
			yield(run(Constants.Leaving), 'completed')
			# TODO: volver al menú principal
