extends Node2D
class_name TeleportAnimation

@export var teleport_audio: AudioStream

signal animation_complete

@onready var tank: Sprite2D = %Tank
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

func teleport_out() -> void:
	SignalBus.emit_stop_sfx(SfxPlayer.SfxType.GAME)
	visible = true
	_hide_player()
	SignalBus.emit_play_sfx(teleport_audio, .5, 1, SfxPlayer.SfxType.SYSTEM)
	animation_player.play("teleport_out", -1, 2.1)
	
func teleport_in() -> void:
	SignalBus.emit_stop_sfx(SfxPlayer.SfxType.GAME)
	visible = true
	_hide_player()
	SignalBus.emit_play_sfx(teleport_audio, .5, 1, SfxPlayer.SfxType.SYSTEM)
	animation_player.play("teleport_in")

func _on_animation_finished(_anim_name: String) -> void:
	visible = false
	animation_complete.emit()

func _hide_player() -> void:
	var player := get_tree().get_first_node_in_group("PLAYER")
	if player is Node2D:
		(player as Node2D).visible = false
