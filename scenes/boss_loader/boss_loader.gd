extends Node
class_name BossLoader

## Needed to listen for all_enemies_destroyed signal.
@export var level_manager: LevelManager
## Time to wait before showing text.
@export var wait_time := 5.0
## The boss to load in, then animate down from the top of the screen.
@export var boss_scene: PackedScene

@onready var mission_update_text_animation: MissionUpdateTextAnimation = $MissionUpdateTextAnimation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if level_manager:
		level_manager.all_enemies_destroyed.connect(_on_all_enemies_destroyed)

func _on_all_enemies_destroyed() -> void:
	SignalBus.emit_fade_out_bgm(wait_time / 1.5)
	await get_tree().create_timer(wait_time).timeout
	mission_update_text_animation.play()
	
func _on_mission_update_text_animation_player_dismissed() -> void:
	mission_update_text_animation.visible = false
	
	if boss_scene:
		# TODO: Load Boss Here
		pass
