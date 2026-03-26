extends Sprite2D
class_name BombFire

@export var lifetime_min := 1.0
@export var lifetime_max := 5.0
@export var damage := 1.0
@export var fire_sound: AudioStream
@export var fire_volume_linear := 0.5

@onready var lifetime_timer: Timer = %LifetimeTimer
@onready var hitbox_component: HitboxComponent = %HitboxComponent
@onready var debris: GPUParticles2D = $Debris

func _ready() -> void:
	debris.emitting = true
	lifetime_timer.wait_time = min(lifetime_min, lifetime_max) if lifetime_min > lifetime_max else _get_random_lifetime()
	lifetime_timer.start()
	print("bomb timer: ", lifetime_timer.wait_time)
	hitbox_component.damage = damage
	SignalBus.emit_play_sfx(fire_sound, fire_volume_linear, 0.175)

func _on_lifetime_timer_timeout() -> void:
	queue_free()

func _get_random_lifetime() -> float:
	return lerp(lifetime_min, lifetime_max, pow(randf(), 2.0))
