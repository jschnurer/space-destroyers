extends CanvasLayer

@onready var credits_display: Label = %CreditsDisplay
@onready var level_number: Label = %LevelNumber
@onready var life_display: Label = %LifeDisplay
@onready var upgrades: Label = %Upgrades

func _ready() -> void:
	GameManager.credits_changed.connect(_on_credits_changed)
	GameManager.current_life_changed.connect(_update_life_display.unbind(1))
	GameManager.stat_changed.connect(_on_stat_changed)
	SignalBus.level_transition_screen_faded.connect(_on_level_transition_screen_faded)
	_on_credits_changed()
	_update_life_display()

func _on_level_transition_screen_faded() -> void:
	level_number.text = str(GameManager.game_state.current_level)

func _on_credits_changed() -> void:
	credits_display.text = "%.0f" % GameManager.game_state.credits

func _on_stat_changed(stat: Stat) -> void:
	if stat.player_stat == Enums.PlayerStats.LIFE:
		_update_life_display()

func _update_life_display() -> void:
	life_display.text = "%s/%s" % [GameManager.game_state.current_life, \
		GameManager.game_state.stats[Enums.PlayerStats.LIFE].get_current_value_int()]
