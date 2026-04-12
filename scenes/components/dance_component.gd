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

## Current frame of animation.
@export var current_frame := 0:
	set(value):
		current_frame = value
		if sprite:
			sprite.frame = value

var _is_playing := false
var _play_time := 0.0

func _ready() -> void:
	if auto_play:
		play()

func _process(delta: float) -> void:
	if !_is_playing:
		return
	
	_play_time += delta * fps
	
	var new_frame := int(_play_time) % frame_count
	
	if new_frame != current_frame:
		current_frame = new_frame

## Plays the animation from the first frame.
func play() -> void:
	_play_time = 0.0
	_is_playing = true
	current_frame = 0

## Pauses the animation, but keeps current frame.
func pause() -> void:
	_is_playing = false

## Resumes animation from the current frame.
func resume() -> void:
	_is_playing = true
