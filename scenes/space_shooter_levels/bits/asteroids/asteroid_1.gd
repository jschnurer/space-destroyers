extends Node2D
class_name Asteroid

## Bigger number, slower rotation.
@export var rotation_slowness := 14.0
## If not 0,0, will randomize slowness between x-y.
@export var rotation_slowness_range: Vector2 = Vector2.ZERO
## Positive or negative 1 only.
@export var rotation_direction := 1
## If true, randomized rotation direction on ready.
@export var random_rotation_direction := true
## If true, randomly mirror x axis.
@export var random_mirror := true

func _ready() -> void:
	if random_rotation_direction:
		rotation_direction = -1 if randf() < 0.5 else 1
	
	if random_mirror and randf() < 0.5:
		scale.x *= -1
	
	if rotation_slowness_range != Vector2.ZERO:
		rotation_slowness = randf_range(rotation_slowness_range.x, rotation_slowness_range.y)

func _process(delta: float) -> void:
	rotate(delta * PI * (1.0 / rotation_slowness) * rotation_direction)
