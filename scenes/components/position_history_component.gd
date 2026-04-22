extends Node
class_name PositionHistoryComponent

## The node to watch position for history.
@export var watch_node: Node2D

@export_group("By Position")
## The number of pixels the node must move to record a historical entry.
@export var deadzone: float
## The length of the position history in milliseconds.
@export var max_positions_remembered := 200

@export_group("By Input")
## If true, history is recorded as long as movement input is detected, even if the node doesn't
## change position.
@export var record_history_with_input := false

## The historical positions of the node.
var _position_history: Array[Vector2]
var _input_history_delay_timer := 0.0

func _physics_process(delta: float) -> void:
	if !watch_node:
		return
	
	if record_history_with_input and _input_history_delay_timer > 0:
		_input_history_delay_timer -= delta
	
	var added := false
	if !_position_history.size():
		_position_history.push_front(watch_node.global_position)
		added = true
	elif _position_history[0].distance_to(watch_node.global_position) > deadzone:
		_position_history.push_front(watch_node.global_position)
		added = true
		_input_history_delay_timer = 0
	elif record_history_with_input and _input_history_delay_timer <= 0:
		var input_vector := Input.get_vector("move_left", "move_right", "move_down", "move_up")
		if input_vector != Vector2.ZERO:
			_position_history.push_front(watch_node.global_position)
			_input_history_delay_timer = (1 / (Game.get_stat_value(Enums.PlayerStats.TANK_SPEED) * .25))
			added = true
	
	# If the position history array is 10x the max size, trim it down. (Set to 10x so as not to
	# resize an array every frame).
	if added and _position_history.size() > max_positions_remembered * 10:
		_position_history.resize(max_positions_remembered)

func get_position_at_history_index(index: int) -> Vector2:
	if _position_history.size() <= index:
		if _position_history.size() > 0:
			return _position_history[_position_history.size() - 1]
		else:
			return watch_node.global_position
	return _position_history[index]
