@tool
extends Node2D

@export var star_count: int = 100:
	set(value):
		star_count = value
		_generate_stars()

@export_group("Size")
@export var star_size_min := 4:
	set(value):
		star_size_min = value
		_generate_stars()
@export var start_size_max := 4:
	set(value):
		start_size_max = value
		_generate_stars()

@export_group("Animation")
## If not ZERO, starts will animate in that direction. When they leave the ReferenceRect,
## they will respawn along the incoming edge somewhere.
@export var animate_direction: Vector2 = Vector2.ZERO
@export var animate_speed: float = 0.0

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
		var initial_size := randf_range(star_size_min, start_size_max)
		star.size = Vector2.ONE * (initial_size * (0.95 - star.position.y / area_size.y) if use_y_scaling \
			else initial_size)
		add_child(star)
		_stars.append(star)

func _process(delta: float) -> void:
	if animate_direction == Vector2.ZERO or animate_speed == 0:
		return
	
	var bounds := bounds_rect.get_global_rect()
	
	for star in _stars:
		star.position += animate_direction * animate_speed * delta
		
		star.global_position.x = fposmod(star.global_position.x - bounds.position.x, bounds.size.x) + bounds.position.x
		star.global_position.y = fposmod(star.global_position.y - bounds.position.y, bounds.size.y) + bounds.position.y
		#if !star.get_global_rect().intersects(bounds):
			#pass
