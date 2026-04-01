extends BaseProjectile
class_name Bullet

## If true, this bullet can flak enemies.
@export var can_flak := false

func _ready() -> void:
	if can_flak:
		($Components/HitboxComponent as HitboxComponent).can_flak = true

func _on_hitbox_component_dealt_damage(_hurtbox_component: HurtboxComponent) -> void:
	($Components/HitboxComponent as HitboxComponent).is_active = false
	queue_free()
