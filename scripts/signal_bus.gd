extends Node
class_name SignalBusType

signal enemy_hit_screen_edge(edge: Enums.ScreenEdges)
func emit_enemy_hit_screen_edge(edge: Enums.ScreenEdges) -> void:
	enemy_hit_screen_edge.emit(edge)

signal enemy_died(enemy: Node2D)
func emit_enemy_died(enemy: Node2D) -> void:
	enemy_died.emit(enemy)

signal enemy_speed_change(new_speed: float)
func emit_enemy_speed_change(new_speed: float) -> void:
	enemy_speed_change.emit(new_speed)

signal enemy_direction_change(new_dir: Vector2, drop_down: bool)
func emit_enemy_direction_change(new_dir: Vector2, drop_down: bool) -> void:
	enemy_direction_change.emit(new_dir, drop_down)

signal enemy_landed()
func emit_enemy_landed() -> void:
	enemy_landed.emit()

signal credits_picked_up(value: float)
func emit_credits_picked_up(value: float) -> void:
	credits_picked_up.emit(value)

signal start_teleporting()
func emit_start_teleporting() -> void:
	start_teleporting.emit()

signal level_transition_screen_faded()
func emit_level_transition_screen_faded() -> void:
	level_transition_screen_faded.emit()

signal new_level_loaded()
func emit_new_level_loaded() -> void:
	new_level_loaded.emit()

signal open_shop()
func emit_open_shop() -> void:
	open_shop.emit()

signal shop_closed()
func emit_shop_closed() -> void:
	shop_closed.emit()

signal play_bgm(stream: AudioStream, volume_linear: float, pitch_scale: float, fade_out_duration: float, fade_in_duration: float)
func emit_play_bgm(stream: AudioStream, volume_linear: float = 1.0, pitch_scale: float = 1.0, fade_out_duration: float = 0.0, fade_in_duration: float = 0.0) -> void:
	play_bgm.emit(stream, volume_linear, pitch_scale, fade_out_duration, fade_in_duration)

signal fade_out_bgm(fade_duration: float)
func emit_fade_out_bgm(fade_duration: float) -> void:
	fade_out_bgm.emit(fade_duration)

signal play_sfx(stream: AudioStream, volume_linear: float, pitch_scale: float, sfx_type: SfxPlayer.SfxType)
func emit_play_sfx(stream: AudioStream, volume_linear: float = 1.0, pitch_scale: float = 1.0, sfx_type: SfxPlayer.SfxType = SfxPlayer.SfxType.SYSTEM) -> void:
	play_sfx.emit(stream, volume_linear, pitch_scale, sfx_type)

signal stop_sfx(type: SfxPlayer.SfxType)
func emit_stop_sfx(type: SfxPlayer.SfxType) -> void:
	stop_sfx.emit(type)

signal game_over(game_over_reason: Enums.GameOverReason)
func emit_game_over(game_over_reason: Enums.GameOverReason) -> void:
	game_over.emit(game_over_reason)

signal fade_out_screen(duration: float)
func emit_fade_out_screen(duration: float = 1.0, color: Color = Color.BLACK) -> void:
	fade_out_screen.emit(duration, color)

signal fade_in_screen(duration: float)
func emit_fade_in_screen(duration: float = 1) -> void:
	fade_in_screen.emit(duration)

signal flash_screen(color: Color, fade_dur: float)
func emit_flash_screen(color: Color, fade_dur: float = 0.15) -> void:
	flash_screen.emit(color, fade_dur)

signal fade_out_screen_complete()
func emit_fade_out_complete() -> void:
	fade_out_screen_complete.emit()

signal fade_in_screen_complete()
func emit_fade_in_complete() -> void:
	fade_in_screen_complete.emit()

signal toggle_mouse_visibility(allow_visible: bool)
func emit_toggle_mouse_visibility(allow_visible: bool) -> void:
	toggle_mouse_visibility.emit(allow_visible)

signal toggle_player_shoot_ability(is_enabled: bool)
func emit_toggle_player_shoot_ability(is_enabled: bool) -> void:
	toggle_player_shoot_ability.emit(is_enabled)

signal clear_enemy_attacks()
func emit_clear_enemy_attacks() -> void:
	clear_enemy_attacks.emit()

signal toggle_options(enabled: bool)
func emit_toggle_options(enabled: bool) -> void:
	toggle_options.emit(enabled)
