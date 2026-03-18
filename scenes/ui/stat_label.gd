@tool
extends HBoxContainer

@export var stat: Stat:
	set(value):
		stat = value
		($Label as Label).text = value.display_text
		_update_value_label()

## Interpolated string to show in Value Label. [i](Make sure to include [b]%s[/b]!)[/i]
@export var interpolate_str: String:
	set(value):
		interpolate_str = value
		_update_value_label()
		
## Format string for the value of the stat.
@export var format_str: String = "%d":
	set(value):
		format_str = value
		_update_value_label()

## Ignores current value, shows only percent bonus.
@export var show_only_percent_bonus: bool:
	set(value):
		show_only_percent_bonus = value
		if Engine.is_editor_hint():
			update_configuration_warnings()
		_update_value_label()

## If true, the number used for display will be ceilinged first.
@export var round_to_int: bool

func _ready() -> void:
	if !Engine.is_editor_hint():
		GameManager.stat_changed.connect(_on_stat_changed)
		_on_stat_changed(GameManager.get_stat(stat.player_stat))

func _on_stat_changed(p_stat: Stat) -> void:
	if p_stat.player_stat == stat.player_stat:
		_update_value_label()

func _update_value_label() -> void:
	if interpolate_str and format_str and stat:
		if stat.player_stat == Enums.PlayerStats.PICKUP_AREA:
			print ("pickup")
			print (show_only_percent_bonus)
		
		if !Engine.is_editor_hint():
			var num := stat.percent_bonus * 100.0 if show_only_percent_bonus else stat.get_current_value()
			var int_num: int = roundi(num)
			
			if round_to_int:
				($ValueLabel as Label).text = interpolate_str % (format_str % int_num)
			else:
				($ValueLabel as Label).text = interpolate_str % (format_str % num)
		else:
			($ValueLabel as Label).text = interpolate_str % (format_str % 123.45)
	else:
		($ValueLabel as Label).text = "ERROR"
