extends Node2D
class_name InvaderBossDisgorger

## Array of enemies to randomly pick from to birth.
@export var birthed_enemies: Array[PackedScene]
## Move speed of birthed enemies.
@export var enemy_move_speed: float = 235.0
## Move speed % bonus each time enemy hits screen edge.
@export var pct_speed_bonus_on_drop := 0.0
## IndependentMoveComponent to add to birthed enemies.
@export var independent_move_component_scene: PackedScene

@onready var dance_component: DanceComponent = %DanceComponent
@onready var disgorge_point: Node2D = %DisgorgePoint
@onready var invader_boss_body_chunk: InvaderBossBodyChunk = $InvaderBossBodyChunk
@onready var disgorger_sprite_2d: Sprite2D = %DisgorgerSprite2D

var enabled := true

func _ready() -> void:
	dance_component.frame_changed.connect(_on_dance_frame_changed)

func _on_dance_frame_changed(frame_index: int) -> void:
	if frame_index != 3 or birthed_enemies.size() == 0:
		return
	
	if enabled:
		# Spawn enemy.
		var enemy_scene: PackedScene = birthed_enemies.pick_random()
		_spawn_enemy(enemy_scene)

func _spawn_enemy(enemy_scene: PackedScene) -> void:
	var enemy: Node2D = enemy_scene.instantiate()
	
	enemy.global_position = disgorge_point.global_position
	
	# Apply level bonuses!
	if enemy is Enemy:
		var en := enemy as Enemy
		en.apply_level_bonus()
		
		if enemy is Sprite2D:
			var sprite_rect := (enemy as Sprite2D).get_rect()
			enemy.global_position.x -= sprite_rect.size.x / 2.0 * enemy.scale.x
			enemy.global_position.y -= sprite_rect.size.y / 2.0 * enemy.scale.y
		
		# Don't need a formation move since these enemies move independently of each other.
		var formation_move: FormationMoveComponent = en.get_component(FormationMoveComponent)
		if formation_move:
			formation_move.queue_free()
		
		var ind_move: IndependentMoveComponent = independent_move_component_scene.instantiate()
		ind_move.initial_speed = enemy_move_speed
		ind_move.percent_speed_bonus_on_dir_change = pct_speed_bonus_on_drop
		ind_move._direction = transform.y
		ind_move.moving_node = en
		var comp_holder: Node = en.find_child("Components")
		if comp_holder:
			comp_holder.add_child(ind_move)
		else:
			en.add_child(ind_move)
		ind_move.position = Vector2.ZERO
		
		# Don't spawn credits.
		var on_death_comp: OnDeathComponent = en.get_component(OnDeathComponent)
		if on_death_comp:
			on_death_comp.spawn_credit = false
		
		# Copy the hurtbox's collision shape into an IndependentMoveComponent
		var hurtbox: HurtboxComponent = en.get_component(HurtboxComponent)
		if hurtbox:
			var child_node: Node = hurtbox.get_child(0)
			if child_node is CollisionShape2D:
				var move_shape := child_node.duplicate()
				ind_move.add_child(move_shape)

	Utilities.add_child_to_level(enemy, true)

func toggle_destroyed(is_destroyed: bool) -> void:
	invader_boss_body_chunk.visible = is_destroyed
	invader_boss_body_chunk.toggle_destroyed(is_destroyed)
	enabled = !is_destroyed
	disgorger_sprite_2d.visible = !is_destroyed
