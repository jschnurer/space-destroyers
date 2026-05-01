extends Node2D
class_name PathStep

## Path to follow.
@export var path: Path2D

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
## If true, the follower will loop along this path forever.
@export var loop_path: bool
## Free the node at the end of this path.
@export var free_at_end: bool
## Wait this long before starting to follow the next path.
@export var wait_time_at_end: float = 0.0
