extends Node
class_name LifetimeComponent

## How long to wait before deletion.
@export var lifetime: float
## Which node to delete.
@export var deletion_node: Node

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.wait_time = lifetime
	timer.start()

func _on_timer_timeout() -> void:
	if deletion_node:
		deletion_node.queue_free()
