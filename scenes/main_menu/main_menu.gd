extends Control
class_name MainMenu

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var mission_update_text_animation: MissionUpdateTextAnimation = $MissionUpdateTextAnimation

func _on_start_game_pressed() -> void:
	animation_player.play("fade_out_ui")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out_ui":
		mission_update_text_animation.visible = true
		mission_update_text_animation.play()
