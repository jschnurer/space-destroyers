extends Node
class_name PlayerOptionSpawnComponent

## The node at which the options should be spawned in (the node with the PositionHistoryComponent).
@export var spawn_position: Node2D
## The node to listen for visibility changes. Options will inherit this node's visibility.
@export var visibility_parent: Node2D
## The scene that is the option to spawn.
@export var option_scene: PackedScene
## The position history component to follow.
@export var position_history_comp: PositionHistoryComponent
## The index the first option should follow and the spacing of each option thereafter.
@export var option_position_spacing := 20

var _spawned_options: Array[Node2D] = []

func _ready() -> void:
	visibility_parent.visibility_changed.connect(_on_visibility_parent_visibility_changed)
	Game.upgrade_changed.connect(_on_upgrade_changed)
	_match_option_count()

## Spawns or despawns options to match the current upgrade level.
func _match_option_count() -> void:
	var option_level := Game.get_upgrade_level(Enums.PlayerUpgrades.OPTION)
	var num_options := clampi(option_level, 0, 4)
	var option_power_bonus := 0 if option_level <= 4 else option_level % 4
	
	if _spawned_options.size() < num_options:
		# Spawn options up to current level.
		for i in range(num_options - _spawned_options.size()):
			_spawn_new_option(option_power_bonus)
	elif _spawned_options.size() > num_options:
		# Despawn options down to current level (not sure why I'd need this, but just in case...)
		while _spawned_options.size() > num_options:
			var opt: PlayerOption = _spawned_options.pop_back()
			if is_instance_valid(opt):
				opt.queue_free()
		# Now that some have been despawned, need to update power bonus for survivors.
		for opt in _spawned_options:
			if "power_bonus" in opt:
				opt.set("power_bonus", option_power_bonus)

## Spawns 1 new option.
func _spawn_new_option(power_bonus: int) -> void:
	# Spawn the option.
	var opt: Node2D = option_scene.instantiate()
	opt.global_position = spawn_position.global_position
	opt.visible = visibility_parent.visible
	
	# Move it just below the player z_index.
	opt.z_index = visibility_parent.z_index - 1
	
	## Apply the power bonus (if any)
	if "power_bonus" in opt:
		opt.set("power_bonus", power_bonus)
	
	var pos_follow: PositionHistoryFollowComponent = Utilities.get_first_child_of_type(opt, PositionHistoryFollowComponent)
	pos_follow.history_delay_index = (_spawned_options.size() * option_position_spacing) + option_position_spacing
	pos_follow.position_history_comp = position_history_comp
	
	# Save to list for later.
	_spawned_options.append(opt)
	
	var parent_node := get_tree().get_first_node_in_group(GroupNames.LEVEL_BASE_NODE)
	parent_node.add_child.call_deferred(opt)

## Fires when visibility parent's `visible` changes.
func _on_visibility_parent_visibility_changed() -> void:
	for opt in _spawned_options:
		opt.visible = visibility_parent.visible

## Fires when a player's upgrade level changes.
func _on_upgrade_changed(changed_upgrade: Upgrade) -> void:
	if changed_upgrade.upgrade == Enums.PlayerUpgrades.OPTION:
		_match_option_count()

## Gets the list of active options.
func _get_options() -> Array[Node2D]:
	return _spawned_options

func reset_options(new_position: Vector2) -> void:
	for opt in _spawned_options:
		opt.global_position = new_position
