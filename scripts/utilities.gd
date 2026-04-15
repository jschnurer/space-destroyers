extends Node

func is_in_layer(node_layer: int, check_layer: Enums.CollisionLayers) -> bool:
	return (node_layer & (1 << check_layer)) != 0

func add_child_to_level(node: Node, deferred := false) -> void:
	if !deferred:
		var level_node: Node = get_tree().get_first_node_in_group("LEVEL_NODE")
		if level_node:
			level_node.add_child(node)
		else:
			get_tree().current_scene.add_child(node)
	else:
		call_deferred("add_child_to_level", node)

func add_children_to_level(nodes: Array[Node], deferred := false) -> void:
	if !deferred:
		var level_node := get_tree().get_first_node_in_group("LEVEL_NODE")
		for node in nodes:
			if level_node:
				level_node.add_child(node)
			else:
				get_tree().current_scene.add_child(node)
	else:
		call_deferred("add_children_to_level", nodes)

func get_children_of_type(base_node: Node, type: Variant) -> Array[Node]:
	var matches: Array[Node] = []
	for child in base_node.find_children("*", "", true):
		if is_instance_of(child, type):
			matches.append(child)
	return matches

func get_first_child_of_type(base_node: Node, type: Variant) -> Node:
	var children := get_children_of_type(base_node, type)
	if children and children.size() > 0:
		return children[0]
	return null

func get_terrain_top_edge_y_position() -> float:
	var bottom_terrain := get_tree().get_first_node_in_group("TERRAIN_BOTTOM")
	return (bottom_terrain as TerrainBottom).get_top_edge_global_y_position()
