extends Resource
class_name GameState

var credits := 0.0
var current_level_type := Enums.LevelTypes.NONE
var current_level := 0
var current_life := 1

var stats: Dictionary[Enums.PlayerStats, Stat] = {
	Enums.PlayerStats.TANK_SPEED: load("res://resources/stats/move_speed.tres"),
	Enums.PlayerStats.MAX_SHOTS: load("res://resources/stats/max_shots.tres"),
	Enums.PlayerStats.RELOAD: load("res://resources/stats/reload.tres"),
	Enums.PlayerStats.DAMAGE: load("res://resources/stats/damage.tres"),
	Enums.PlayerStats.SHOT_SPEED: load("res://resources/stats/shot_speed.tres"),
	Enums.PlayerStats.PICKUP_AREA: load("res://resources/stats/pickup_area.tres"),
	Enums.PlayerStats.CREDIT_MULTIPLIER: load("res://resources/stats/credit_multiplier.tres"),
	Enums.PlayerStats.LUCK: load("res://resources/stats/luck.tres"),
	Enums.PlayerStats.LIFE: load("res://resources/stats/life.tres"),
}

var upgrades: Dictionary[Enums.PlayerUpgrades, Upgrade] = {
	Enums.PlayerUpgrades.FULL_AUTO: load("res://resources/upgrades/full_auto.tres"),
	Enums.PlayerUpgrades.MISSILES: load("res://resources/upgrades/missiles.tres"),
	Enums.PlayerUpgrades.LASER_SIGHT: load("res://resources/upgrades/laser_sight.tres"),
	Enums.PlayerUpgrades.MULTI_CANNON: load("res://resources/upgrades/multi_cannon.tres"),
	Enums.PlayerUpgrades.ANTI_AIR_TOWER: load("res://resources/upgrades/anti_air_tower.tres"),
	Enums.PlayerUpgrades.BARRICADE: load("res://resources/upgrades/barricade.tres"),
	Enums.PlayerUpgrades.LIGHTNING_TOWER: load("res://resources/upgrades/lightning_tower.tres"),
	Enums.PlayerUpgrades.RETAINING_WALL_LEFT: load("res://resources/upgrades/left_wall.tres"),
	Enums.PlayerUpgrades.RETAINING_WALL_RIGHT: load("res://resources/upgrades/right_wall.tres"),
	Enums.PlayerUpgrades.FLAK_CANNON: load("res://resources/upgrades/flak_cannon.tres"),
}
