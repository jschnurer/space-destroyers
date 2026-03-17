extends Node

var credits := 1000000000.0
var current_level := 0
var level_holder: Node2D

var stats: Dictionary[Enums.PlayerStats, Stat] = {
	Enums.PlayerStats.RELOAD: load("res://resources/stats/reload_stat.tres"),
}

var player_stats: Dictionary[Enums.PlayerStats, PlayerStat] = {
	Enums.PlayerStats.TANK_SPEED: PlayerStat.new(200.0),
	Enums.PlayerStats.MAX_SHOTS: PlayerStat.new(1.0),
	Enums.PlayerStats.RELOAD: PlayerStat.new(1.0, 0.0),
	Enums.PlayerStats.SHOT_POWER: PlayerStat.new(12.0),
	Enums.PlayerStats.SHOT_SPEED: PlayerStat.new(600.0, 0.0),
	Enums.PlayerStats.PICKUP_AREA: PlayerStat.new(26.0),
	Enums.PlayerStats.CREDIT_MULTIPLIER: PlayerStat.new(1.0),
	Enums.PlayerStats.TELEPORT_DELAY: PlayerStat.new(5.0),
	Enums.PlayerStats.LUCK: PlayerStat.new(1.0),
	Enums.PlayerStats.MAX_LIFE: PlayerStat.new(1.0)
}

var player_upgrades: Dictionary[Enums.PlayerUpgrades, float] = {
	Enums.PlayerUpgrades.AUTO_FIRE: 0.0,
	Enums.PlayerUpgrades.MISSILES: 0.0,
	Enums.PlayerUpgrades.LASER_SIGHT: 0.0,
	Enums.PlayerUpgrades.TWIN_CANNON: 0.0,
	Enums.PlayerUpgrades.ANTI_AIR: 0.0,
	Enums.PlayerUpgrades.BARRICADE: 0.0,
	Enums.PlayerUpgrades.LIGHTNING_TOWER: 0.0,
	Enums.PlayerUpgrades.RETAINING_WALL_LEFT: 0.0,
	Enums.PlayerUpgrades.RETAINING_WALL_RIGHT: 0.0,
}

signal credits_changed()
signal player_stat_changed(stat: Enums.PlayerStats, value: PlayerStat)
signal player_upgrade_changed(upgrade: Enums.PlayerUpgrades, value: float)

func _ready() -> void:
	SignalBus.credits_picked_up.connect(_on_credits_picked_up)
	
	# DEBUG TO ADD POWER!!!
	alter_player_stat(Enums.PlayerStats.TANK_SPEED, 200, 0, 0)
	alter_player_stat(Enums.PlayerStats.MAX_SHOTS, 200, 0, 0)
	alter_player_stat(Enums.PlayerStats.RELOAD, 0, 0, 12.0)
	alter_player_stat(Enums.PlayerStats.SHOT_POWER, 250, 0, 0)
	alter_player_stat(Enums.PlayerStats.SHOT_SPEED, 0, 0, 10)
	alter_player_stat(Enums.PlayerStats.PICKUP_AREA, 0, 0, 10)
	alter_player_stat(Enums.PlayerStats.CREDIT_MULTIPLIER, 25, 0, 0)
	alter_player_stat(Enums.PlayerStats.LUCK, 25, 0, 0)
	alter_player_stat(Enums.PlayerStats.MAX_LIFE, 20, 0, 0)
	
	alter_player_upgrade(Enums.PlayerUpgrades.AUTO_FIRE, 1.0)
	alter_player_upgrade(Enums.PlayerUpgrades.TWIN_CANNON, 1.0)
	alter_player_upgrade(Enums.PlayerUpgrades.RETAINING_WALL_LEFT, 1.0)
	alter_player_upgrade(Enums.PlayerUpgrades.RETAINING_WALL_RIGHT, 1.0)
	alter_player_upgrade(Enums.PlayerUpgrades.LASER_SIGHT, 1.0)
	
	call_deferred("_load_initial_level")

func get_player_stat(stat: Enums.PlayerStats) -> PlayerStat:
	return player_stats[stat]

func get_player_stat_curr_value(stat: Enums.PlayerStats) -> float:
	return get_player_stat(stat).current_value

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

func pay_credits(amount: float) -> bool:
	if credits >= amount:
		credits -= amount
		credits_changed.emit()
		return true
	return false

func alter_player_stat(stat: Enums.PlayerStats, hard_bonus_delta: float, soft_bonus_delta: float, \
	percentile_bonus_delta: float) -> void:
	var player_stat := player_stats[stat]
	player_stat.hard_bonus += hard_bonus_delta
	player_stat.soft_bonus += soft_bonus_delta
	player_stat.percent_modifier += percentile_bonus_delta
	player_stat.current_level += 1
	player_stat_changed.emit(stat, player_stat)

func _on_credits_picked_up(amt: float) -> void:
	credits += (amt * player_stats[Enums.PlayerStats.CREDIT_MULTIPLIER].percent_modifier)
	credits_changed.emit()

func get_player_stat_upgrade_cost(level: int, upgrade: Enums.PlayerStats) -> int:
	var times_upgraded := level - 1.0
	
	match upgrade:
		Enums.PlayerStats.TANK_SPEED: return ceil(30 * pow(1.3, times_upgraded))
		Enums.PlayerStats.MAX_SHOTS: return ceil(10 * pow(1.25, times_upgraded))
		Enums.PlayerStats.RELOAD: return ceil(5 * pow(1.5, times_upgraded))
		Enums.PlayerStats.SHOT_POWER: return ceil(12 * pow(1.2, times_upgraded))
		Enums.PlayerStats.SHOT_SPEED: return ceil(25 * pow(1.3, times_upgraded))
		Enums.PlayerStats.PICKUP_AREA: return ceil(20 * pow(1.5, times_upgraded))
		Enums.PlayerStats.CREDIT_MULTIPLIER: return ceil(5 * pow(1.7, times_upgraded))
		Enums.PlayerStats.TELEPORT_DELAY: return ceil(8 * pow(1.17, times_upgraded))
		Enums.PlayerStats.LUCK: return ceil(7 * pow(1.55, times_upgraded))
		Enums.PlayerStats.MAX_LIFE: return ceil(50 * pow(1.55, times_upgraded))
	return 42069

func get_player_upgrade_upgrade_cost(level: float, upgrade: Enums.PlayerUpgrades) -> int:
	var times_upgraded := level - 1.0
	
	match upgrade:
		Enums.PlayerUpgrades.AUTO_FIRE: return 75
		Enums.PlayerUpgrades.LASER_SIGHT: return 80
		Enums.PlayerUpgrades.RETAINING_WALL_LEFT: return 125
		Enums.PlayerUpgrades.RETAINING_WALL_RIGHT: return 125
		Enums.PlayerUpgrades.TWIN_CANNON: return 500
		Enums.PlayerUpgrades.ANTI_AIR: return ceil(300 * pow(1.75, times_upgraded))
		Enums.PlayerUpgrades.MISSILES: return ceil(150 * pow(1.75, times_upgraded))
	
	return 42069

## Adds the specified delta to the player upgrade.
func alter_player_upgrade(upgr: Enums.PlayerUpgrades, delta: float) -> void:
	player_upgrades[upgr] += delta
	player_upgrade_changed.emit(upgr, player_upgrades[upgr])

## Returns the specified upgrade value.
func get_player_upgrade(upgr: Enums.PlayerUpgrades) -> float:
	return player_upgrades[upgr]

## Returns true if the specified upgrade is not 0.0.
func has_upgrade(upgr: Enums.PlayerUpgrades) -> bool:
	return get_player_upgrade(upgr) != 0.0
