extends OrchestratedBehavior
class_name FollowPathBehavior

## Path to follow.
@export var path: Path2D
## The node that will follow the path.
@export var node_to_move: Node2D

@export_group("Movement Options")
## Speed of things moving along path.
@export var path_speed: float = 100.0
## Defines whether or not to use path_transition.
@export var path_use_transition: bool
## Path transition.
@export var path_transition: Tween.TransitionType
## Defines whether or not to use path_easing.
@export var path_use_easing: bool
## Path easing.
@export var path_easing: Tween.EaseType
## Rotate the follower as it follows path?
@export var rotate_follower: bool

@export_group("")
## The number of times this path should loop. If -1, infinitely.
@export var loop_count: int = 0

var _path_tween: Tween
var _is_processing: bool
var _follower: PathFollow2D
var _remote_transform: RemoteTransform2D

func handle() -> Signal:
	if _path_tween:
		_path_tween.kill()
	
	if !_follower:
		_follower = PathFollow2D.new()
		_remote_transform = RemoteTransform2D.new()
		
	_follower.progress = 0
	_follower.rotates = rotate_follower
	_follower.loop = loop_count > 0
	_remote_transform.remote_path = node_to_move.get_path()
	_follower.add_child(_remote_transform)
	
	if _follower.get_parent():
		_follower.reparent(path)
	else:
		path.add_child(_follower)
	
	_is_processing = true
	
	if loop_count == 0 and (path_use_transition or path_use_easing):
		var duration := path.curve.get_baked_length() / path_speed
		_path_tween = create_tween()
		if path_use_transition:
			_path_tween.set_trans(path_transition)
		if path_use_easing:
			_path_tween.set_ease(path_easing)
		_path_tween.tween_property(_follower, "progress_ratio", 1.0, duration)
	else:
		_path_tween.kill()
	
	return behavior_complete

func _physics_process(delta: float) -> void:
	if !_is_processing:
		return
	
	if !_path_tween:
		_follower.progress += path_speed * delta
	
	# The behavior is complete if:
	#   * No looping & reached 100%.
	#   * Loop X times and reached 100% + X00%
	if (loop_count == 0 and _follower.progress_ratio >= 1.0)\
		or (loop_count > 0 and _follower.progress_ratio >= loop_count + 1):
		_is_processing = false
		emit_behavior_complete()
