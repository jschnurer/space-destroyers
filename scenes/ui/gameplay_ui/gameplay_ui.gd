extends CanvasLayer
class_name GameplayUI

@onready var current_life: Label = %CurrentLife
@onready var max_life: Label = %MaxLife
@onready var credits_display: Label = %CreditsDisplay
@onready var controls_container: HBoxContainer = %ControlsContainer

var _inputs_that_clear_instructions: Array[String] = ["move_left", "move_right", "shoot"]
var _clear_instructions_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.credits_changed.connect(_on_credits_changed)
	Game.current_life_changed.connect(_on_current_life_changed)
	Game.stat_changed.connect(_on_stat_changed)
	_on_current_life_changed(Game.game_state.current_life)
	_on_stat_changed(Game.get_stat(Enums.PlayerStats.LIFE))

func _on_credits_changed(new_credits: float) -> void:
	credits_display.text = "%.0f" % new_credits

func _on_current_life_changed(new_life: int) -> void:
	current_life.text = str(new_life)

func _on_stat_changed(changed_stat: Stat) -> void:
	if changed_stat.player_stat == Enums.PlayerStats.LIFE:
		max_life.text = str(changed_stat.get_current_value_int())

func _input(event: InputEvent) -> void:
	if controls_container.visible:
		var did_input := false
		for i in _inputs_that_clear_instructions:
			if event.is_action_pressed(i):
				did_input = true
		
		if did_input:
			# Fade out the instructions.
			if _clear_instructions_tween:
				_clear_instructions_tween.kill()
			_clear_instructions_tween = create_tween()
			_clear_instructions_tween.tween_property(controls_container, "modulate:a", 0.0, 1.5)
			_clear_instructions_tween.tween_callback(func() -> void:
				controls_container.visible = false
				controls_container.modulate.a = 1.0
			)
