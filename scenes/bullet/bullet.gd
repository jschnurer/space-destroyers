extends BaseProjectile
class_name Bullet

func _on_hitbox_component_dealt_damage(_hurtbox_component: HurtboxComponent) -> void:
	($Components/HitboxComponent as HitboxComponent).is_active = false
	queue_free()
