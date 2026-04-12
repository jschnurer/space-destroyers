extends Node2D
class_name Rocket

@onready var fire: Sprite2D = $Fire
@onready var smoke: GPUParticles2D = %Smoke

func toggle_fire(active: bool) -> void:
	fire.visible = active

func toggle_smoke_emission(emitting: bool) -> void:
	smoke.emitting = emitting
