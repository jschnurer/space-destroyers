class_name PlayerStat

@export var current_level := 1

## Base value of the stat.
@export var base_value: float:
	set(value):
		base_value = value
		_update_current_value()
	get():
		return base_value

## Hard points added to base and included in percentile modifications.
@export var hard_bonus: float:
	set(value):
		hard_bonus = value
		_update_current_value()
	get():
		return hard_bonus

## Soft points added to base NOT included in percentile modifications.
@export var soft_bonus: float:
	set(value):
		soft_bonus = value
		_update_current_value()
	get():
		return soft_bonus

## Modifies total value by this percentage (default 1.0 = no bonus/penalty)
@export var percent_modifier: float = 1.0:
	set(value):
		percent_modifier = value
		_update_current_value()
	get():
		return percent_modifier

## The current total value of the stat:
## (base_value + hard_bonus) * percent_modifier + soft_bonus.
## DO NOT SET THIS DIRECTLY! IT IS CALCULATED AUTOMATICALLY WHEN THE OTHER VALUES CHANGE.
@export var current_value: float:
	set(value):
		current_value = value
	get():
		return current_value

func _update_current_value() -> void:
	current_value = (base_value + hard_bonus) * percent_modifier + soft_bonus

func _init(base_val: float, prct_mod: float = 1.0) -> void:
	base_value = base_val
	percent_modifier = prct_mod
