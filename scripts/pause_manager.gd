extends Node

var pause_requests := 0

func pause() -> void:
	pause_requests += 1
	_update_pause_state()

func resume() -> void:
	pause_requests = max(0, pause_requests - 1)
	_update_pause_state()

func _update_pause_state() -> void:
	get_tree().paused = pause_requests > 0
