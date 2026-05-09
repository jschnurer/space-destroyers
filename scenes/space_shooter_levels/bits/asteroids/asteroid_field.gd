extends Node2D
class_name AsteroidField

## If true, asteroids will continually spawn above the top of the screen as others leave.
@export var continuous := true
## The possible asteroids to spawn.
@export var asteroid_scenes: Array[PackedScene] = []
## If true, asteroids start above the top of the screen.
@export var start_above_screen := false

@export_group("Asteroid Options")
## Max asteroid count visible at once.
@export var max_asteroid_count := 30
## Min/max scale of each asteroid spawned (x=min, y=max).
@export var scale_range: Vector2 = Vector2.ONE
## The range of values for rotation speed (10-50).
@export var rot_speed_range: Vector2 = Vector2(10, 50)
## The larger the asteroid, the slower it spins.
@export var rot_speed_by_scale := true
## Determines asteroid collision status.
@export var has_collision: bool
## The additional y velocity of the asteroids (+- the auto-scroll speed).
@export var y_velocity: float
## If true, asteroid's y_velocity is increased with bigger scale.
@export var y_velocity_by_scale := true
## The largest scale gains this much more y_velocity.
@export var max_addtl_y_velocity: float
## If true, larger asteroids gain modulate toward end of gradiant.
@export var modulate_by_scale := true
## Used by modulate_by_scale.
@export var scale_modulate_gradient: Gradient
## The range of z-index values by scale.
@export var z_index_range: Vector2

func _ready() -> void:
	_init_all_asteroids()

func _init_all_asteroids() -> void:
	for i in range(max_asteroid_count):
		var scn: PackedScene = asteroid_scenes.pick_random()
		var ast: Asteroid = scn.instantiate()
		
		var sprite: Sprite2D = Utilities.get_first_child_of_type(ast, Sprite2D)
		var sprite_rect := sprite.get_rect()
		sprite_rect.size *= sprite.scale
		sprite_rect.position *= sprite.scale
		
		ast.set_meta("sprite_rect", sprite_rect)
		
		# Add a trigger to detect when it leaves the screen to disable it.
		var vis := VisibleOnScreenNotifier2D.new()
		vis.rect = sprite_rect
		vis.screen_exited.connect(_on_asteroid_screen_exited.bind(ast))
		ast.add_child(vis)
		
		ast.enable_collision = false
		
		add_child(ast)
		
		_init_asteroid(ast, true)

func _on_asteroid_screen_exited(ast: Asteroid) -> void:
	_init_asteroid(ast, false)

## Places an asteroid appropriately and randomizes its appearance.
func _init_asteroid(ast: Asteroid, is_initial_placement: bool) -> void:
	ast.random_mirror = false
	ast.random_starting_rotation = false
	ast.y_velocity = y_velocity
	ast.rotation_direction = Asteroid.AsteroidRotationDirection.RANDOM
		
	ast.rotation_degrees = randf_range(0, 360)
	
	if ast.enable_collision != has_collision:
		ast.enable_collision = has_collision
	
	if scale_range.x > 0 and scale_range.y >= scale_range.x:
		var ast_scale := randf_range(scale_range.x, scale_range.y)
		ast.scale = Vector2(ast_scale, ast_scale)
	
	var pct_along_scale_range := inverse_lerp(scale_range.x, scale_range.y, ast.scale.y)
	
	if rot_speed_by_scale:
		# Do not randomize rotation slowness. It will be handled here.
		ast.rotation_slowness_range = Vector2.ZERO
		ast.rotation_slowness = lerpf(rot_speed_range.x, rot_speed_range.y, pct_along_scale_range)
	
	if y_velocity_by_scale:
		ast.y_velocity = y_velocity + lerpf(0, max_addtl_y_velocity, pct_along_scale_range)
	else:
		ast.y_velocity = y_velocity
	
	if scale_range.x != scale_range.y:
		ast.z_index = int(lerpf(z_index_range.x, z_index_range.y, ast.scale.y / (scale_range.y - scale_range.x)))
	
	if modulate_by_scale:
		ast.modulate = scale_modulate_gradient.sample(pct_along_scale_range)
	
	# Determine placement.
	var ast_rect: Rect2 = ast.get_meta("sprite_rect")
	var scaled_rect := ast_rect
	scaled_rect.size *= abs(ast.scale.x)
	
	# Determine placement of asteroid.
	var ast_size: float = absf(maxf(scaled_rect.size.y, scaled_rect.size.x))
	var size_offset := randf_range(-0.75 * ast_size, 0.75 * ast_size)
	
	var playable_rect := Global.PLAYABLE_AREA_RECT
	
	if is_initial_placement and !start_above_screen:
		ast.global_position = Vector2(
			randf_range(
				playable_rect.position.x,
				playable_rect.size.x
			) + size_offset,
			randf_range(
				playable_rect.position.y - playable_rect.size.y * 0.5,
				playable_rect.size.y
			) + size_offset
		)
	else:
		ast.global_position = Vector2(
			randf_range(
				playable_rect.position.x,
				playable_rect.size.x
			) + size_offset,
			randf_range(
				playable_rect.position.y - playable_rect.size.y * 0.75 - size_offset,
				playable_rect.position.y - size_offset
			)
		)
	
	# Flip its scale.x 50% of the time.
	ast.scale.x = -1 if randf() < 0.5 else 1
