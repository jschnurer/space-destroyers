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
	
	if Input.is_action_just_pressed("shop"):
		_input_enabled = false
		_fade_out_restart()

func _on_game_over(game_over_reason: Enums.GameOverReason) -> void:
	SignalBus.emit_play_bgm(game_over_bgm, 1.0, 1.0, 0.0, 1.0)
	var screen_fader: ScreenFader = get_tree().get_first_node_in_group("SCREEN_FADER")
	_update_labels(game_over_reason)
	visible = true
	screen_fader.fade_in()
	await screen_fader.fade_complete
	_input_enabled = true

func _update_labels(game_over_reason: Enums.GameOverReason) -> void:
	match game_over_reason:
		Enums.GameOverReason.ENEMY_LANDED:
			game_over_reason_text.text = "You failed to prevent the destroyers from reaching Earth. The citizens of the planet aren't mad. They're just disappointed."
		Enums.GameOverReason.TANK_DESTROYED:
			game_over_reason_text.text = "During your valiant battle, your tank was destroyed. Unopposed, the destroyers from space conquered the Earth. The citizens of the planet aren't mad. They're just disappointed."

func _fade_out_restart() -> void:
	_input_enabled = false
	
	var screen_fader: ScreenFader = get_tree().get_first_node_in_group("SCREEN_FADER")
	screen_fader.fade_out()
	await screen_fader.fade_complete
	
	GameManager.restart_game()
	visible = false
