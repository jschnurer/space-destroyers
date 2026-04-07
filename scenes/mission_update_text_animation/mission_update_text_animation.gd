extends CanvasLayer
class_name MissionUpdateTextAnimation

@export var autoplay := true
@export_multiline() var mission_text: String
@export var typing_chars_per_second := 10.0

@export_group("Audio")
@export var bgm: AudioStream
## How long to fade out the currently playing BGM.
@export var bgm_fade_out_time := 1.0
## How long to fade in the new BGM.
@export var bgm_fade_in_time := 1.0

@onready var title: Label = %Title
@onready var mission_text_label: RichTextLabel = %MissionText
@onready var continue_prompt: TextureRect = %ContinuePrompt
@onready var klaxon_player: AudioStreamPlayer2D = %KlaxonPlayer
@onready var prompt_blink_timer: Timer = %PromptBlinkTimer
@onready var typing_audio_player: AudioStreamPlayer2D = %TypingAudioPlayer

signal player_dismissed

enum Mode {
	NONE,
	TITLE,
	TYPING,
	PAUSE_BEFORE_PROMPT,
	PROMPT,
	DONE,
}

var _mode := Mode.NONE
var _mission_text_length := 0
var _visible_chars := 0.0
var _title_blink_tween: Tween

func _ready() -> void:
	mission_text_label.text = mission_text
	_mission_text_length = _get_text_length(mission_text)
	if autoplay:
		play()

## Plays the mission update animation.
func play() -> void:
	SignalBus.emit_play_bgm(bgm, 1.0, 1.0, bgm_fade_out_time, bgm_fade_in_time)
	if bgm_fade_in_time > 0:
		await get_tree().create_timer(bgm_fade_in_time).timeout
	_blink_title()

func _process(delta: float) -> void:
	if _mode == Mode.NONE:
		return

	if _mode == Mode.TITLE and Input.is_action_just_pressed("ui_accept"):
		klaxon_player.stop()
		if _title_blink_tween:
			_title_blink_tween.stop()
		title.visible = true
		_type_mission_text()
	elif _mode == Mode.TYPING and Input.is_action_just_pressed("ui_accept"):
		mission_text_label.visible_characters = _mission_text_length
		typing_audio_player.stop()
		_show_continue_prompt()
	elif _mode == Mode.PROMPT and Input.is_action_just_pressed("ui_accept"):
		player_dismissed.emit()
	
	if _mode == Mode.TYPING:
		_visible_chars += typing_chars_per_second * delta
		mission_text_label.visible_characters = floori(_visible_chars)
		if mission_text_label.visible_characters >= _mission_text_length:
			_pause_before_prompt()

func _show_continue_prompt() -> void:
	_mode = Mode.PROMPT
	continue_prompt.visible = true
	prompt_blink_timer.start()

func _on_prompt_blink_timer_timeout() -> void:
	continue_prompt.visible = !continue_prompt.visible

func _on_typing_audio_player_finished() -> void:
	typing_audio_player.play()

func _play_klaxon() -> void:
	klaxon_player.play()

func _blink_title() -> void:
	_mode = Mode.TITLE
	
	var sound_length := 0.58
	var sound_pause_length := 0.11
	
	_title_blink_tween = create_tween()
	
	for i in range(4):
		_title_blink_tween.tween_callback(_play_klaxon)
		_title_blink_tween.tween_property(title, "visible", true, 0.0)
		_title_blink_tween.tween_interval(sound_length)
		if i < 3:
			_title_blink_tween.tween_property(title, "visible", false, 0.0)
			_title_blink_tween.tween_interval(sound_pause_length)
	
	_title_blink_tween.tween_property(title, "visible", true, 0.0)
	_title_blink_tween.tween_callback(_type_mission_text)

func _type_mission_text() -> void:
	_mode = Mode.TYPING
	typing_audio_player.play()
	# Typing is handled in _process.

func _pause_before_prompt() -> void:
	_mode = Mode.PAUSE_BEFORE_PROMPT
	typing_audio_player.stop()
	await get_tree().create_timer(1.0).timeout
	_show_continue_prompt()

func _get_text_length(text: String) -> int:
	var regex := RegEx.new()
	regex.compile("\\[.*?\\]") 
	var plain_text := regex.sub(text, "", true)
	return plain_text.length()
