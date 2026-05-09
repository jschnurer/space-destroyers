extends Node2D
class_name Asteroid

enum AsteroidRotationDirection {
	LEFT = -1,
	RIGHT = 1,
	RANDOM = 0,
}

## Bigger number, slower rotation.
@export_range(0.1, 50) var rotation_slowness := 14.0
## If not 0,0, will randomize slowness between x-y.
@export var rotation_slowness_range: Vector2 = Vector2.ZERO
## Positive or negative 1 only.
@export var rotation_direction := AsteroidRotationDirection.RANDOM
## If true, randomly mirror x axis.
@export var random_mirror := false
## If true, randomizes rotation on ready.
@export var random_starting_rotation := true
## This is applied each _physics_process frame to counteract (or add to) auto scroll.
@export var y_velocity := 0.0
## Determines if shots and/or the player can collide with the asteroid.
@export var enable_collision := true

@onready var _collision_shapes : Array[Node] = [
	%HitboxShape,
	%BodyShape,
	%HurtboxShape,
]
	
var _rot_dir := -1

func _ready() -> void:
	if rotation_direction == AsteroidRotationDirection.RANDOM:
		_randomize_rotate_dir()
	
	if random_starting_rotation:
		rotation_degrees = randf_range(0, 360)
	
	if random_mirror and randf() < 0.5:
		scale.x *= -1
	
	if rotation_slowness_range != Vector2.ZERO:
		rotation_slowness = randf_range(rotation_slowness_range.x, rotation_slowness_range.y)
	
	toggle_collisions(enable_collision)

func _physics_process(delta: float) -> void:
	rotate(delta * PI * (1.0 / rotation_slowness) * _rot_dir)
	
	if !get_tree().paused:
		global_position.y += y_velocity * delta

func _randomize_rotate_dir() -> void:
	_rot_dir = -1 if randf() < 0.5 else 1

func toggle_collisions(is_enabled: bool) -> void:
	enable_collision = is_enabled
	
	for shape in _collision_shapes:
		if shape:
			shape.set_deferred("disabled", !is_enabled)

## Toggles the functioning of the asteroid on or off.
func toggle(is_enabled: bool) -> void:
	if enable_collision:
		toggle_collisions(false)
	visible = is_enabled
	process_mode = Node.PROCESS_MODE_DISABLED if !is_enabled else Node.PROCESS_MODE_INHERIT
