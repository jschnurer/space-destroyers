extends CanvasLayer

@onready var countdown_label: Label = %CountdownLabel

var _time_remaining := 5.0
var _is_counting_down := false

func _ready() -> void:
	SignalBus.start_teleporting.connect(_on_start_teleporting)

func _process(delta: float) -> void:
	if !_is_counting_down:
		return
	
	_time_remaining -= delta
	
	if Input.is_action_just_pressed("skip_teleport_delay"):
		_time_remaining = 0
	
	if _time_remaining <= 0:
		_is_counting_down = false
		visible = false
		GameManager.load_next_level()
	else:
		_update_label()

func _on_start_teleporting() -> void:
	visible = true
	_is_counting_down = true
	_time_remaining = GameManager.get_player_stat_curr_value(Enums.PlayerStats.TELEPORT_DELAY)
	_update_label()

func _update_label() -> void:
	countdown_label.text = str("%.2f" % _time_remaining)
