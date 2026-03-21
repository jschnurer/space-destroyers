extends Area2D
class_name HurtboxComponent

## Life component to hurt.
@export var life_component: LifeComponent

@export_group("Hit Sound")
@export var play_hit_sound: bool = false
## Sound to play on hit.
@export var hit_sound: AudioStream
## If true, the sound will play even if the hit damage kills. (Use false if onDeath sound is used.)
@export var play_on_death: bool = false

@export_group("Damage Flash")
@export var flash_damage: bool = false
@export var flash_color: Color = Color.RED
@export var sprite_2d: Sprite2D
@export var flash_duration := 0.06

signal on_hurtbox_hit(hitbox: HitboxComponent)

var _flash_tween: Tween

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent and life_component:
		var hitbox := area as HitboxComponent
		
		if !hitbox.is_active:
			return
		
		# Attempt to reduce life.
		var dmg_dealt := life_component.take_damage(hitbox.damage)
		if dmg_dealt > 0:
			_on_took_damage(dmg_dealt, hitbox)
		
		# Always play "hit sound".
		_try_play_hit_sound()
		
		# Notify.
		on_hurtbox_hit.emit(hitbox)

func _on_took_damage(dmg_dealt: float, hitbox: HitboxComponent) -> void:
	hitbox.notify_dealt_damage(self, dmg_dealt)
	if life_component.life > 0 and flash_damage:
		_flash_damage()

func _flash_damage() -> void:
	if _flash_tween and _flash_tween.is_running():
		_flash_tween.kill()
	
	_flash_tween = create_tween()
	var end_color := Color(flash_color, 0.0)
	_flash_tween.tween_method(_set_flash_color, flash_color, end_color, flash_duration)

func _set_flash_color(color: Color) -> void:
	var sprite_mat := (sprite_2d.material as ShaderMaterial)
	if not sprite_mat:
		return
	sprite_mat.set_shader_parameter("flash_color", color)

func _try_play_hit_sound() -> void:
	if play_hit_sound and hit_sound and (play_on_death or life_component.life > 0):
		SignalBus.emit_play_sfx(hit_sound, 0.8)
