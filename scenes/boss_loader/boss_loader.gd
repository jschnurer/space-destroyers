extends Node
class_name BossLoader

## Needed to listen for all_enemies_destroyed signal.
@export var level_manager: LevelManager
## Time to wait before showing text.
@export var wait_time := 5.0
## The boss to load in, then animate down from the top of the screen.
@export var boss_scene: PackedScene
## The location to spawn the boss in.
@export var spawn_location: Vector2
## The location to animate the boss to.
@export var final_position: Vector2
## The number of seconds needed to animate the boss to its final position before play begins.
@export var boss_animate_duration: float = 1.0
## Boss bgm.
@export var boss_bgm: AudioStream

@onready var mission_update_text_animation: MissionUpdateTextAnimation = $MissionUpdateTextAnimation

signal boss_killed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if level_manager:
		level_manager.all_enemies_destroyed.connect(_on_all_enemies_destroyed)

func _on_all_enemies_destroyed() -> void:
	SignalBus.emit_fade_out_bgm(wait_time / 1.5)
	await get_tree().create_timer(wait_time).timeout
	SignalBus.emit_clear_enemy_attacks()
	SignalBus.emit_toggle_player_shoot_ability(false)
	mission_update_text_animation.play()
	
func _on_mission_update_text_animation_player_dismissed() -> void:
	mission_update_text_animation.visible = false
	
	SignalBus.emit_fade_out_bgm(1)
	
	var pause_tween := create_tween()
	pause_tween.tween_interval(1)
	pause_tween.tween_callback(_spawn_boss)

func _spawn_boss() -> void:
	if !boss_scene:
		return
	
	SignalBus.emit_play_bgm(boss_bgm, 1, 1, 0, 1)
	
	var boss: Node2D = boss_scene.instantiate()
	if boss.has_method("toggle_attacking"):
		boss.call("toggle_attacking", false)
	boss.global_position = spawn_location
	
	if boss.has_signal("boss_killed"):
		boss.connect("boss_killed", boss_killed.emit)
	
	Utilities.add_child_to_level(boss)
	
	var tween := create_tween()
	tween.tween_property(boss, "global_position", final_position, boss_animate_duration)
	tween.tween_callback(func() -> void:
		SignalBus.emit_toggle_player_shoot_ability(true)
		if boss.has_method("toggle_attacking"):
			boss.call("toggle_attacking", true)
	)
