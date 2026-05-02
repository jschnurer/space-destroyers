extends OrchestratedBehavior
class_name WaitBehavior

@export var wait_time: float

var _timer: Timer

func handle() -> Signal:
	if _timer:
		# If timer already exists, stop it first.
		_timer.stop()
	else:
		# Create a timer and connect its timeout to the signal.
		_timer = Timer.new()
		_timer.timeout.connect(_timer_timeout)
		add_child(_timer)
	
	# Set the timer's wait time and start it.
	_timer.wait_time = wait_time
	_timer.start()
	
	# Return the signal so it can be awaited.
	return behavior_complete

func _timer_timeout() -> void:
	_timer.queue_free()
	emit_behavior_complete()
