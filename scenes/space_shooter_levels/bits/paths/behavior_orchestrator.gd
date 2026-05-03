extends Node2D
class_name BehaviorOrchestrator

## If true, the auto-scrolling level will be offset once this node activates (stop moving down).
@export var offset_auto_scroll := true
## The paths to follow in order.
@export var behaviors: Array[OrchestratedBehavior] = []
## If true, when final behavior is completed, orchestrator is freed.
@export var free_on_complete: bool = true

var _behavior_index := -1
var _level_manager: SpaceShooterLevelManager

@onready var path_wait_timer: Timer = %PathWaitTimer

signal all_steps_complete

func _ready() -> void:
	_level_manager = get_tree().get_first_node_in_group(GroupNames.LEVEL_MANAGER_SPACE)
	_begin_next_behavior()

func _begin_next_behavior() -> void:
	_behavior_index += 1
	var current_behavior := _get_current_behavior()
	if !current_behavior:
		all_steps_complete.emit()
		if free_on_complete:
			queue_free()
		return
	
	# Handle the current behavior and wait for it to complete. When it does,
	# just start the next behavior.
	current_behavior.handle().connect(_begin_next_behavior)

func _physics_process(delta: float) -> void:
	if offset_auto_scroll:
		# Stop scrolling downward!
		position.y -= _level_manager.scroll_speed * delta

func _get_current_behavior() -> OrchestratedBehavior:
	return behaviors[_behavior_index] if _behavior_index < behaviors.size() and _behavior_index >= 0 else null
