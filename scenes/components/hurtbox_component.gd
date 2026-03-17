extends Area2D
class_name HurtboxComponent

## Life component to hurt.
@export var life_component: LifeComponent

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent and life_component:
		if life_component.life > 0.0:
			life_component.take_damage((area as HitboxComponent).damage)
			if life_component.life <= 0.0:
				(area as HitboxComponent).notify_dealt_damage(self)
