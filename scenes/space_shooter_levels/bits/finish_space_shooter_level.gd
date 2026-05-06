extends Node2D
class_name FinishSpaceShooterLevel

@export var jet_burst_stream: AudioStream

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	_play_exit_scene()

func _play_exit_scene() -> void:
	var player: Spaceship = get_tree().get_first_node_in_group(GroupNames.PLAYER)
	if !player:
		return
		
	PauseManager.pause()
	
	# Allow exiting the screen.
	player.toggle_allow_exit_screen(true)
	
	# Jet burst!
	player.toggle_smoke_emission(true)
	SignalBus.emit_play_sfx(jet_burst_stream, .85, 0.175)
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.set_parallel(true)
	
	tween.tween_property(player, "global_position:y", -1080, 3.0)
	
	# Enable player's position history component so it keeps recording positions.
	var pos_hist: PositionHistoryComponent = Utilities.get_first_child_of_type(player, PositionHistoryComponent)
	if pos_hist:
		pos_hist.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Also enable all the options so they continue following the player.
	var opt_spawn: PlayerOptionSpawnComponent = \
		Utilities.get_first_child_of_type(player, PlayerOptionSpawnComponent)
	var player_options: Array[Node2D]
	if opt_spawn:
		player_options = opt_spawn._get_options()
		for opt in player_options:
			opt.process_mode = Node.PROCESS_MODE_ALWAYS
	
	var starfield: Starfield = get_tree().get_first_node_in_group(GroupNames.STAR_FIELD)
	if starfield:
		tween.tween_property(starfield, "animate_speed", 4000, 3.0)
	
	tween.finished.connect(_exit_done.bind(pos_hist, player_options))

func _exit_done(pos_hist: PositionHistoryComponent, player_options: Array[Node2D]) -> void:
	pos_hist.process_mode = Node.PROCESS_MODE_INHERIT
	
	for opt in player_options:
		opt.process_mode = Node.PROCESS_MODE_INHERIT
	PauseManager.resume()
	Game.load_next_level()
