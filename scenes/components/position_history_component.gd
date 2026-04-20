extends Node
class_name PositionHistoryComponent

## The node to watch position for history.
@export var watch_node: Node2D
## The number of pixels the node must move to record a historical entry.
@export var deadzone: float
## The length of the position history in milliseconds.
@export var history_lifespan_ms := 3000.0

## The historical positions of the node.
var _position_history: Array[PositionHistoryEntry]

func _physics_process(_delta: float) -> void:
	if !watch_node:
		return
	
	if !_position_history.size():
		_position_history.push_front(PositionHistoryEntry.new(watch_node.global_position, Time.get_ticks_msec()))
	elif _position_history[0].position.distance_to(watch_node.global_position) > deadzone:
		_position_history.push_front(PositionHistoryEntry.new(watch_node.global_position, Time.get_ticks_msec()))
	
	# TODO: Truncate history to history_lifespan_ms.

class PositionHistoryEntry:
	@export var position: Vector2
	@export var time: int
	
	func _init(p_position: Vector2, p_time: int) -> void:
		position = p_position
		time = p_time
