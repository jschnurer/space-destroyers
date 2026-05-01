extends CanvasLayer
class_name GameOver

@export var game_over_bgm: AudioStream

@onready var game_over_reason_text: Label = %GameOverReasonText

var _input_enabled := false

func _ready() -> void:
	visible = false
	SignalBus.game_over.connect(_on_game_over)

func _process(_delta: float) -> void:
	if !_input_enabled:
		return
	
	if Input.is_action_just_pressed("shoot"):
		_input_enabled = false
		_fade_out_restart()

func _on_game_over(game_over_reason: Enums.GameOverReason) -> void:
	SignalBus.emit_play_bgm(game_over_bgm, 1.0, 1.0, 0.0, 1.0)
	_update_labels(game_over_reason)
	visible = true
	SignalBus.emit_fade_in_screen()
	await SignalBus.fade_in_screen_complete
	_input_enabled = true

func _update_labels(game_over_reason: Enums.GameOverReason) -> void:
	match game_over_reason:
		Enums.GameOverReason.ENEMY_LANDED:
			game_over_reason_text.text = "You failed to prevent the destroyers from reaching Earth. The citizens of the planet aren't mad. They're just disappointed."
		Enums.GameOverReason.TANK_DESTROYED:
			game_over_reason_text.text = "During your valiant battle, SOPHIA 0 was destroyed. Unopposed, the destroyers from space conquered the Earth. The citizens of the planet aren't mad. They're just disappointed."

func _fade_out_restart() -> void:
	_input_enabled = false
	
	SignalBus.emit_fade_out_screen()
	await SignalBus.fade_out_screen_complete
	visible = false
	
	Game.restart_game()
