extends Node2D
class_name InvaderBossTentacle

@onready var life_component: LifeComponent = %LifeComponent
@onready var body_chunk: InvaderBossBodyChunk = %BodyChunk
@onready var auto_shoot_component: AutoShootComponent = %AutoShootComponent
@onready var sprite_2d: Sprite2D = %Sprite2D

signal destroyed

func _ready() -> void:
	life_component.life_zeroed.connect(_on_life_zeroed)

func _on_life_zeroed(_hitbox: HitboxComponent) -> void:
	body_chunk.toggle_destroyed(true)
	auto_shoot_component.queue_free()
	sprite_2d.visible = false
	destroyed.emit()
