extends Node2D
class_name FormationPathFollow

## If true, the auto-scrolling level will be offset once this node activates (stop moving down).
@export var offset_auto_scroll := true
## The node to move along the path.
@export var node_to_move: Node2D
## The PathFollower scene that will be used to follow the path.
@export var path_follower_scene: PackedScene
## The paths to follow in order.
@export var path_steps: Array[PathStep] = []

var _path_index := -1
var _level_manager: SpaceShooterLevelManager
var _follower: PathFollow2D
var _processing_path := false
var _active_tween: Tween

@onready var path_wait_timer: Timer = %PathWaitTimer

signal final_path_end_reached

func _ready() -> void:
	_follower = path_follower_scene.instantiate() as PathFollow2D
	
	var transformer: RemoteTransform2D = Utilities.get_first_child_of_type(_follower, RemoteTransform2D)
	transformer.remote_path = node_to_move.get_path()
	
	_level_manager = get_tree().get_first_node_in_group(GroupNames.LEVEL_MANAGER_SPACE)
	
	_begin_next_path()

func _begin_next_path() -> void:
	if _active_tween:
		_active_tween.kill()
	
	_path_index += 1
	
	var ps := _get_curr_path_step()
	
	if !ps:
		final_path_end_reached.emit()
		return
	
	_follower.progress = 0
	_follower.rotates = ps.rotate_follower
	_follower.loop = ps.loop_path
	
	if _follower.get_parent():
		_follower.reparent(ps.path)
	else:
		ps.path.add_child(_follower)
	
	_processing_path = true
	
	if !ps.loop_path and (ps.path_use_transition or ps.path_use_easing):
		var duration := ps.path.curve.get_baked_length() / ps.path_speed
		_active_tween = create_tween()
		if ps.path_use_transition:
			_active_tween.set_trans(ps.path_transition)
		if ps.path_use_easing:
			_active_tween.set_ease(ps.path_easing)
		_active_tween.tween_property(_follower, "progress_ratio", 1.0, duration)

func _physics_process(delta: float) -> void:
	if offset_auto_scroll:
		# Stop scrolling downward!
		position.y -= _level_manager.scroll_speed * delta
	
	if !_processing_path:
		return
	
	var ps := _get_curr_path_step()
	
	if !node_to_move or !_level_manager or ps == null:
		return
	
	if !ps.loop_path:
		_follower.progress += ps.path_speed * delta
	
	if _follower.progress_ratio >= 1.0:
		_handle_path_end()

func _handle_path_end() -> void:
	var ps := _get_curr_path_step()
	
	if !ps:
		return
	
	if ps.free_at_end:
		queue_free()
		_processing_path = false
	elif ps.loop_path:
		# No need to do anything at all. Looping is handled automatically, just keep incrementing
		# progress.
		return
	else:
		if _path_index == path_steps.size() - 1:
			# Hit end of final path. Emit signal.
			final_path_end_reached.emit()
			_processing_path = false
		elif ps.wait_time_at_end:
			# Pause before starting next path.
			path_wait_timer.wait_time = ps.wait_time_at_end
			path_wait_timer.start()
			_processing_path = false
		else:
			# Immediately begin next path.
			_begin_next_path()

func _on_path_wait_timer_timeout() -> void:
	# Immediately begin next path.
	_begin_next_path()

func _get_curr_path_step() -> PathStep:
	return path_steps[_path_index] if _path_index <= path_steps.size() and _path_index >= 0 else null
