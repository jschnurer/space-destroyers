extends CanvasLayer

var _enabled := false

@onready var debug_log: RichTextLabel = %DebugLog
@onready var debug_input: LineEdit = %DebugInput

const _help_text: String = \
"[color=yellow]addstat STAT 0[/color]: adds the specified levels to a stat
[color=yellow]addupgrade UPGRADE 0[/color]: adds the specified levels to an upgrade
[color=yellow]collect[/color]: collects all visible credits
[color=yellow]credits 0000[/color]: pick up specified number of credits (multiplier affects)
[color=yellow]goto type num[/color]: skips to indicated level type/num (type: invader/space) (num: 1-9)
[color=yellow]help[/color]: show this message
[color=yellow]max[/color]: maxes all stats and upgrades
[color=yellow]maxstats[/color]: maxes all stats
[color=yellow]maxupgrades[/color]: maxes all upgrades
[color=yellow]nuke[/color]: destroy all enemies
[color=yellow]pass[/color]: destroy all enemies, collect their coins, go to next level immediately
[color=yellow]resume[/color]: force-unpauses the game (in case you broke something with the debug console)
[color=yellow]setallstats 0[/color]: sets all stats to a level
[color=yellow]setstat STAT 0[/color]: sets a stat to a level
[color=yellow]setupgrade UPGRADE 0[/color]: sets an upgrade to a level
[color=yellow]shop[/color]: as pass but show the show between levels"

var _valid_input_history: Array[String]
var _history_index := -1

func _ready() -> void:
	visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_console"):
		_toggle_enabled()
		return
	
func _toggle_enabled() -> void:
	_enabled = !_enabled
	visible = _enabled
	debug_input.editable = _enabled
	
	if _enabled:
		PauseManager.pause()
		debug_input.grab_focus()
		debug_input.set_caret_column(debug_input.text.length())
	else:
		PauseManager.resume()

func _log(msg: String) -> void:
	debug_log.append_text("\n")
	debug_log.append_text(msg)

func _on_debug_input_text_submitted(new_text: String) -> void:
	if new_text == "":
		return
	
	_log("> [color=white]" + new_text + "[/color]")
	_prepend_command_history(new_text)
	_history_index = -1
	
	debug_input.clear()
	
	var text_chunks := new_text.split(" ")
	var cmd := text_chunks[0]
	
	match cmd:
		"collect": _collect_credits()
		"help": _output_help()
		"nuke": _nuke_enemies()
		"pass": _pass_level(false)
		"shop": _pass_level(true)
		"credits": _add_credits(text_chunks)
		"goto": _go_to_level(text_chunks)
		"resume": PauseManager.resume(true)
		"addstat": _add_stat(text_chunks)
		"setstat": _set_stat(text_chunks)
		"setallstats": _set_all_stats(text_chunks)
		"addupgrade": _add_upgrade(text_chunks)
		"setupgrade": _set_upgrade(text_chunks)
		"max": _max_out(true, true)
		"maxstats": _max_out(true, false)
		"maxupgrades": _max_out(false, true)
		_: _log("[color=red]Invalid command[/color]")

## Disable entering `.
func _on_debug_input_text_changed(new_text: String) -> void:
	if new_text.contains("`"):
		debug_input.text = new_text.replace("`", "")

func _output_help() -> void:
	_log(_help_text)

## Kills all enemies.
func _nuke_enemies() -> void:
	for en in get_tree().get_nodes_in_group(GroupNames.ENEMY):
		var lc: LifeComponent = Utilities.get_first_child_of_type(en, LifeComponent)
		if lc:
			lc.take_damage(99999999.0, null)

## Deletes enemies, collects their credits, and optionally shows the shop or goes to next level immediately.
func _pass_level(show_shop: bool) -> void:
	var total_credits := 0.0
	for en in get_tree().get_nodes_in_group(GroupNames.ENEMY):
		var od: OnDeathComponent = (en as Enemy).get_component(OnDeathComponent)
		if od:
			total_credits += od.get_total_credit_value()
		en.queue_free()
		
	var mult := Game.get_stat_value(Enums.PlayerStats.CREDIT_MULTIPLIER)
	SignalBus.emit_credits_picked_up(total_credits * mult)
	Game.load_next_level(!show_shop)

## Picks up credits (multiplier is applied).
func _add_credits(text_chunks: Array[String]) -> void:
	if text_chunks.size() == 1:
		_log("[color=red]How many credits? (e.g. 'credits 0000')[/color]")
	elif text_chunks[1].is_valid_float():
		var creds := text_chunks[1].to_float()
		if creds <= 0.0:
			_log("[color=red]Invalid credit amount.[/color]")
			return
		_log("Picked up %s credits" % str(creds))
		SignalBus.emit_credits_picked_up(creds)

## Goes to a specific level.
func _go_to_level(text_chunks: Array[String]) -> void:
	var err_msg := "[color=red]Go to which level? (e.g. 'goto invader 1', 'goto space 3')[/color]"
	
	if text_chunks.size() < 3:
		_log(err_msg)
		return
	
	var level_type := text_chunks[1].to_upper()
	if level_type not in Enums.LevelTypes:
		var keys := Enums.LevelTypes.keys()
		_log("[color=red]Invalid level type. Valid types: %s[/color]" % str(keys))
		return
	var lvl_type: int = Enums.LevelTypes[level_type]
	
	var level_num_str := text_chunks[2]
	if !level_num_str.is_valid_int():
		_log(err_msg)
		return
	
	var level_num := level_num_str.to_int()
	Game.go_to_level(lvl_type, level_num)

func _collect_credits() -> void:
	var player := get_tree().get_first_node_in_group(GroupNames.PLAYER)
	if !player:
		return
	
	for c in get_tree().get_nodes_in_group(GroupNames.CREDIT):
		(c as Credit).start_pickup_sequence(player as Node2D)

func _add_stat(text_chunks: Array[String]) -> void:
	if text_chunks.size() < 3:
		_log("[color=red]Invalid arguments. (e.g. 'addstat RELOAD 5')[/color]")
		return
	
	var stat_name := text_chunks[1].to_upper()
	if stat_name not in Enums.PlayerStats:
		var keys := Enums.PlayerStats.keys()
		_log("[color=red]Invalid stat. Valid stats: %s[/color]" % str(keys))
		return
	var stat: int = Enums.PlayerStats[stat_name]
	
	if !text_chunks[2].is_valid_int():
		_log("[color=red]Invalid stat gain amount (ints only).[/color]")
		return
	
	var amt := text_chunks[2].to_int()
	if amt <= 0 or amt > 50:
		_log("[color=red]Invalid stat gain amount (1-50).[/color]")
		return
	
	while amt > 0:
		Game.improve_stat(stat)
		amt -= 1
	
	_log("+%s %s" % [text_chunks[2].to_int(), stat_name])

func _set_stat(text_chunks: Array[String]) -> void:
	if text_chunks.size() < 3:
		_log("[color=red]Invalid arguments. (e.g. 'setstat DAMAGE 31')[/color]")
		return
	
	var stat_name := text_chunks[1].to_upper()
	if stat_name not in Enums.PlayerStats:
		var keys := Enums.PlayerStats.keys()
		_log("[color=red]Invalid stat. Valid stats: %s[/color]" % str(keys))
		return
	var stat: int = Enums.PlayerStats[stat_name]
	
	if !text_chunks[2].is_valid_int():
		_log("[color=red]Invalid stat level (1 or higher only).[/color]")
		return
	
	var amt := text_chunks[2].to_int()
	if amt <= 0:
		_log("[color=red]Invalid stat level (1 or higher only).[/color]")
		return
	
	Game.set_stat(stat, amt)
	
	_log("%s set to level %s" % [text_chunks[2].to_int(), stat_name])

func _set_all_stats(text_chunks: Array[String]) -> void:
	if text_chunks.size() < 2:
		_log("[color=red]Invalid arguments. (e.g. 'setallstats 10')[/color]")
		return
	
	if !text_chunks[1].is_valid_int():
		_log("[color=red]Invalid stat level (1 or higher only).[/color]")
		return
	
	var amt := text_chunks[1].to_int()
	if amt <= 0:
		_log("[color=red]Invalid stat level (1 or higher only).[/color]")
		return
	
	var stat_values := Enums.PlayerStats.values()
	for s: int in stat_values:
		Game.set_stat(s, amt)
	
	_log("All stats set to level %s" % amt)

func _add_upgrade(text_chunks: Array[String]) -> void:
	if text_chunks.size() < 3:
		_log("[color=red]Invalid arguments. (e.g. 'addupgrade FULL_AUTO 5')[/color]")
		return
	
	var upgr_name := text_chunks[1].to_upper()
	if upgr_name not in Enums.PlayerUpgrades:
		var keys := Enums.PlayerUpgrades.keys()
		_log("[color=red]Invalid upgrade. Valid upgrades: %s[/color]" % str(keys))
		return
	var upgr: int = Enums.PlayerUpgrades[upgr_name]
	
	if !text_chunks[2].is_valid_int():
		_log("[color=red]Invalid upgrade gain amount (ints only).[/color]")
		return
	
	var amt := text_chunks[2].to_int()
	if amt <= 0 or amt > 50:
		_log("[color=red]Invalid upgrade gain amount (1-50).[/color]")
		return
	
	Game.alter_upgrade(upgr, amt)
	
	_log("+%s %s" % [amt, upgr_name])

func _set_upgrade(text_chunks: Array[String]) -> void:
	if text_chunks.size() < 3:
		_log("[color=red]Invalid arguments. (e.g. 'setupgrade MULTI_CANNON 4')[/color]")
		return
	
	var upgr_name := text_chunks[1].to_upper()
	if upgr_name not in Enums.PlayerUpgrades:
		var keys := Enums.PlayerUpgrades.keys()
		_log("[color=red]Invalid upgrade. Valid upgrades: %s[/color]" % str(keys))
		return
	var upgr: int = Enums.PlayerUpgrades[upgr_name]
	
	if !text_chunks[2].is_valid_int():
		_log("[color=red]Invalid upgrade level (0 or higher only).[/color]")
		return
	
	var amt := text_chunks[2].to_int()
	if amt < 0:
		_log("[color=red]Invalid upgrade level (0 or higher only).[/color]")
		return
	
	Game.set_upgrade(upgr, amt)
	
	_log("%s set to level %s" % [text_chunks[2].to_int(), upgr_name])

func _max_out(max_stats: bool, max_upgrades: bool) -> void:
	if max_stats:
		var stat_keys := Enums.PlayerStats.keys()
		for key: String in stat_keys:
			var stat: int = Enums.PlayerStats[key]
			Game.set_stat(stat, Game.get_stat(stat).max_level)
		_log("All stats maxed out!")
	
	if max_upgrades:
		var upgr_keys := Enums.PlayerUpgrades.keys()
		for key: String in upgr_keys:
			var upgr: int = Enums.PlayerUpgrades[key]
			Game.set_upgrade(upgr, Game.get_upgrade(upgr).max_level)
		_log("All upgrades maxed out!")

func _prepend_command_history(cmd: String) -> void:
	_valid_input_history.push_front(cmd)
	if _valid_input_history.size() > 50:
		_valid_input_history.resize(50)

func _on_debug_input_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var ev: InputEventKey = event
		if ev.pressed and ev.keycode == KEY_UP:
			_alter_history_ix(1)
			# Don't bubble up.
			get_viewport().set_input_as_handled()
		elif ev.pressed and ev.keycode == KEY_DOWN:
			_alter_history_ix(-1)
			# Don't bubble up.
			get_viewport().set_input_as_handled()

func _alter_history_ix(delta: int) -> void:
	_history_index += delta
	_history_index = clampi(_history_index, -1, _valid_input_history.size() - 1)
	if _history_index == -1:
		debug_input.clear()
	else:
		debug_input.text = _valid_input_history[_history_index]
