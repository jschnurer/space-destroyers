extends Area2D
class_name HitboxComponent

@export var damage: float

signal dealt_damage(hurtbox_component: HurtboxComponent)

## Send the signal notifying that this HitboxComponent has dealt damage to HurtboxComponent.
func notify_dealt_damage(hurtbox_component: HurtboxComponent) -> void:
	dealt_damage.emit(hurtbox_component)
