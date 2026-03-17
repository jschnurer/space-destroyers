extends CanvasLayer

var _disabled := false

@onready var button_container: GridContainer = %ButtonContainer
@onready var purchase_description: Label = %PurchaseDescription

func _ready() -> void:
	SignalBus.start_teleporting.connect(_on_start_teleporting)
	SignalBus.new_level_loaded.connect(_on_new_level_loaded)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_setup_hover_events()

func _process(_delta: float) -> void:
	if _disabled:
		return
	
	if Input.is_action_just_pressed("shop"):
		_toggle_shop()

func _toggle_shop() -> void:
	visible = !visible
	get_tree().paused = visible
	
	if visible:
		_on_appear()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_appear() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	for child in button_container.get_children():
		if child is ShopButton:
			(child as ShopButton).update_label_and_cost()

func _on_start_teleporting() -> void:
	_disabled = true
	
func _on_new_level_loaded() -> void:
	_disabled = false

func _setup_hover_events() -> void:
	for child in button_container.get_children():
		if child is ShopButton:
			var c := child as ShopButton
			c.mouse_entered.connect(_on_button_hovered.bind(c.hover_text))
			c.mouse_exited.connect(_on_button_exited)

func _on_button_hovered(text: String) -> void:
	purchase_description.text = text

func _on_button_exited() -> void:
	purchase_description.text = ""
