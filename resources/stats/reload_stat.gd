extends Stat
class_name ReloadStat

@export var base_value := 1.0
	
func get_upgrade_cost() -> float:
	return ceil(5 * pow(1.5, current_level))

func get_current_value() -> float:
	return base_value / (1.0 + 0.12 * current_level)
