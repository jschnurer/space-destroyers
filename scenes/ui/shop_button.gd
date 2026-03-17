@tool
extends Button
class_name ShopButton

@export var btn_text: String:
	set(value):
		btn_text = value
		update_label_and_cost()
@export var hover_text: String
@export var purchase_sfx: AudioStream

@export var is_player_stat := false
@export var is_player_upgrade := false

@export_group("Player Stat")
@export var player_stat: Enums.PlayerStats
@export var hard_bonus_delta: float
@export var soft_bonus_delta: float
@export var percentile_bonus_delta: float

@export_group("Player Upgrade")
@export var player_upgrade: Enums.PlayerUpgrades
@export var max_upgrade_value := 1.0

var upgrade_cost: int = 999

func _ready() -> void:
	update_label_and_cost()
	if !Engine.is_editor_hint():
		GameManager.credits_changed.connect(update_label_and_cost)

func _on_pressed() -> void:
	var count := 1
	if Input.is_action_pressed("buy_5"): count = 5
	
	var any_bought := false
	
	for i in range(count):
		if is_player_upgrade and GameManager.get_player_upgrade(player_upgrade) >= max_upgrade_value:
			break
		
		if GameManager.pay_credits(upgrade_cost):
			if is_player_stat:
				GameManager.alter_player_stat(player_stat, hard_bonus_delta, soft_bonus_delta, percentile_bonus_delta)
			elif is_player_upgrade:
				GameManager.alter_player_upgrade(player_upgrade, 1.0)
			
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
			var ps := GameManager.get_player_stat(player_stat)
			upgrade_cost = GameManager.get_player_stat_upgrade_cost(ps.current_level + 1, player_stat)
			label.text = "%s\n[$%s]" % [btn_text, str(upgrade_cost)]
		elif is_player_upgrade:
			var pu := GameManager.get_player_upgrade(player_upgrade)
			upgrade_cost = GameManager.get_player_upgrade_upgrade_cost(pu + 1, player_upgrade)
			if GameManager.get_player_upgrade(player_upgrade) >= max_upgrade_value:
				label.text = "%s\n[SOLD OUT]" % btn_text
			else:
				label.text = "%s\n[$%s]" % [btn_text, str(upgrade_cost)]
		else:
			label.text = "BTN ERROR"
			return
		
		(label as ShopButtonLabel).update_font_size()
	
	if !Engine.is_editor_hint():
		if is_player_stat:
			disabled = upgrade_cost > GameManager.credits
		elif is_player_upgrade:
			var upgr_val := GameManager.get_player_upgrade(player_upgrade)
			disabled = upgr_val >= max_upgrade_value
		else:
			disabled = false
	else:
		disabled = false
