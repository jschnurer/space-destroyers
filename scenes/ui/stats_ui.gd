extends Control
class_name StatsUI

@onready var credits_display: Label = %CreditsDisplay
@onready var life_display: Label = %LifeDisplay

func _ready() -> void:
	Game.credits_changed.connect(_on_credits_changed)
	Game.current_life_changed.connect(_update_life_display.unbind(1))
	Game.stat_changed.connect(_on_stat_changed)
	_on_credits_changed(Game.game_state.credits)
	_update_life_display()

func _on_credits_changed(new_credits: float) -> void:
	credits_display.text = "%.0f" % new_credits

func _on_stat_changed(stat: Stat) -> void:
	if stat.player_stat == Enums.PlayerStats.LIFE:
		_update_life_display()

func _update_life_display() -> void:
	life_display.text = "%s/%s" % [Game.game_state.current_life, \
		Game.game_state.stats[Enums.PlayerStats.LIFE].get_current_value_int()]
