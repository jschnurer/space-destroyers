@tool
extends Button
class_name ShopButton

@export var btn_text: String:
	set(value):
		btn_text = value
		update_label_and_cost()
@export var purchase_sfx: AudioStream

@export var is_player_stat := false
@export var is_player_upgrade := false

@export_group("Player Stat")
@export var player_stat: Enums.PlayerStats

@export_group("Player Upgrade")
@export var player_upgrade: Enums.PlayerUpgrades

var upgrade_cost: int = 999

func _on_pressed() -> void:
	var count := 1
	if Input.is_action_pressed("buy_5"): count = 5
	
	var any_bought := false
	
	for i in range(count):
		if is_player_upgrade and Game.get_upgrade(player_upgrade).is_maxed():
			break
		
		if Game.pay_credits(upgrade_cost):
			if is_player_stat:
				Game.improve_stat(player_stat)
			elif is_player_upgrade:
				Game.alter_upgrade(player_upgrade, 1.0)
			
			update_label_and_cost()
			any_bought = true
		else:
			break
	
	if any_bought:
		SignalBus.emit_play_sfx(purchase_sfx, 1, 1, SfxPlayer.SfxType.SYSTEM)

func update_label_and_cost() -> void:
	if not is_inside_tree():
		return
	
	var label: Label = get_node_or_null("Label")
	if not label:
		return
	
	if Engine.is_editor_hint():
		label.text = "%s\n[$%s]" % [btn_text, "00000"]
	else:
		if is_player_stat:
			var stat := Game.get_stat(player_stat)
			if stat.is_maxed():
				label.text = "%s\n[SOLD OUT]" % btn_text
			else:
				upgrade_cost = stat.get_upgrade_cost()
				label.text = "%s\n[$%s]" % [btn_text, str(upgrade_cost)]
		elif is_player_upgrade:
			var pu := Game.get_upgrade(player_upgrade)
			upgrade_cost = pu.get_upgrade_cost()
			if pu.is_maxed():
				label.text = "%s\n[SOLD OUT]" % btn_text
			else:
				label.text = "%s\n[$%s]" % [btn_text, str(upgrade_cost)]
		else:
			label.text = "BTN ERROR"
			return
		
		(label as ShopButtonLabel).update_font_size()
	
	if !Engine.is_editor_hint():
		if is_player_upgrade:
			disabled = Game.get_upgrade(player_upgrade).is_maxed()\
				or upgrade_cost > Game.game_state.credits
		elif is_player_stat:
			disabled = Game.get_stat(player_stat).is_maxed()\
				or upgrade_cost > Game.game_state.credits
	else:
		disabled = false
