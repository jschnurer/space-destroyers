extends CanvasLayer

var _enabled := false

@onready var debug_log: RichTextLabel = %DebugLog
@onready var debug_input: LineEdit = %DebugInput

const _help_text: String = "[color=yellow]collect[/color]: collects all visible credits
[color=yellow]credits 0000[/color]: pick up specified number of credits (multiplier affects)
[color=yellow]goto type num[/color]: skips to indicated level type/num (type: invader/space) (num: 1-9)
[color=yellow]help[/color]: show this message
[color=yellow]nuke[/color]: destroy all enemies
[color=yellow]pass[/color]: destroy all enemies, collect their coins, go to next level immediately
[color=yellow]resume[/color]: force-unpauses the game (in case you broke something with the debug console)
[color=yellow]shop[/color]: as pass but show the show between levels"

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
	
	var level_type := text_chunks[1]
	if level_type != "invader" and level_type != "space":
		_log(err_msg)
		return
	
	var level_num_str := text_chunks[2]
	if !level_num_str.is_valid_int():
		_log(err_msg)
		return
	
	var level_num := level_num_str.to_int()
	# TODO: Make this handle invader / space levels!
	Game.go_to_level(level_num)

func _collect_credits() -> void:
	var player := get_tree().get_first_node_in_group(GroupNames.PLAYER)
	if !player:
		return
	
	for c in get_tree().get_nodes_in_group(GroupNames.CREDIT):
		(c as Credit).start_pickup_sequence(player as Node2D)
