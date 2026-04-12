@tool
extends Node2D
class_name Starfield

@export var star_count: int = 100:
	set(value):
		star_count = value
		_generate_stars()

@export_group("Size")
@export var star_size_min := 4:
	set(value):
		star_size_min = value
		_generate_stars()
@export var star_size_max := 4:
	set(value):
		star_size_max = value
		_generate_stars()

@export_group("Animation")
## If not ZERO, starts will animate in that direction. When they leave the ReferenceRect,
## they will respawn along the incoming edge somewhere.
@export var animate_direction: Vector2 = Vector2.ZERO
@export var animate_speed: float = 0.0
@export var randomize_x_on_wrap := false
@export var randomize_y_on_wrap := false

@export_group("Scaling & Weight")
@export_range(0.1, 5.0) var y_weight: float = 2.0:
	set(value):
		y_weight = value
		_generate_stars()

@export var use_y_weight := true
@export var use_y_scaling := true

@export_group("")
@export_tool_button("Clear Stars") var clear_stars_button := _clear_stars
@export_tool_button("Generate Stars") var generate_stars_button := _generate_stars

# We use the ReferenceRect as our "container"
@onready var bounds_rect: ReferenceRect = $ReferenceRect

var _stars: Array[ColorRect] = []

func _ready() -> void:
	_generate_stars()

func _clear_stars() -> void:
	for child in get_children():
		if child is ColorRect:
			child.free()
	_stars.clear()

func _generate_stars() -> void:
	if !bounds_rect:
		return
	
	# 1. Clear existing stars
	for child in get_children():
		if child is ColorRect:
			child.free()
	_stars.clear()
	
	# 2. Get bounds from the ReferenceRect size
	var area_size := bounds_rect.size
	
	# 3. Create random stars
	for i in range(star_count):
		var star := ColorRect.new()
		var y_pos := 0.0
		
		if use_y_weight:
			y_pos = pow(randf(), y_weight) * area_size.y
		else:
			y_pos = randf_range(0, area_size.y)
		
		star.position = Vector2(randf_range(0, area_size.x), y_pos)
		_size_star(star)
		star.modulate.a = star.size.x / star_size_max
		add_child(star)
		_stars.append(star)

func _process(delta: float) -> void:
	if animate_direction == Vector2.ZERO or animate_speed == 0:
		return

	for star in _stars:
		star.position += animate_direction * animate_speed * delta * star.modulate.a
		
		var off_x := star.position.x < 0 or star.position.x > bounds_rect.size.x
		var off_y := star.position.y < 0 or star.position.y > bounds_rect.size.y
		
		star.position.x = fposmod(star.position.x - bounds_rect.position.x, bounds_rect.size.x) + bounds_rect.position.x
		star.position.y = fposmod(star.position.y - bounds_rect.position.y, bounds_rect.size.y) + bounds_rect.position.y
		
		if off_y and randomize_x_on_wrap:
			star.position.x = randf_range(0, bounds_rect.size.x)
		if off_x and randomize_y_on_wrap:
			star.position.y = randf_range(0, bounds_rect.size.y)
			_size_star(star)

func _size_star(star: ColorRect) -> void:
	var initial_size := randf_range(star_size_min, star_size_max)
	star.size = Vector2.ONE * (initial_size * (0.95 - star.position.y / bounds_rect.size.y) if use_y_scaling \
		else initial_size)
