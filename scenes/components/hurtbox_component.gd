extends Area2D
class_name HurtboxComponent

## Life component to hurt.
@export var life_component: LifeComponent

@export_group("Damage Flash")
@export var flash_damage: bool = false
@export var flash_color: Color = Color.RED
@export var sprite_2d: Sprite2D

var _flash_tween: Tween

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent and life_component:
		if !(area as HitboxComponent).is_active:
			return
		var dmg_dealt := life_component.take_damage((area as HitboxComponent).damage)
		if dmg_dealt > 0:
			(area as HitboxComponent).notify_dealt_damage(self)
		if life_component.life > 0.0:
			_flash_damage()

func _flash_damage() -> void:
	if _flash_tween and _flash_tween.is_running():
		_flash_tween.kill()
	
	_flash_tween = create_tween()
	_flash_tween.tween_method(_set_flash_color, flash_color, Color(flash_color, 0.0), 0.06)

func _set_flash_color(color: Color) -> void:
	var sprite_mat := (sprite_2d.material as ShaderMaterial)
	if not sprite_mat:
		return
	sprite_mat.set_shader_parameter("flash_color", color)
