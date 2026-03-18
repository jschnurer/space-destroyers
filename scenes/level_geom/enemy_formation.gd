@tool
extends Node2D

#@export_tool_button("Center Formation") var center_formation_button := _center_formation
## Centers each Node2D child within the reference rect.
@export_tool_button("Center Rows") var center_rows_btn := _center_rows
## Moves all rows to align the left-most enemy with position 0.
@export_tool_button("Zero Rows") var zero_rows_btn := _zero_rows
## Sets the EnemyFormation's x position to 0.
@export_tool_button("Zero Position") var zero_button := _zero_position

func _ready() -> void:
	if !Engine.is_editor_hint():
		global_position.x = Global.PLAYABLE_AREA_RECT.position.x

func _center_rows() -> void:
	var play_area_ref_rect := $PlayAreaReference as ReferenceRect
	var center_x := play_area_ref_rect.position.x + play_area_ref_rect.size.x / 2.0
	
	var enemies_by_row: Dictionary[float, Array] = _group_enemies_by_y_position()
	
	for dict_row: Array in enemies_by_row.values():
		var enemies_in_row: Array[Sprite2D] = []
		enemies_in_row.assign(dict_row)
		
		# Calculate the width of the rect containing all enemies on this row (including empty space).
		var extents := _get_min_max_x_from_enemies(enemies_in_row)
		
		# Calculate row width, centerpoint, and required offset.
		var row_width := extents.max_val - extents.min_val
		var row_center_x := extents.min_val + (row_width / 2.0)
		var row_offset := center_x - row_center_x
		
		# Add this offset to every enemy in this row.
		for enemy in enemies_in_row:
			enemy.position.x += row_offset

func _zero_rows() -> void:
	var enemies_by_row: Dictionary[float, Array] = _group_enemies_by_y_position()
	
	for dict_row: Array in enemies_by_row.values():
		var enemies_in_row: Array[Sprite2D] = []
		enemies_in_row.assign(dict_row)
		
		var extents := _get_min_max_x_from_enemies(enemies_in_row)
		
		# Already zeroed.
		if extents.min_val == 0.0:
			continue
		
		# Add this offset to every enemy in this row.
		for enemy in enemies_in_row:
			enemy.position.x += -extents.min_val

func _zero_position() -> void:
	position = Vector2.ZERO

func _group_enemies_by_y_position() -> Dictionary[float, Array]:
	# Get all child enemies' sprites.
	var enemies: Array[Sprite2D] = []
	enemies.assign(
		get_children().filter(
			func(child: Node) -> bool: return child.is_in_group("ENEMY") and child is Sprite2D
		)
	)
	
	# Group sprites by their y position.
	var row_dict: Dictionary[float, Array] = {}
	for e in enemies:
		if row_dict.has(e.position.y):
			row_dict[e.position.y].append(e)
		else:
			row_dict[e.position.y] = [e]
	
	return row_dict

func _get_min_max_x_from_enemies(enemies: Array[Sprite2D]) -> MinMax:
	var min_x := INF
	var max_x := -INF
	
	for e in enemies:
		var sprite_rect := e.get_global_transform() * e.get_rect()
		min_x = min(min_x, sprite_rect.position.x)
		max_x = max(max_x, sprite_rect.position.x + sprite_rect.size.x)
	
	return MinMax.new(min_x, max_x)

class MinMax:
	var min_val: float
	var max_val: float
	
	func _init(p_min: float, p_max: float) -> void:
		min_val = p_min
		max_val = p_max
