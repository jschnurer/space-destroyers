extends Node
class_name ReloadComponent

## The amount of time it takes to reload. Call `set_reload_time` to change it later.
@export var reload_time: float = 1.0

@export_group("Randomizer")
@export var use_random_reload_time := false
@export var min_reload_time: float = 1.0
@export var max_reload_time: float = 1.0

## Emitted when the reload starts.
signal reload_started
## Emitted when the reload completes.
signal reload_complete

@onready var reload_timer: Timer = %ReloadTimer

var _is_reloading := false

## Updates the reload wait time.
func set_reload_time(value: float) -> void:
	reload_time = value
	reload_timer.wait_time = value

func set_random_reload_time(min_time: float, max_time: float) -> void:
	min_reload_time = min_time
	max_reload_time = max_time
	_update_random_timer()

func _update_random_timer() -> void:
	if use_random_reload_time:
		reload_timer.wait_time = randf_range(minf(min_reload_time, max_reload_time), \
			maxf(min_reload_time, max_reload_time))

## Returns whether the component is reloading or not.
func is_reloading() -> bool:
	return _is_reloading

## Begins the reload timer.
func reload() -> void:
	if !_is_reloading:
		_is_reloading = true
		if use_random_reload_time:
			_update_random_timer()
		else:
			reload_timer.wait_time = reload_time
		reload_timer.start()
		reload_started.emit()

## Gets the current reload progress (or 0.0 if not reloading). Returns 0.0 to 1.0.
func get_reload_progress() -> float:
	if !_is_reloading:
		return 0.0
	
	return 1.0 - (reload_timer.time_left / reload_timer.wait_time)

func _on_reload_timer_timeout() -> void:
	_is_reloading = false
	reload_complete.emit()
	if use_random_reload_time:
		reload_timer.wait_time = randf_range(min_reload_time, max_reload_time)

func toggle(is_enabled: bool) -> void:
	# Pause the delay timer.
	reload_timer.paused = !is_enabled
