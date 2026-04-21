extends Node

var pause_requests := 0

## Requests to pause the game.
func pause() -> void:
	pause_requests += 1
	_update_pause_state()
	print_debug("Pause Request")

## Requests to resume the game. If force = true, FORCES game to resume regardless of any other
## script that wanted it paused.
func resume(force: bool = false) -> void:
	pause_requests = 0 if force else max(0, pause_requests - 1)
	_update_pause_state()
	print_debug("Resume Request")

func _update_pause_state() -> void:
	get_tree().paused = pause_requests > 0
