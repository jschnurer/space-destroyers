extends Resource
class_name Stat

@export var player_stat: Enums.PlayerStats
@export var current_level: int = 0
@export var current_value := 0.0

func get_upgrade_cost() -> float:
	return 999.99

func get_current_value() -> float:
	return 0

func level_up(delta_levels: int) -> void:
	current_level += delta_levels
