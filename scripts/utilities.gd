extends Node

func is_in_layer(node_layer: int, check_layer: Enums.CollisionLayers) -> bool:
	return (node_layer & (1 << check_layer)) != 0

func add_child_to_level(node: Node) -> void:
	get_tree().get_first_node_in_group("LEVEL_NODE").add_child(node)

func add_children_to_level(nodes: Array[Node]) -> void:
	for n in nodes:
		get_tree().get_first_node_in_group("LEVEL_NODE").add_child(n)

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
