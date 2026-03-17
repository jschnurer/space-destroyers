@tool
extends Node2D

#@export_tool_button("Center Formation") var center_formation_button := _center_formation
## Centers each Node2D child within the reference rect.
@export_tool_button("Center Rows") var center_rows_btn := _center_rows
## Sets the EnemyFormation's x position to 0.
@export_tool_button("Zero Position") var zero_button := _zero_position

func _ready() -> void:
	if !Engine.is_editor_hint():
		global_position.x = Global.PLAYABLE_AREA_RECT.position.x

#func _center_formation() -> void:
	#var largest_right_edge := 0.0
	#
	#for child in get_children():
		#if child is not ReferenceRect and child is Node2D:
			#var c := child as Node2D
			## Hardcode width for now...
			#if c.position.x + 44 > largest_right_edge:
				#largest_right_edge = c.position.x + 44
	#
	#var playable_area_left_edge := Global.PLAYABLE_AREA_RECT.position.x
	#var playable_area_right_edge := Global.PLAYABLE_AREA_RECT.end.x
	#var center_point := float(playable_area_right_edge + playable_area_left_edge) / 2.0
#
	## left edge = 410
	## right edge = 1510
	## center = 960
	#var formation_center := float(largest_right_edge) / 2.0
	#
	#if largest_right_edge > 0.0:
		#position.x = center_point - formation_center
	#else:
		#position.x = center_point

func _center_rows() -> void:
	var play_area_ref_rect := $PlayAreaReference as ReferenceRect
	var center_x := play_area_ref_rect.position.x + play_area_ref_rect.size.x / 2.0
	
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
	
	for dict_row: Array in row_dict.values():
		var enemies_in_row: Array[Sprite2D] = []
		enemies_in_row.assign(dict_row)
		
		# Calculate the width of the rect containing all enemies on this row (including empty space).
		var min_x := INF
		var max_x := -INF
		
		for e in enemies_in_row:
			var sprite_rect := e.get_global_transform() * e.get_rect()
			min_x = min(min_x, sprite_rect.position.x)
			max_x = max(max_x, sprite_rect.position.x + sprite_rect.size.x)
		
		# Calculate row width, centerpoint, and required offset.
		var row_width := max_x - min_x
		var row_center_x := min_x + (row_width / 2.0)
		var row_offset := center_x - row_center_x
		
		# Add this offset to every enemy in this row.
		for enemy in enemies_in_row:
			enemy.position.x += row_offset

func _zero_position() -> void:
	position = Vector2.ZERO
