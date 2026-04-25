extends CanvasLayer
class_name RemapInputPopup

@export var wait_time := 5.0

signal input_accepted(event: InputEvent, key_name: String)

@onready var input_countdown: Timer = %InputCountdown
@onready var countdown: Label = %Countdown
@onready var title: Label = %Title

var _countdown_time: float
var _input_enabled := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_countdown_time = wait_time
	input_countdown.start()

func _unhandled_input(event: InputEvent) -> void:
	if !_input_enabled:
		return
		
	if event is not InputEventKey:
		return
	
	var e: InputEventKey = event
	var file_path := Global.get_kenney_file_path_for_input(e)
	
	if !file_path:
		return
	
	var key_name := OS.get_keycode_string(e.physical_keycode)
	input_accepted.emit(e, key_name)
	queue_free()

func _on_input_countdown_timeout() -> void:
	_countdown_time -= 1
	countdown.text = "%.0f" % _countdown_time
	if _countdown_time <= 0:
		queue_free()
	else:
		input_countdown.start()

func set_action_name(action_name: String) -> void:
	title.text = action_name

func _on_delay_timer_timeout() -> void:
	_input_enabled = true
