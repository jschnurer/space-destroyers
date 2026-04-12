extends Node2D

var _go_to_level_timeout := 0.0

func _process(delta: float) -> void:
	if _go_to_level_timeout > 0:
		_go_to_level_timeout -= delta
	
	if Input.is_action_just_pressed("nuke"):
		for en in get_tree().get_nodes_in_group(GroupNames.ENEMY):
			var lc: LifeComponent = (en as Enemy).get_component(LifeComponent)
			if lc:
				lc.take_damage(99999999.0, null)
	elif Input.is_action_just_pressed("pass_level") or Input.is_action_just_pressed("pass_level_shop"):
		var total_credits := 0.0
		for en in get_tree().get_nodes_in_group(GroupNames.ENEMY):
			var od: OnDeathComponent = (en as Enemy).get_component(OnDeathComponent)
			if od:
				total_credits += od.get_total_credit_value()
			en.queue_free()
		
		var mult := Game.get_stat_value(Enums.PlayerStats.CREDIT_MULTIPLIER)
		SignalBus.emit_credits_picked_up(total_credits * mult)
		Game.load_next_level(!Input.is_action_just_pressed("pass_level_shop"))
	elif Input.is_action_just_pressed("credits"):
		SignalBus.emit_credits_picked_up(99999999999)
	elif Input.is_action_just_pressed("launch"):
		_launch()
	elif Input.is_action_just_pressed("go_to_level"):
		_go_to_level_timeout = 1.0

func _input(event: InputEvent) -> void:
	if _go_to_level_timeout <= 0:
		return
	
	if event is InputEventKey:
		var e: InputEventKey = event
		if e.pressed:
			var lvl_num := e.as_text_keycode()
			if lvl_num.is_valid_int():
				var num := lvl_num.to_int()
				Game.go_to_level(num)
			

func _launch() -> void:
	var scene_file: PackedScene = load("res://scenes/rocket_launch_anim/rocket_launch_animation.tscn")
	var anim: Node2D = scene_file.instantiate()
	var player_tank: Tank = get_tree().get_first_node_in_group("PLAYER")
	anim.global_position = player_tank.global_position
	Utilities.add_child_to_level(anim, true)
	player_tank.visible = false
	get_tree().paused = true
