extends CanvasLayer
## A compact field-notebook interface. All displayed mechanics exist in this scene.

const PAPER := Color("#efe4c7")
const MUTED := Color("#aebca9")
const GOLD := Color("#c7a870")
var message_label: Label
var prompt_label: Label
var progress_label: Label
var pause_overlay: ColorRect
var task_label: Label
var screen: Control

func _ready() -> void:
	name = "FieldNotebookHUD"
	screen = Control.new()
	add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_header()
	_notebook()
	_footer()
	_pause()

func _text(parent: Node, words: String, size: int, color: Color = PAPER) -> Label:
	var label := Label.new()
	label.text = words
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.025, 0.07, 0.075, 0.65))
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _panel() -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.065, 0.135, 0.145, 0.94)
	style.border_color = Color(0.36, 0.44, 0.39, 0.65)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 17
	style.content_margin_right = 17
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	style.shadow_color = Color(0.02, 0.05, 0.05, 0.25)
	style.shadow_size = 8
	panel.add_theme_stylebox_override("panel", style)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.add_child(panel)
	return panel

func _header() -> void:
	var row := HBoxContainer.new()
	row.position = Vector2(30, 27)
	row.add_theme_constant_override("separation", 12)
	screen.add_child(row)
	var crest := TextureRect.new()
	crest.texture = preload("res://ui/crest.svg")
	crest.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	crest.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	crest.custom_minimum_size = Vector2(52, 52)
	row.add_child(crest)
	var words := VBoxContainer.new()
	words.add_theme_constant_override("separation", 0)
	row.add_child(words)
	_text(words, "AFTERMARKET", 28)
	_text(words, "THE HEIRLOOMS  /  SERVICE COURTYARD", 11, MUTED)
	var rule := ColorRect.new()
	rule.position = Vector2(32, 96)
	rule.size = Vector2(55, 2)
	rule.color = GOLD
	screen.add_child(rule)
	var region := _text(screen, "Everything still works.", 13, MUTED)
	region.position = Vector2(101, 86)

func _notebook() -> void:
	var panel := _panel()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	panel.offset_left = -304
	panel.offset_right = -28
	panel.offset_top = 28
	panel.offset_bottom = 132
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 5)
	panel.add_child(column)
	_text(column, "FIELD NOTES   /   01", 11, GOLD)
	progress_label = _text(column, "", 15)
	task_label = _text(column, "An old rule. A new way through.", 11, MUTED)

func _footer() -> void:
	var panel := _panel()
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_left = 28
	panel.offset_right = -28
	panel.offset_top = -138
	panel.offset_bottom = -24
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 23)
	panel.add_child(row)
	var body := VBoxContainer.new()
	body.custom_minimum_size.x = 215
	body.add_theme_constant_override("separation", 4)
	row.add_child(body)
	_text(body, "BLOOMED TRAVELER", 10, GOLD)
	_text(body, "An altered arm", 19)
	_text(body, "Some doors require a different body.", 11, MUTED)
	var divider := ColorRect.new()
	divider.custom_minimum_size.x = 1
	divider.color = Color(0.34, 0.43, 0.38, 0.6)
	row.add_child(divider)
	var context := VBoxContainer.new()
	context.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	context.add_theme_constant_override("separation", 4)
	row.add_child(context)
	prompt_label = _text(context, "Explore the courtyard", 19)
	message_label = _text(context, "", 13, MUTED)
	message_label.custom_minimum_size.y = 33
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text(context, "WASD / ARROWS  Move     E  Interact     ESC  Pause     R  Replay", 11, GOLD)

func _pause() -> void:
	pause_overlay = ColorRect.new()
	pause_overlay.color = Color(0.025, 0.085, 0.095, 0.90)
	screen.add_child(pause_overlay)
	pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_overlay.visible = false
	var label := _text(pause_overlay, "TAKE A BREATH\n\nThe courtyard can wait.\n\nESC to continue   ·   R to replay", 25)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func update_progress(inspected: bool, open: bool, reached: bool) -> void:
	var mark := "1 / 1" if inspected else "0 / 1"
	var route := "REACHED" if reached else ("OPEN" if open else "SEALED")
	progress_label.text = "NOTEBOOK   %s\nSIDE ROUTE   %s" % [mark, route]
	if inspected and reached:
		progress_label.text = "COURTYARD COMPLETE"
		task_label.text = "A useful discovery. An unexpected door."
	elif inspected:
		task_label.text = "Your altered arm can shift the panel."
	else:
		task_label.text = "Investigate the old dispenser."
