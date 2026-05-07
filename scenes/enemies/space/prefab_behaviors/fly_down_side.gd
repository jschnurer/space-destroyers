@tool
extends Node2D
class_name FlyDownSide

enum FlySide {
	LEFT = 0,
	RIGHT = 1,
}

## The path to follow (left or right).
@export var side: FlySide:
	set(value):
		side = value
		_toggle_path_display()
	get():
		return side
		
## The node to follow the path. If null, will search for first child node that is an Enemy.
@export var node_to_move: Node2D

@onready var follow_path_down_left: FollowPathBehavior = $BehaviorOrchestrator/FollowPathDownLeft
@onready var follow_path_down_right: FollowPathBehavior = $BehaviorOrchestrator/FollowPathDownRight
@onready var behavior_orchestrator: BehaviorOrchestrator = $BehaviorOrchestrator

func _ready() -> void:
	if !Engine.is_editor_hint():
		if !node_to_move:
			node_to_move = Utilities.get_first_child_of_type(self, Enemy)
		
		if side == FlySide.LEFT:
			follow_path_down_left.node_to_move = node_to_move
			behavior_orchestrator.behaviors.assign([follow_path_down_left])
		else:
			follow_path_down_right.node_to_move = node_to_move
			behavior_orchestrator.behaviors.assign([follow_path_down_right])
	else:
		_toggle_path_display()

func _toggle_path_display() -> void:
	if Engine.is_editor_hint():
		($BehaviorOrchestrator/FollowPathDownLeft as Node2D).visible = side == FlySide.LEFT
		($BehaviorOrchestrator/FollowPathDownRight as Node2D).visible = side == FlySide.RIGHT
