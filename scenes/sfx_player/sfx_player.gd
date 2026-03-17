extends Node
class_name SfxPlayer

@export var sfx_player_type: SfxType
@export var channels := 8

var audio_players: Array[AudioStreamPlayer]

enum SfxType {
	GAME = 0,
	SYSTEM = 1,
}

func _ready() -> void:
	SignalBus.play_sfx.connect(_on_play_sfx)
	SignalBus.stop_sfx.connect(_on_stop_sfx)
	
	for i in range(channels):
		var player := AudioStreamPlayer.new()
		player.process_mode = Node.PROCESS_MODE_ALWAYS if sfx_player_type == SfxType.SYSTEM else Node.PROCESS_MODE_PAUSABLE
		add_child(player)
		audio_players.append(player)

func _on_play_sfx(stream: AudioStream, volume_linear: float, pitch_scale: float, sfx_type: SfxType) -> void:
	if sfx_type != sfx_player_type:
		# Wrong type. Do not handle.
		return
	
	var player := _get_audio_player()
	
	if not player:
		return
	
	player.stop()
	player.stream = stream
	player.volume_linear = volume_linear
	player.pitch_scale = pitch_scale
	player.play()

func _get_audio_player() -> AudioStreamPlayer:
	var max_play_percent := 0.0
	var oldest_player: AudioStreamPlayer
	
	for p in audio_players:
		if !p.playing:
			return p
		var progress := p.get_playback_position() / p.stream.get_length()
		if progress > max_play_percent:
			max_play_percent = progress
			oldest_player = p
	
	return oldest_player

func _on_stop_sfx(type: SfxType) -> void:
	if type != sfx_player_type:
		return
	
	for p in audio_players:
		p.stop()
