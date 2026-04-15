extends Node
class_name BossKilledTransition

## The boss loader to listen for boss_killed.
@export var boss_loader: BossLoader

@onready var rocket_launch_animation: RocketLaunchAnimation = %RocketLaunchAnimation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boss_loader.boss_killed.connect(_on_boss_killed)

func _on_boss_killed() -> void:
	var level_node := get_tree().get_first_node_in_group("LEVEL_NODE")
	if !level_node:
		return
	
	for child in level_node.get_children():
		if child is not BossKilledTransition:
			child.queue_free()
	
	rocket_launch_animation.reposition()
	rocket_launch_animation.visible = true
	SignalBus.emit_fade_in_screen(3)
	await SignalBus.fade_in_screen_complete
	rocket_launch_animation.play()
