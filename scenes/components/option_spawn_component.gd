extends Node
class_name PlayerOptionSpawnComponent

## The node at which the options should be spawned in (the node with the PositionHistoryComponent).
@export var spawn_position: Node2D
## The scene that is the option to spawn.
@export var option_scene: PackedScene
## The position history component to follow.
@export var position_history_comp: PositionHistoryComponent
## The index the first option should follow and the spacing of each option thereafter.
@export var option_position_spacing := 20

var _spawned_options: Array[Node2D] = []

func _ready() -> void:
	# TODO: Debugging; remove this.
	if option_scene:
		for i in range(3):
			var opt: Node2D = option_scene.instantiate()
			opt.global_position = spawn_position.global_position
			var pos_follow: PositionHistoryFollowComponent = Utilities.get_first_child_of_type(opt, PositionHistoryFollowComponent)
			pos_follow.history_delay_index = (i * option_position_spacing) + option_position_spacing
			pos_follow.position_history_comp = position_history_comp
			_spawned_options.append(opt)
			Utilities.add_child_to_level(opt, true)
	# TODO: Also hook into the "player just upgraded Option" signal and spawn one.
