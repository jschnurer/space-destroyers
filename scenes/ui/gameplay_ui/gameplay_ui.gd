extends CanvasLayer
class_name GameplayUI

@onready var current_life: Label = %CurrentLife
@onready var max_life: Label = %MaxLife
@onready var credits_display: Label = %CreditsDisplay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.credits_changed.connect(_on_credits_changed)
	GameManager.current_life_changed.connect(_on_current_life_changed)
	GameManager.stat_changed.connect(_on_stat_changed)
	_on_current_life_changed(GameManager.game_state.current_life)
	_on_stat_changed(GameManager.get_stat(Enums.PlayerStats.LIFE))

func _on_credits_changed(new_credits: float) -> void:
	credits_display.text = "%.0f" % new_credits

func _on_current_life_changed(new_life: int) -> void:
	current_life.text = str(new_life)

func _on_stat_changed(changed_stat: Stat) -> void:
	if changed_stat.player_stat == Enums.PlayerStats.LIFE:
		max_life.text = str(changed_stat.get_current_value_int())
