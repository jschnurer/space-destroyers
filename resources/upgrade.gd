extends BaseStat
class_name Upgrade

@export var upgrade: Enums.PlayerUpgrades

func is_maxed() -> bool:
	return level >= max_level
