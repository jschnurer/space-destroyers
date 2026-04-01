extends CanvasLayer

@export var shop_bgm: AudioStream
@export var level_bgm: AudioStream

@onready var purchase_description: Label = %PurchaseDescription
@onready var stats_ui: Control = %StatsUI

var _input_enabled := false

func _ready() -> void:
	SignalBus.open_shop.connect(_on_open_shop)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_setup_hover_events()

func _process(_delta: float) -> void:
	if !_input_enabled:
		return
	
	if Input.is_action_just_pressed("shop"):
		_toggle_shop(false)

func _toggle_shop(p_visible: bool) -> void:
	if !p_visible:
		_fade_out_shop()
	else:
		_fade_in_shop()

func _on_open_shop() -> void:
	_toggle_shop(true)

func _fade_in_shop() -> void:
	visible = true
	stats_ui.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var button_nodes := get_tree().get_nodes_in_group("SHOP_BUTTON")
	for button in button_nodes:
		if button is ShopButton:
			(button as ShopButton).update_label_and_cost()
	
	_toggle_shop_music(true)
			
	var screen_fader: ScreenFader = get_tree().get_first_node_in_group("SCREEN_FADER")
	
	if screen_fader:
		screen_fader.fade_in()
		await screen_fader.fade_complete
	
	_toggle_input(true)

func _fade_out_shop() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	_toggle_input(false)
	_toggle_shop_music(false)
	
	var screen_fader: ScreenFader = get_tree().get_first_node_in_group("SCREEN_FADER")
	
	if screen_fader:
		screen_fader.fade_out()
		await screen_fader.fade_complete
	
	visible = false
	stats_ui.visible = false
	SignalBus.shop_closed.emit()

func _toggle_input(p_enabled: bool) -> void:
	_input_enabled = p_enabled
	var nodes := get_tree().get_nodes_in_group("SHOP_BUTTON")
	for node in nodes:
		if node is not Button and node is not ShopButton:
			continue 
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE if !p_enabled else Control.MOUSE_FILTER_STOP

func _setup_hover_events() -> void:
	var button_nodes := get_tree().get_nodes_in_group("SHOP_BUTTON")
	for button in button_nodes:
		if button is ShopButton:
			var c := button as ShopButton
			if c.is_player_stat:
				c.mouse_entered.connect(_on_button_hovered.bind(GameManager.get_stat(c.player_stat).description))
			elif c.is_player_upgrade:
				c.mouse_entered.connect(_on_button_hovered.bind(GameManager.get_upgrade(c.player_upgrade).description))
			c.mouse_exited.connect(_on_button_exited)

func _on_button_hovered(text: String) -> void:
	purchase_description.text = text

func _on_button_exited() -> void:
	purchase_description.text = ""

func _toggle_shop_music(play_shop_bgm: bool) -> void:
	SignalBus.emit_play_bgm(shop_bgm if play_shop_bgm else level_bgm, 1.0, 1.0, 1.0, 1.0)
