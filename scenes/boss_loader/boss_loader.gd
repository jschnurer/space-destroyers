extends Node
class_name BossLoader

## Needed to listen for all_enemies_destroyed signal.
@export var level_manager: LevelManager

@onready var mission_update_text_animation: MissionUpdateTextAnimation = $MissionUpdateTextAnimation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if level_manager:
		level_manager.all_enemies_destroyed.connect(_on_all_enemies_destroyed)

func _on_all_enemies_destroyed() -> void:
	SignalBus.emit_fade_out_bgm(2.0)
	await get_tree().create_timer(2.0).timeout
	mission_update_text_animation.play()
	
func _on_mission_update_text_animation_player_dismissed() -> void:
	mission_update_text_animation.visible = false
	# TODO: Load Boss Here
