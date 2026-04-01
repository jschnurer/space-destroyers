extends Node

var level_holder: Node2D

var game_state: GameState

signal credits_changed(new_credits: float)
signal stat_changed(changed_stat: Stat)
signal upgrade_changed(changed_upgrade: Upgrade)
signal current_life_changed(new_life: int)

func _ready() -> void:
	game_state = GameState.new()
	process_mode = Node.PROCESS_MODE_ALWAYS
	SignalBus.credits_picked_up.connect(_on_credits_picked_up)
	SignalBus.game_over.connect(_on_game_over)
	
	if get_tree().current_scene.name == "Main":
		call_deferred("restart_game")

func _load_initial_level() -> void:
	get_tree().paused = true
	game_state.current_level = 1
	var level_filename := "res://scenes/levels/level_" + str(game_state.current_level) + ".tscn"
	if !FileAccess.file_exists(level_filename):
		print("Level file not found! " + level_filename)
		return
	
	var next_level: PackedScene = load(level_filename)
	if next_level:
		level_holder.add_child(next_level.instantiate())
	
	
	var screen_fader: ScreenFader = get_tree().get_first_node_in_group("SCREEN_FADER")
	await screen_fader.fade_in()
	get_tree().paused = false
	SignalBus.emit_new_level_loaded()

## Loads the next level sequentially.
func load_next_level() -> void:
	get_tree().paused = true
	game_state.current_level += 1
	
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
		await screen_fader.fade_out()
		SignalBus.emit_level_transition_screen_faded()
	
	SignalBus.emit_open_shop()
	await SignalBus.shop_closed
	
	var level_filename := "res://scenes/levels/level_" + str(game_state.current_level) + ".tscn"
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
		await screen_fader.fade_in()
		
	if teleport_anim and player_tank:
		# Play the animation and then wait for it to complete.
		teleport_anim.teleport_in()
		await teleport_anim.animation_complete
		player_tank.visible = true
	
	get_tree().paused = false
	SignalBus.emit_new_level_loaded()

func _on_credits_picked_up(amt: float) -> void:
	game_state.credits += (amt * get_stat_value(Enums.PlayerStats.CREDIT_MULTIPLIER))
	credits_changed.emit(game_state.credits)

## If the player has enough credits, decrement the credits and return true. Otherwise, return false.
func pay_credits(amount: float) -> bool:
	if game_state.credits >= amount:
		game_state.credits -= amount
		credits_changed.emit(game_state.credits)
		return true
	return false

## Gets a stat.
func get_stat(stat: Enums.PlayerStats) -> Stat:
	return game_state.stats[stat]

## Gets the current value of a stat.
func get_stat_value(stat: Enums.PlayerStats) -> float:
	return get_stat(stat).get_current_value()

## Adds the delta to the player stat.
func alter_stat(p_stat: Enums.PlayerStats, point_delta: float, percent_bonus_delta: float) -> void:
	var stat := game_state.stats[p_stat]
	stat.point_bonus += point_delta
	stat.percent_bonus += percent_bonus_delta
	stat.level += 1
	stat_changed.emit(stat)
	
## Adds the delta to the player int stat.
func alter_stat_int(p_stat: Enums.PlayerStats, point_delta: int) -> void:
	var stat := game_state.stats[p_stat]
	stat.point_bonus_int += point_delta
	stat.level += 1
	stat_changed.emit(stat)
	
	# Special, for LIFE only. When increasing max life, also increase current life.
	if p_stat == Enums.PlayerStats.LIFE:
		game_state.current_life += point_delta
		current_life_changed.emit(game_state.current_life)

## Returns the specified upgrade value.
func get_upgrade(upgr: Enums.PlayerUpgrades) -> Upgrade:
	return game_state.upgrades[upgr]

## Returns the upgrade's current level.
func get_upgrade_level(upgr: Enums.PlayerUpgrades) -> int:
	return get_upgrade(upgr).level

## Returns true if the specified upgrade is not 0.0.
func has_upgrade(upgr: Enums.PlayerUpgrades) -> bool:
	return get_upgrade(upgr).level > 0

## Adds the specified delta to the player upgrade.
func alter_upgrade(upgr: Enums.PlayerUpgrades, delta_points: float) -> void:
	if game_state.upgrades[upgr].is_maxed():
		return
	
	game_state.upgrades[upgr].level += 1
	game_state.upgrades[upgr].point_bonus += delta_points
	upgrade_changed.emit(game_state.upgrades[upgr])

func _on_game_over(_reason: Enums.GameOverReason) -> void:
	for child in level_holder.get_children():
		child.queue_free()

func restart_game() -> void:
	game_state = GameState.new()
	
	# DEBUG TO ADD POWER!!!
	#credits = 55
	#game_state.credits = 999999999
	
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
	
	#var multi_cannon := game_state.upgrades[Enums.PlayerUpgrades.MULTI_CANNON]
	#multi_cannon.level = 3
	
	#var flak := game_state.upgrades[Enums.PlayerUpgrades.FLAK_CANNON]
	#flak.level = 1
	
	SignalBus.emit_play_bgm(load("res://audio/bgm/moonlight.mp3") as AudioStream, 1.0, 1.0, 0.0, 1.0)
	_load_initial_level()

func set_current_life(new_life: int) -> void:
	if game_state.current_life != new_life:
		game_state.current_life = new_life
		current_life_changed.emit(new_life)
