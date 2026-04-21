extends Node
class_name PositionHistoryFollowComponent

# The node that is moved to follow the history.
@export var following_node: Node2D
# The index within the history to derive position from.
@export var history_delay_index := 5
# The position history component that is recording position history.
@export var position_history_comp: PositionHistoryComponent

func _process(_delta: float) -> void:
	if !position_history_comp:
		return
	
	var pos_hist := position_history_comp.get_position_at_history_index(history_delay_index)
	following_node.global_position = pos_hist
