extends Label
class_name ShopButtonLabel

func _ready() -> void:
	# Connect to the text_changed signal if you change text via code
	# Or just call this function whenever you set the text
	update_font_size()

func update_font_size() -> void:
	var font := get_theme_font("font")
	var parent_button: Button = get_parent()
	var max_width := parent_button.size.x
	var font_size := get_theme_font_size("font_size")
	
	var text_lines := text.split("\n")
	
	var largest_line_width := 0.0
	
	for line in text_lines:
		var text_size := font.get_string_size(line, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		if text_size.x > largest_line_width:
			largest_line_width = text_size.x
	
	if largest_line_width > max_width:
		# Calculate scale factor
		var scale_factor := max_width / largest_line_width
		# Apply a new font size or scale the transform
		self.scale = Vector2(scale_factor, scale_factor)
	else:
		self.scale = Vector2.ONE
