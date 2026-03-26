@tool
extends Node2D
class_name AntiAirTower

@export var bullet_scene: PackedScene

## Base reload time, slightly altered randomly.
@export var reload_time := 2.25:
	set(value):
		reload_time = value
		(%ReloadComponent as ReloadComponent).set_reload_time(value)

@export_group("Cannon Rotation")
@export_range(-180, 180, 1) var min_rotation: float
@export_range(-180, 180, 1) var max_rotation: float
@export var rotation_speed: float = 60.0

var _rotation_dir := 1
var debug_guide_length: float = 1000.0

@onready var cannon: Sprite2D = $Cannon
@onready var reload_component: ReloadComponent = %ReloadComponent
@onready var bullet_spawn_point: Node2D = $Cannon/BulletSpawnPoint
@onready var initial_shot_timer: Timer = $InitialShotTimer

func _ready() -> void:
	_randomize_cannon()
	
	if !Engine.is_editor_hint():
		SignalBus.level_transition_screen_faded.connect(_randomize_cannon)
		SignalBus.new_level_loaded.connect(_on_level_loaded)
		reload_component.reload_complete.connect(_shoot)
		_start_initial_shot()

func _draw() -> void:
	if !Engine.is_editor_hint():
		return
	
	var cannon_origin := ($Cannon as Sprite2D).position
	
	var offset := -PI/2
	var min_dir := Vector2.from_angle(deg_to_rad(min_rotation) + offset)
	var max_dir := Vector2.from_angle(deg_to_rad(max_rotation) + offset)
	
	draw_line(cannon_origin, cannon_origin + (min_dir * pow(debug_guide_length, 4)), Color.YELLOW, 1.0)
	draw_line(cannon_origin, cannon_origin + (max_dir * pow(debug_guide_length, 4)), Color.RED, 1.0)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	
	cannon.rotation_degrees += _rotation_dir * rotation_speed * delta
	
	if cannon.rotation_degrees <= min_rotation:
		cannon.rotation_degrees = min_rotation
		_rotation_dir *= -1
	elif cannon.rotation_degrees >= max_rotation:
		cannon.rotation_degrees = max_rotation
		_rotation_dir *= -1

func _randomize_cannon() -> void:
	cannon.rotation_degrees = randf_range(min_rotation, max_rotation)
	_rotation_dir *= -1 if randf() <= 0.5 else 1

func _get_bullet_direction() -> Vector2:
	return Vector2.from_angle(cannon.rotation - PI/2.0)

func _shoot() -> void:
	var shot := bullet_scene.instantiate() as Bullet
	shot.set_power_speed_direction(10.0,\
		400.0,
		_get_bullet_direction())
	shot.global_position = bullet_spawn_point.global_position
	shot.rotation_degrees = cannon.rotation_degrees
	shot.set_collision(1 << 3, 1 << 1)
	Utilities.call_deferred("add_child_to_level", shot)

	reload_component.set_reload_time(reload_time * randf_range(1.0, 1.25))
	reload_component.reload()

func _on_initial_shot_timer_timeout() -> void:
	_shoot()

func _start_initial_shot() -> void:
	initial_shot_timer.wait_time = randf_range(1.0, 3.0)
	initial_shot_timer.start()

func _on_level_loaded() -> void:
	_start_initial_shot()
