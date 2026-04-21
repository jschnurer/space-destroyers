extends Node
class_name PositionHistoryComponent

## The node to watch position for history.
@export var watch_node: Node2D
## The number of pixels the node must move to record a historical entry.
@export var deadzone: float
## The length of the position history in milliseconds.
@export var max_positions_remembered := 200

## The historical positions of the node.
var _position_history: Array[Vector2]

func _physics_process(_delta: float) -> void:
	if !watch_node:
		return
	
	var added := false
	if !_position_history.size():
		_position_history.push_front(watch_node.global_position)
		added = true
	elif _position_history[0].distance_to(watch_node.global_position) > deadzone:
		_position_history.push_front(watch_node.global_position)
		added = true
	
	if added and _position_history.size() > max_positions_remembered:
		_position_history.resize(max_positions_remembered)

func get_position_at_history_index(index: int) -> Vector2:
	if _position_history.size() <= index:
		if _position_history.size() > 0:
			return _position_history[_position_history.size() - 1]
		else:
			return watch_node.global_position
	return _position_history[index]
