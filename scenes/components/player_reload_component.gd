extends ReloadComponent
class_name PlayerReloadComponent

func _ready() -> void:
	_update_reload_time(Game.get_stat_value(Enums.PlayerStats.RELOAD))
	Game.stat_changed.connect(_on_stat_changed)

func _on_stat_changed(stat: Stat) -> void:
	match stat.player_stat:
		Enums.PlayerStats.RELOAD: _update_reload_time(stat.get_current_value())
	
func _update_reload_time(p_reload_time: float) -> void:
	set_reload_time(p_reload_time)
