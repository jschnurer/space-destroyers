extends CanvasLayer
class_name MissionUpdateTextAnimation

@export var title_text := "MISSION UPDATE"
@export_multiline() var mission_text: String

@export_group("Options")
## Start playing immediately upon ready?
@export var autoplay := true
## Show confirm prompt after text, requiring player to press button.
@export var require_player_confirm := true
## If require_player_confirm is false, do not show confirm prompt after text, automatically
## continue after this amount of time.
@export var auto_confirm_time: float
## How many text characters appear per second.
@export var typing_chars_per_second := 35.0

@export_group("Audio")
@export var bgm: AudioStream
## How long to fade out the currently playing BGM.
@export var bgm_fade_out_time := 1.0
## How long to fade in the new BGM.
@export var bgm_fade_in_time := 1.0

@onready var title: Label = %Title
@onready var mission_text_label: RichTextLabel = %MissionText
@onready var klaxon_player: AudioStreamPlayer2D = %KlaxonPlayer
@onready var prompt_blink_timer: Timer = %PromptBlinkTimer
@onready var typing_audio_player: AudioStreamPlayer2D = %TypingAudioPlayer
@onready var continue_prompt: HBoxContainer = %ContinuePrompt

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
var _mission_text_pauses: Array[MessagePause] = []
var _visible_chars := 0.0
var _title_blink_tween: Tween
var _typing_is_paused := false

func _ready() -> void:
	_parse_text()
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
		_mode = Mode.DONE
		player_dismissed.emit()
	
	if _mode == Mode.TYPING:
		if !_typing_is_paused:
			_visible_chars += typing_chars_per_second * delta
			mission_text_label.visible_characters = floori(_visible_chars)
			
			# Check for and handle pauses.
			if _mission_text_pauses.size() > 0 \
				and _mission_text_pauses[0].index == mission_text_label.visible_characters - 1:
				_pause_typing(_mission_text_pauses[0].duration)
				_mission_text_pauses.pop_front()
		
		if mission_text_label.visible_characters >= _mission_text_length:
			_pause_before_prompt()

func _pause_typing(duration: float) -> void:
	typing_audio_player.stop()
	_typing_is_paused = true
	await get_tree().create_timer(duration).timeout
	typing_audio_player.play()
	_typing_is_paused = false

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
	
	if require_player_confirm:
		await get_tree().create_timer(1.0).timeout
		_show_continue_prompt()
	else:
		_mode = Mode.DONE
		if auto_confirm_time > 0:
			await get_tree().create_timer(auto_confirm_time).timeout
		player_dismissed.emit()

func _get_text_length(text: String) -> int:
	var regex := RegEx.new()
	regex.compile("\\[.*?\\]") 
	var plain_text := regex.sub(text, "", true)
	return plain_text.length()

func _parse_text() -> void:
	title.text = title_text
	mission_text_label.visible_characters = 0
	_parse_mission_text()
	_mission_text_length = _get_text_length(mission_text)

func _parse_mission_text() -> void:
	var regex := RegEx.new()
	# Find pause tags.
	regex.compile("\\[(?:p|pause)=(\\d+(?:\\.\\d+)?)\\]")

	var results: Array[MessagePause] = []
	var clean_text := mission_text
	var position_offset := 0

	var matches := regex.search_all(mission_text)

	for m in matches:
		var full_tag := m.get_string() # Entire pause tag
		var value_str := m.get_string(1) # Just the duration inside
		
		# Calculate the position in the "clean" string
		# Original start position minus how many characters we've already deleted
		var clean_index := m.get_start() - position_offset
		
		results.append(MessagePause.new(clean_index, value_str.to_float()))
		
		# Since tag is stripped from message, add its length to the index for later tags.
		position_offset += full_tag.length()
	
	# Strip out all pause tags
	clean_text = regex.sub(mission_text, "", true)
	mission_text_label.text = clean_text
	_mission_text_pauses = results

class MessagePause:
	var index: int
	var duration: float
	
	func _init(p_index: int, p_duration: float) -> void:
		index = p_index
		duration = p_duration
