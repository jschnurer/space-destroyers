extends CanvasLayer

@onready var credits_display: Label = %CreditsDisplay
@onready var speed_display: Label = %SpeedDisplay
@onready var pickup_display: Label = %PickupDisplay
@onready var credit_multiplier_display: Label = %CreditMultiplierDisplay
@onready var max_shots_display: Label = %MaxShotsDisplay
@onready var power_display: Label = %PowerDisplay
@onready var shot_speed_display: Label = %ShotSpeedDisplay
@onready var reload_display: Label = %ReloadDisplay
@onready var level_number: Label = %LevelNumber
@onready var teleport_delay_display: Label = %TeleportDelayDisplay
@onready var luck_display: Label = %LuckDisplay

@onready var anti_air_display := UpgradeDisplay.new(Enums.PlayerUpgrades.ANTI_AIR,\
	%AntiAirTowersHolder as Control, %AntiAirTowers as Label, true, "%d")
@onready var seeking_missiles_display := UpgradeDisplay.new(Enums.PlayerUpgrades.MISSILES,\
	%SeekingMissileHolder as Control, %SeekingMissiles as Label, true, "%d")
@onready var laser_sight: Label = %LaserSight
@onready var twin_cannon: Label = %TwinCannon
@onready var auto_fire: Label = %AutoFire
@onready var left_wall: Label = %LeftWall
@onready var right_wall: Label = %RightWall

func _ready() -> void:
	GameManager.credits_changed.connect(_on_credits_changed)
	GameManager.player_stat_changed.connect(_update_stats)
	GameManager.player_upgrade_changed.connect(_update_upgrades.unbind(2))
	SignalBus.level_transition_screen_faded.connect(_on_level_transition_screen_faded)
	
	_on_credits_changed()
	# Update all the labels (ignores params)
	_update_stats(Enums.PlayerStats.TANK_SPEED, null)
	_update_upgrades()

func _on_level_transition_screen_faded() -> void:
	level_number.text = str(GameManager.current_level)

func _on_credits_changed() -> void:
	credits_display.text = "%.2f" % GameManager.credits

func _update_stats(_stat: Enums.PlayerStats, _value: PlayerStat) -> void:
	speed_display.text = "%.2f" % GameManager.get_player_stat_curr_value(Enums.PlayerStats.TANK_SPEED)
	pickup_display.text = "%.2f" % GameManager.get_player_stat_curr_value(Enums.PlayerStats.PICKUP_AREA)
	luck_display.text = "%.2f" % GameManager.get_player_stat_curr_value(Enums.PlayerStats.LUCK)
	credit_multiplier_display.text = ("%.2f" % GameManager.get_player_stat_curr_value(Enums.PlayerStats.CREDIT_MULTIPLIER)) + "x"
	max_shots_display.text = str(GameManager.get_player_stat_curr_value(Enums.PlayerStats.MAX_SHOTS))
	power_display.text = "%.2f" % GameManager.get_player_stat_curr_value(Enums.PlayerStats.SHOT_POWER)
	shot_speed_display.text = str(GameManager.get_player_stat(Enums.PlayerStats.SHOT_SPEED).percent_modifier * 100.0) + "%"
	reload_display.text = str(GameManager.get_player_stat(Enums.PlayerStats.RELOAD).percent_modifier * 100.0) + "%"
	teleport_delay_display.text = "%.2f" % GameManager.get_player_stat_curr_value(Enums.PlayerStats.TELEPORT_DELAY)

func _update_upgrades() -> void:
	laser_sight.visible = GameManager.has_upgrade(Enums.PlayerUpgrades.LASER_SIGHT)
	twin_cannon.visible = GameManager.has_upgrade(Enums.PlayerUpgrades.TWIN_CANNON)
	auto_fire.visible = GameManager.has_upgrade(Enums.PlayerUpgrades.AUTO_FIRE)
	seeking_missiles_display.update()
	anti_air_display.update()
	left_wall.visible = GameManager.has_upgrade(Enums.PlayerUpgrades.RETAINING_WALL_LEFT)
	right_wall.visible = GameManager.has_upgrade(Enums.PlayerUpgrades.RETAINING_WALL_RIGHT)

class UpgradeDisplay:
	var upgrade: Enums.PlayerUpgrades
	var holder: Control
	var label: Label
	var show_label: bool
	var label_format: String
	
	func _init(p_upgrade: Enums.PlayerUpgrades, p_holder: Control, p_label: Label, p_show_label: bool,\
		p_label_format: String) -> void:
		upgrade = p_upgrade
		holder = p_holder
		label = p_label
		show_label = p_show_label
		label_format = p_label_format
	
	func update(value_override: String = "") -> void:
		if !GameManager.has_upgrade(upgrade):
			holder.visible = false
			return
		
		holder.visible = true
		
		if show_label and label:
			label.text = value_override if value_override != "" else (label_format % GameManager.get_player_upgrade(upgrade))
		elif label:
			label.visible = false
