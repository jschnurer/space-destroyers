extends Node

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
func emit_play_sfx(stream: AudioStream, volume_linear: float = 1.0, pitch_scale: float = 1.0, sfx_type: SfxPlayer.SfxType = SfxPlayer.SfxType.GAME) -> void:
	play_sfx.emit(stream, volume_linear, pitch_scale, sfx_type)

signal stop_sfx(type: SfxPlayer.SfxType)
func emit_stop_sfx(type: SfxPlayer.SfxType) -> void:
	stop_sfx.emit(type)

signal game_over(game_over_reason: Enums.GameOverReason)
func emit_game_over(game_over_reason: Enums.GameOverReason) -> void:
	game_over.emit(game_over_reason)

signal fade_out_screen()
func emit_fade_out_screen() -> void:
	fade_out_screen.emit()

signal fade_in_screen()
func emit_fade_in_screen() -> void:
	fade_in_screen.emit()

signal fade_out_complete()
func emit_fade_out_complete() -> void:
	fade_out_complete.emit()

signal fade_in_complete()
func emit_fade_in_complete() -> void:
	fade_in_complete.emit()
