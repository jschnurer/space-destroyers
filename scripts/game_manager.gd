extends Node

var credits := 0.0
var current_level := 0
var level_holder: Node2D

var stats: Dictionary[Enums.PlayerStats, Stat] = {
	Enums.PlayerStats.TANK_SPEED: load("res://resources/stats/tank_speed.tres"),
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
}

signal credits_changed()
signal stat_changed(changed_stat: Stat)
signal upgrade_changed(changed_upgrade: Upgrade)

func _ready() -> void:
	SignalBus.credits_picked_up.connect(_on_credits_picked_up)
	
	# DEBUG TO ADD POWER!!!
	credits = 55
	credits = 1000000000
	
	#alter_stat(Enums.PlayerStats.TANK_SPEED, 200, 0, 0)
	#alter_stat(Enums.PlayerStats.MAX_SHOTS, 200, 0, 0)
	#alter_stat(Enums.PlayerStats.RELOAD, 0, 0, 12.0)
	#alter_stat(Enums.PlayerStats.DAMAGE, 250, 0, 0)
	#alter_stat(Enums.PlayerStats.SHOT_SPEED, 0, 0, 10)
	#alter_stat(Enums.PlayerStats.PICKUP_AREA, 0, 0, 10)
	#alter_stat(Enums.PlayerStats.CREDIT_MULTIPLIER, 25, 0, 0)
	#alter_stat(Enums.PlayerStats.LUCK, 25, 0, 0)
	#alter_stat(Enums.PlayerStats.LIFE, 20, 0, 0)
	
	#alter_upgrade(Enums.PlayerUpgrades.FULL_AUTO, 1.0)
	#alter_upgrade(Enums.PlayerUpgrades.MULTI_CANNON, 1.0)
	#alter_upgrade(Enums.PlayerUpgrades.RETAINING_WALL_LEFT, 1.0)
	#alter_upgrade(Enums.PlayerUpgrades.RETAINING_WALL_RIGHT, 1.0)
	#alter_upgrade(Enums.PlayerUpgrades.LASER_SIGHT, 1.0)
	
	call_deferred("_load_initial_level")

func _load_initial_level() -> void:
	current_level = 1
	var level_filename := "res://scenes/levels/level_" + str(current_level) + ".tscn"
	if !FileAccess.file_exists(level_filename):
		print("Level file not found! " + level_filename)
		return
		
	var next_level: PackedScene = load(level_filename)
	if next_level:
		level_holder.add_child(next_level.instantiate())
	
	SignalBus.emit_new_level_loaded()

## Loads the next level sequentially.
func load_next_level() -> void:
	get_tree().paused = true
	current_level += 1
	
	for child in level_holder.get_children():
		child.queue_free()
	
	var player_tank: Node2D = get_tree().get_first_node_in_group("PLAYER")
	var screen_fader: ScreenFader = get_tree().get_first_node_in_group("SCREEN_FADER")
	
	var teleport_anim: TeleportAnimation = get_tree().get_first_node_in_group("TELEPORT_ANIM")
	if teleport_anim and player_tank:
		# Play the animation and then wait for it to complete.
		teleport_anim.global_position = player_tank.global_position
		teleport_anim.teleport_out()
		await teleport_anim.animation_complete
		
	if screen_fader:
		screen_fader.fade_out()
		await screen_fader.fade_complete
		SignalBus.emit_level_transition_screen_faded()
	
	var level_filename := "res://scenes/levels/level_" + str(current_level) + ".tscn"
	if !FileAccess.file_exists(level_filename):
		print("Level file not found! " + level_filename)
		return
		
	var next_level: PackedScene = load(level_filename)
	if next_level:
		level_holder.add_child(next_level.instantiate())
	
	# Snap player back to center.
	if player_tank:
		player_tank.global_position.x = Global.PLAYABLE_AREA_RECT.size.x / 2.0 + Global.PLAYABLE_AREA_RECT.position.x
		if teleport_anim:
			teleport_anim.global_position = player_tank.global_position
	
	SignalBus.emit_open_shop()
	await SignalBus.shop_closed
	
	if screen_fader:
		screen_fader.fade_in()
		await screen_fader.fade_complete
	
	if teleport_anim and player_tank:
		# Play the animation and then wait for it to complete.
		teleport_anim.teleport_in()
		await teleport_anim.animation_complete
		player_tank.visible = true
	
	get_tree().paused = false
	SignalBus.emit_new_level_loaded()

func _on_credits_picked_up(amt: float) -> void:
	credits += (amt * get_stat_value(Enums.PlayerStats.CREDIT_MULTIPLIER))
	credits_changed.emit()

## If the player has enough credits, decrement the credits and return true. Otherwise, return false.
func pay_credits(amount: float) -> bool:
	if credits >= amount:
		credits -= amount
		credits_changed.emit()
		return true
	return false

## Gets a stat.
func get_stat(stat: Enums.PlayerStats) -> Stat:
	return stats[stat]

## Gets the current value of a stat.
func get_stat_value(stat: Enums.PlayerStats) -> float:
	return get_stat(stat).get_current_value()

## Adds the delta to the player stat.
func alter_stat(p_stat: Enums.PlayerStats, point_delta: float, percent_bonus_delta: float) -> void:
	var stat := stats[p_stat]
	stat.point_bonus += point_delta
	stat.percent_bonus += percent_bonus_delta
	stat.level += 1
	stat_changed.emit(stat)

## Returns the specified upgrade value.
func get_upgrade(upgr: Enums.PlayerUpgrades) -> Upgrade:
	return upgrades[upgr]

## Returns the upgrade's current level.
func get_upgrade_level(upgr: Enums.PlayerUpgrades) -> int:
	return get_upgrade(upgr).level

## Returns true if the specified upgrade is not 0.0.
func has_upgrade(upgr: Enums.PlayerUpgrades) -> bool:
	return get_upgrade(upgr).level > 0

## Adds the specified delta to the player upgrade.
func alter_upgrade(upgr: Enums.PlayerUpgrades, delta_points: float) -> void:
	if upgrades[upgr].is_maxed():
		return
	
	upgrades[upgr].level += 1
	upgrades[upgr].point_bonus += delta_points
	upgrade_changed.emit(upgrades[upgr])
