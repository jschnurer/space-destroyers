extends Node
class_name GameManager

## Folder containing all the levels_X.tscn files for invaders levels.
static var invaders_levels_folder := "res://scenes/invaders_levels/"
## Scene file for the main menu.
static var main_menu_scene_path := "res://scenes/ui/main_menu/main_menu.tscn"

## Level holder node to replace the current level in (from invaders_levels and shooter_levels).
var level_holder: Node2D
## The current game state data.
var game_state: GameState

## Emitted when the player's number of credits is changed (spent or picked up).
signal credits_changed(new_credits: float)
## Emitted when a player's stat changes (purchased).
signal stat_changed(changed_stat: Stat)
## Emitted when a player's upgrade changes (purchased).
signal upgrade_changed(changed_upgrade: Upgrade)
## Emitted when a player's current life changes (increased or damaged).
signal current_life_changed(new_life: int)

func _ready() -> void:
	game_state = GameState.new()
	process_mode = Node.PROCESS_MODE_ALWAYS
	SignalBus.credits_picked_up.connect(_on_credits_picked_up)
	SignalBus.game_over.connect(_on_game_over)
	
	# TODO: Remove this and load first level via main menu instead.
	if get_tree().current_scene.name == "InvadersLevels":
		call_deferred("restart_game")

## Loads the initial level of the invaders levels.
func load_initial_level() -> void:
	get_tree().paused = true
	game_state.current_level = 1
	var level_filename := _get_invaders_level_path(game_state.current_level)
	if !FileAccess.file_exists(level_filename):
		print("Level file not found! " + level_filename)
		return
	
	var next_level: PackedScene = load(level_filename)
	if next_level:
		level_holder.add_child(next_level.instantiate())
	
	SignalBus.emit_new_level_loaded()

## Loads the next level sequentially.
func load_next_level(instantly := false) -> void:
	get_tree().paused = true
	game_state.current_level += 1
	
	for child in level_holder.get_children():
		child.queue_free()
	
	var player_tank: Tank = get_tree().get_first_node_in_group("PLAYER")
	var teleport_anim: TeleportAnimation = get_tree().get_first_node_in_group("TELEPORT_ANIM")
	
	if !instantly:
		# Play the animation and then wait for it to complete.
		teleport_anim.global_position = player_tank.global_position
		teleport_anim.teleport_out()
		await teleport_anim.animation_complete
		
		SignalBus.emit_fade_out_screen()
		await SignalBus.fade_out_screen_complete
		SignalBus.emit_level_transition_screen_faded()
		
		SignalBus.emit_open_shop()
		await SignalBus.shop_closed
	
	var level_filename := _get_invaders_level_path(game_state.current_level)
	if !FileAccess.file_exists(level_filename):
		print("Level file not found! " + level_filename)
		return
		
	var next_level: PackedScene = load(level_filename)
	if next_level:
		level_holder.add_child(next_level.instantiate())
	
	# Snap player back to center.
	var tank_sprite_rect := player_tank.get_scaled_sprite_rect()
	player_tank.global_position.x = Global.PLAYABLE_AREA_RECT.size.x / 2.0 \
		+ Global.PLAYABLE_AREA_RECT.position.x\
		- tank_sprite_rect.size.x / 2.0
	
	if !instantly:
			teleport_anim.global_position = player_tank.global_position
			SignalBus.emit_fade_in_screen()
	
	if !instantly:
		# Play the animation and then wait for it to complete.
		teleport_anim.teleport_in()
		await teleport_anim.animation_complete
		player_tank.visible = true
	
	get_tree().paused = false
	SignalBus.emit_new_level_loaded()

## Jumps to specified level.
func go_to_level(lvl_num: int) -> void:
	if get_tree().current_scene.name != "invaders_levels":
		get_tree().change_scene_to_file(invaders_levels_folder + "invaders_levels.tscn")
		await get_tree().scene_changed
		SignalBus.emit_play_bgm(load("res://audio/bgm/moonlight.mp3") as AudioStream)
	
	# Decrement one because load_next_level increments.
	game_state.current_level = lvl_num - 1
	load_next_level(true)

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

func improve_stat(p_stat: Enums.PlayerStats) -> void:
	var stat := get_stat(p_stat)
	
	stat.level += 1
	stat.point_bonus += stat.value_per_level
	stat.point_bonus_int += stat.int_value_per_level
	stat.percent_bonus += stat.pct_bonus_per_level
	
	# Special, for LIFE only. When increasing max life, also increase current life.
	if p_stat == Enums.PlayerStats.LIFE:
		game_state.current_life += stat.int_value_per_level
		current_life_changed.emit(game_state.current_life)
	
	stat_changed.emit(stat)

### Adds the delta to the player stat.
#func alter_stat(p_stat: Enums.PlayerStats, point_delta: float, percent_bonus_delta: float) -> void:
	#var stat := game_state.stats[p_stat]
	#stat.point_bonus += point_delta
	#stat.percent_bonus += percent_bonus_delta
	#stat.level += 1
	#stat_changed.emit(stat)
	#
### Adds the delta to the player int stat.
#func alter_stat_int(p_stat: Enums.PlayerStats, point_delta: int) -> void:
	#var stat := game_state.stats[p_stat]
	#stat.point_bonus_int += point_delta
	#stat.level += 1
	#stat_changed.emit(stat)
	#
	## Special, for LIFE only. When increasing max life, also increase current life.
	#if p_stat == Enums.PlayerStats.LIFE:
		#game_state.current_life += point_delta
		#current_life_changed.emit(game_state.current_life)

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

## Fades out the screen, clears the game state, sends player to main menu.
func restart_game() -> void:
	SignalBus.emit_fade_out_screen()
	await SignalBus.fade_out_screen_complete
	game_state = GameState.new()
	get_tree().change_scene_to_file(main_menu_scene_path)

## Updates the player's current life to the new value and emits current_life_changed.
func set_current_life(new_life: int) -> void:
	if game_state.current_life != new_life:
		game_state.current_life = new_life
		current_life_changed.emit(new_life)

func _get_invaders_level_path(level_num: int) -> String:
	return invaders_levels_folder + "level_" + str(level_num) + ".tscn"
