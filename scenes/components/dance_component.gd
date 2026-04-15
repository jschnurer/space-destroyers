@tool
extends Node
class_name DanceComponent

## The sprite to animate.
@export var sprite: Sprite2D
## Number of frames.
@export var frame_count := 2
## Speed scale of the animation.
@export var fps := 5.0
## Start animation on ready?
@export var auto_play := true
## If true, animation bounces (1,2,3,4,3,2,1).
@export var bounce := false
## If not 0,0, a random start time between x-y seconds will be added to initial time on start.
@export var random_start_time: Vector2

## Current frame of animation.
@export var current_frame := 0:
	set(value):
		current_frame = value
		if sprite:
			sprite.frame = value

@export_tool_button("Play") var play_button := play
@export_tool_button("Pause") var stop_botton := pause

signal frame_changed(frame_index: int)

var _is_playing := false
var _play_time := 0.0

func _ready() -> void:
	if auto_play:
		play()

func _process(delta: float) -> void:
	if !_is_playing or frame_count <= 1:
		return
	
	_play_time += delta * fps
	
	var new_frame: int
	if !bounce:
		new_frame = int(fposmod(_play_time, float(frame_count)))
	else:
		new_frame = round(pingpong(_play_time, float(frame_count - 1)))
	
	if new_frame != current_frame:
		current_frame = new_frame
		frame_changed.emit(current_frame)

## Plays the animation from the first frame.
func play() -> void:
	_play_time = 0.0 if random_start_time == Vector2.ZERO else randf_range(random_start_time.x, random_start_time.y)
	_is_playing = true
	current_frame = 0
	frame_changed.emit(current_frame)

## Pauses the animation, but keeps current frame.
func pause() -> void:
	_is_playing = false

## Resumes animation from the current frame.
func resume() -> void:
	_is_playing = true
