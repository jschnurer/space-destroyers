extends AudioStreamPlayer
class_name BGMPlayer

var _fade_volume_tween: Tween

func _ready() -> void:
	SignalBus.play_bgm.connect(_on_play_bgm)
	SignalBus.fade_out_bgm.connect(_on_fade_out_bgm)

func _on_play_bgm(p_stream: AudioStream, p_volume_linear: float, p_pitch_scale: float, fade_out_duration: float, fade_in_duration: float) -> void:
	if fade_out_duration > 0.0:
		await _on_fade_out_bgm(fade_out_duration)
	
	stop()
	stream = p_stream
	pitch_scale = p_pitch_scale
	
	if fade_in_duration == 0.0:
		volume_linear = p_volume_linear
		play()
	else:
		_fade_in_bgm(fade_in_duration, p_volume_linear)

func _on_fade_out_bgm(fade_duration: float) -> Signal:
	if _fade_volume_tween and _fade_volume_tween.is_running():
		_fade_volume_tween.kill()
	_fade_volume_tween = create_tween()
	_fade_volume_tween.tween_property(self, "volume_linear", 0.0, fade_duration)
	return _fade_volume_tween.finished

func _fade_in_bgm(fade_duration: float, to_volume_linear: float) -> Signal:
	if _fade_volume_tween and _fade_volume_tween.is_running():
		_fade_volume_tween.kill()
	volume_linear = 0.0
	_fade_volume_tween = create_tween()
	_fade_volume_tween.tween_property(self, "volume_linear", to_volume_linear, fade_duration)
	play()
	return _fade_volume_tween.finished
