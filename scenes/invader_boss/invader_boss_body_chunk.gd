extends Node2D
class_name InvaderBossBodyChunk

@export var plink_sound: AudioStream

@onready var sprite_2d: Sprite2D = %Sprite2D

var _collision_shapes: Array[CollisionShape2D]

func _ready() -> void:
	for child_shape in (%BodyChunkArea).get_children():
		if child_shape is CollisionShape2D:
			_collision_shapes.append(child_shape as CollisionShape2D)

func _on_body_chunk_area_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		# Tell the hitbox it hit something, even though it did no damage (deletes bullet).
		(area as HitboxComponent).notify_dealt_damage(null, 0)
		# Play the "no damage" sound.
		SignalBus.emit_play_sfx(plink_sound)

## Toggles the "destroyed" sprite on/off.
func toggle_destroyed(is_destroyed: bool) -> void:
	sprite_2d.frame = 1 if is_destroyed else 0

## Toggles the visibility and collision on/off.
func toggle(is_active: bool) -> void:
	visible = is_active
	for cs in _collision_shapes:
		cs.disabled = !is_active
