extends Area2D
class_name HitboxComponent

@export var damage: float

## If this is true, the hitbox may deal damage. Otherwise, it shouldn't.
var is_active := true

signal dealt_damage(hurtbox_component: HurtboxComponent)

## Send the signal notifying that this HitboxComponent has dealt damage to HurtboxComponent.
func notify_dealt_damage(hurtbox_component: HurtboxComponent, _dmg_dealt: float) -> void:
	dealt_damage.emit(hurtbox_component)
