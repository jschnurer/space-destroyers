extends Node2D
class_name FormationPathFollow

@export var node_to_move: Node2D
@export var enemy_path_speed: float
@export var path_follower_scene: PackedScene
@export var rotate_enemies: bool

var _path: Path2D
var _level_manager: SpaceShooterLevelManager

func _ready() -> void:
	_path = Utilities.get_first_child_of_type(self, Path2D)
	
	var follower := path_follower_scene.instantiate() as PathFollow2D
	follower.loop = false
	follower.rotates = rotate_enemies
	
	var transformer: RemoteTransform2D = Utilities.get_first_child_of_type(follower, RemoteTransform2D)
	transformer.remote_path = node_to_move.get_path()
	
	if !_level_manager:
		_level_manager = get_tree().get_first_node_in_group(GroupNames.LEVEL_MANAGER_SPACE)
		print("Ready on: ", self.name, " for manager: ", _level_manager)

func _physics_process(delta: float) -> void:
	if !_level_manager:
		_level_manager = get_tree().get_first_node_in_group(GroupNames.LEVEL_MANAGER_SPACE)
		
	if !node_to_move or !_path or !_level_manager:
		return
		
	# Stop scrolling downward!
	position.y -= _level_manager.scroll_speed * delta
	
	for follower: PathFollow2D in _path.get_children():
		follower.progress += enemy_path_speed * delta
		if follower.progress_ratio >= 1.0:
			follower.queue_free()
