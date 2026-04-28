extends VisibleOnScreenNotifier2D
class_name DeleteOffscreenComponent

## The node to delete if it goes offscreen.
@export var delete_node: Node

func _on_screen_exited() -> void:
	if delete_node:
		delete_node.queue_free()
