@tool
extends Node2D

@export var star_count: int = 100:
	set(value):
		star_count = value
		_generate_stars()
		
@export var star_size: Vector2 = Vector2(4, 4):
	set(value):
		star_size = value
		_generate_stars()
		
@export_range(0.1, 5.0) var y_weight: float = 2.0:
	set(value):
		y_weight = value
		_generate_stars()

@export var use_y_weight := true
@export var use_y_scaling := true

@export_tool_button("Clear Stars") var clear_stars_button := _clear_stars
@export_tool_button("Generate Stars") var generate_stars_button := _generate_stars

# We use the ReferenceRect as our "container"
@onready var bounds_rect: ReferenceRect = $ReferenceRect

func _ready() -> void:
	_generate_stars()

func _clear_stars() -> void:
	for child in get_children():
		if child is ColorRect:
			child.free()

func _generate_stars() -> void:
	if !bounds_rect:
		return
	
	# 1. Clear existing stars
	for child in get_children():
		if child is ColorRect:
			child.free()
	
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
		star.size = star_size * (0.95 - star.position.y / area_size.y) if use_y_scaling else star_size
		add_child(star)
