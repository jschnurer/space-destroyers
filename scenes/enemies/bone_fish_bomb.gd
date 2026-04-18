extends BaseProjectile
class_name BoneFishBomb

@export var bomb_fire_damage: float = 1.0
@export var bomb_fire_scene: PackedScene

func _on_hitbox_component_dealt_damage(_hurtbox_component: HurtboxComponent) -> void:
	_on_contact()

func _on_terrain_detector_area_entered(_area: Area2D) -> void:
	_on_contact()

func _on_contact() -> void:
	($Components/HitboxComponent as HitboxComponent).is_active = false
	var my_shape: CollisionShape2D = Utilities.get_first_child_of_type(self, CollisionShape2D)
	var impact_point := Vector2(my_shape.global_position.x, Utilities.get_terrain_top_edge_y_position())
	call_deferred("_spawn_fire", impact_point)
	queue_free()

func _spawn_fire(impact_point: Vector2) -> void:
	var bomb_fire: BombFire = bomb_fire_scene.instantiate()
	bomb_fire.scale = scale
	bomb_fire.damage = bomb_fire_damage
	bomb_fire.global_position = impact_point
	bomb_fire.add_to_group("ENEMY_ATTACK")
	
	var smoke_emitter: GPUParticles2D = find_child("Smoke")
	if smoke_emitter:
		smoke_emitter.scale = scale
	
	Utilities.add_child_to_level(bomb_fire, true)

func _on_terrain_detector_body_entered(_body: Node2D) -> void:
	_on_contact()
