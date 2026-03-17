extends Node
class_name DanceComponent

## The sprite to animate.
@export var sprite: Sprite2D
## Speed scale of the animation.
@export var speed_scale := 1.0
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
	
	_play_time += delta * speed_scale
	
	if _play_time >= 2.0:
		if current_frame != 1:
			current_frame = 1
		_play_time = 0.0
	elif _play_time >= 1.0:
		if current_frame != 0:
			current_frame = 0

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
