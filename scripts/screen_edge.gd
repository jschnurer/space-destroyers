extends Area2D

@export var edge: Enums.ScreenEdges
@export var detection_cooldown := 0.25

var detection_time := 0.0

@onready var static_shape: CollisionShape2D = %StaticShape

func _ready() -> void:
	GameManager.upgrade_changed.connect(_on_upgrade_changed.unbind(1))
	_update_static_shape()

func _process(delta: float) -> void:
	if detection_time > 0.0:
		detection_time -= delta

func _on_area_entered(_area: Area2D) -> void:
	if detection_time > 0.0:
		return
	
	detection_time = detection_cooldown
	SignalBus.emit_enemy_hit_screen_edge(edge)

func _on_upgrade_changed() -> void:
	_update_static_shape()

func _update_static_shape() -> void:
	if edge == Enums.ScreenEdges.LEFT:
		static_shape.disabled = !GameManager.has_upgrade(Enums.PlayerUpgrades.RETAINING_WALL_LEFT)
	elif edge == Enums.ScreenEdges.RIGHT:
		static_shape.disabled = !GameManager.has_upgrade(Enums.PlayerUpgrades.RETAINING_WALL_RIGHT)
