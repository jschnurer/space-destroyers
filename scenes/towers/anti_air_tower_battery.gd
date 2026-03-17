extends Node2D

func _ready() -> void:
	GameManager.player_upgrade_changed.connect(_on_player_upgrade_changed)
	_disable_all_towers()
	_enable_towers(GameManager.get_player_upgrade(Enums.PlayerUpgrades.ANTI_AIR))

func _on_player_upgrade_changed(upgrade: Enums.PlayerUpgrades, value: float) -> void:
	if upgrade != Enums.PlayerUpgrades.ANTI_AIR:
		return
	_enable_towers(value)

func _enable_towers(num_towers: float) -> void:
	for i in range(int(num_towers)):
		var t := find_child("Tower" + str(i + 1))
		if t and t is AntiAirTower:
			t.process_mode = Node.PROCESS_MODE_PAUSABLE
			(t as AntiAirTower).visible = true

func _disable_all_towers() -> void:
	for child in get_children():
		if child is AntiAirTower:
			child.process_mode = Node.PROCESS_MODE_DISABLED
			(child as AntiAirTower).visible = false
