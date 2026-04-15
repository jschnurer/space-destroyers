extends Node2D
class_name InvaderBoss

@export var credit_value := 2500

@onready var chunks_by_frame: Array[InvaderBossBodyChunk] = [
	%ChunksFrame0,
	%ChunksFrame1,
	%ChunksFrame2,
	%ChunksFrame3,
]
@onready var dance_component: DanceComponent = %DanceComponent
@onready var independent_move_component: IndependentMoveComponent = %IndependentMoveComponent
@onready var tentacles: Node2D = %Tentacles
@onready var disgorgers: Node2D = %Disgorgers
@onready var game_over_animation: GameOverAnimation = %GameOverAnimation
@onready var game_over_animation_2: GameOverAnimation = %GameOverAnimation2
@onready var game_over_animation_3: GameOverAnimation = %GameOverAnimation3
@onready var game_over_animation_4: GameOverAnimation = %GameOverAnimation4
@onready var boom_roar_sound: AudioStreamPlayer = %BoomRoarSound
@onready var boom_roar_sound_2: AudioStreamPlayer = %BoomRoarSound2
@onready var explosion_handler: ExplosionHandler = %ExplosionHandler

signal boss_killed

var _tentacles_remaining := 0

func _ready() -> void:
	dance_component.frame_changed.connect(_on_dance_frame_changed)
	var tens := tentacles.get_children()
	_tentacles_remaining = tens.size()
	for t: InvaderBossTentacle in tens:
		t.destroyed.connect(_on_tentacle_destroyed)

func _on_dance_frame_changed(frame_index: int) -> void:
	for i in chunks_by_frame.size():
		chunks_by_frame[i].toggle(frame_index == i)

func toggle_attacking(is_enabled: bool) -> void:
	var children_nodes := find_children("*", "InvaderBossTentacle", true)
	for n in children_nodes:
		var asc := Utilities.get_first_child_of_type(n, AutoShootComponent)
		if asc as AutoShootComponent:
			(asc as AutoShootComponent).process_mode = Node.PROCESS_MODE_DISABLED if !is_enabled else Node.ProcessMode.PROCESS_MODE_INHERIT
	
	var other_nodes := find_children("*", "InvaderBossDisgorger", true)
	for n in other_nodes:
		(n as InvaderBossDisgorger).enabled = is_enabled

func _on_tentacle_destroyed() -> void:
	_tentacles_remaining -= 1
	if _tentacles_remaining == 0:
		SignalBus.emit_credits_picked_up(credit_value)
		explosion_handler.play()

func emit_boss_killed() -> void:
	boss_killed.emit()
