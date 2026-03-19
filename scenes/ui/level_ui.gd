extends CanvasLayer

@onready var credits_display: Label = %CreditsDisplay
@onready var level_number: Label = %LevelNumber

@onready var upgrades: Label = %Upgrades

func _ready() -> void:
	GameManager.credits_changed.connect(_on_credits_changed)
	SignalBus.level_transition_screen_faded.connect(_on_level_transition_screen_faded)
	_on_credits_changed()

func _on_level_transition_screen_faded() -> void:
	level_number.text = str(GameManager.current_level)

func _on_credits_changed() -> void:
	credits_display.text = "%.0f" % GameManager.credits
