extends RigidBody2D
class_name Credit

@export var value := 1.0
@export var collection_move_speed := 800.0
@export var credit_sound: AudioStream
var denomination: CreditDenomination:
	set(val):
		denomination = val
		_update_shader_color()

var _is_collecting := false
var _player_target: Node2D
var _collection_velocity := Vector2.ZERO
var _collection_push_strength := 800.0
var _collection_speed := 1200.0
var _is_pushing := false
var _steer_force := 20.0

@onready var sprite_2d: Sprite2D = %Sprite2D

func _ready() -> void:
	await get_tree().physics_frame
	PhysicsServer2D.body_set_force_integration_callback(get_rid(), Callable(self, "_on_force_integration"))

func _process(delta: float) -> void:
	if _is_pushing:
		# Decelerate
		_collection_velocity = _collection_velocity.lerp(Vector2.ZERO, delta * 10.0)
		global_position += _collection_velocity * delta
		# Once stopped, stop pushing, start collecting.
		if _collection_velocity.length() < 10.0:
			_is_pushing = false
			_is_collecting = true
	
	# If collecting, move toward player.
	if _is_collecting and is_instance_valid(_player_target):
		var to_target := (_player_target.global_position - global_position).normalized()
		var desired_velocity := to_target * _collection_speed
		var steering := (desired_velocity - _collection_velocity) * _steer_force * delta
		_collection_velocity += steering
		global_position += _collection_velocity * delta

	if is_instance_valid(_player_target) and \
		global_position.distance_to(_player_target.global_position) < 20.0:
		collect()

func collect() -> void:
	var mult := Game.get_stat_value(Enums.PlayerStats.CREDIT_MULTIPLIER)
	var pickup_amt := value * mult
	SignalBus.emit_credits_picked_up(pickup_amt)
	SignalBus.emit_play_sfx(credit_sound, 0.5)
	queue_free()

func _on_force_integration(_state: PhysicsDirectBodyState2D) -> void:
	var side_motion := randf_range(-120.0, 120.0)
	var up_motion := randf_range(0.0, 120.0)

	apply_impulse(Vector2(side_motion, -up_motion))
	apply_torque_impulse(randf_range(0.15, 1.15) * side_motion)

	PhysicsServer2D.body_set_force_integration_callback(get_rid(), Callable())

func set_lucky(lucky: bool) -> void:
	(%LuckyComponent as LuckyComponent).set_lucky(lucky)

func _update_shader_color() -> void:
	if !denomination:
		return
	
	(%Sprite2D as Sprite2D).modulate = denomination.color

func start_pickup_sequence(player_target: Node2D) -> void:
	if _is_collecting:
		return
	
	# Save the point to fly to.
	_player_target = player_target
	call_deferred("_lock_and_push")

func _lock_and_push() -> void:
	# Stop gravity/physics.
	freeze = true
	
	# Stop interacting with other objects.
	set_collision_layer_value(6, false)
	set_collision_mask_value(5, false)
	set_collision_mask_value(6, false)
	
	# Push the object away a little.
	var push_dir := (global_position - _player_target.global_position).normalized()
	_collection_velocity = push_dir * _collection_push_strength
	_is_pushing = true
