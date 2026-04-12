@tool
extends CenterContainer

@export var upgrade: Upgrade:
	set(value):
		upgrade = value
		($HBoxContainer/Label as Label).text = value.display_text
	get():
		return upgrade
		
@export var show_plus: bool = false:
	set(value):
		show_plus = value
		_toggle_plus()
	get():
		return show_plus

@export var show_level_number: bool = false:
	set(value):
		show_level_number = value
		_toggle_num_visibility()
	get():
		return show_level_number

@onready var value_label: Label = $HBoxContainer/ValueLabel

func _ready() -> void:
	if !Engine.is_editor_hint():
		visible = false
		Game.upgrade_changed.connect(_on_upgrade_changed)
		_on_upgrade_changed(Game.get_upgrade(upgrade.upgrade))

func _on_upgrade_changed(upgr: Upgrade) -> void:
	if upgr.upgrade == upgrade.upgrade and upgr.level > 0:
		visible = true
		value_label.text = ("+" if show_plus else "") + str(upgr.level)

func _toggle_plus() -> void:
	($HBoxContainer/ValueLabel as Label).text = ("+" if show_plus else "") + "0"

func _toggle_num_visibility() -> void:
	($HBoxContainer/ValueLabel as Label).visible = show_level_number
	($HBoxContainer/Label as Label).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if !show_level_number else HORIZONTAL_ALIGNMENT_LEFT
