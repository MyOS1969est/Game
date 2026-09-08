extends Node3D

const INTERACTION_DISTANCE := 2.15
const CREAM := Color("#e5dcc0")
const TEAL := Color("#456c6b")
const MOSS := Color("#6d8552")
const AMBER := Color("#dfa34a")

@onready var player: CharacterBody3D = $Player
@onready var heirloom: Area3D = $Heirloom
@onready var panel: StaticBody3D = $MaintenancePanel
var route_reached := false
var prompt_label: Label
var progress_label: Label
var message_label: Label
var pause_overlay: ColorRect
var message_time := 0.0
var materials: Dictionary = {}

func _ready() -> void:
	# Keep pause/reset input alive; physical actors explicitly use PAUSABLE.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_configure_input()
	$Camera.look_at(Vector3(0, 0, -0.4), Vector3.UP)
	player.camera = $Camera
	_build_courtyard()
	_build_ui()
	$SideRoute.body_entered.connect(_on_side_route_entered)
	heirloom.inspected.connect(_update_progress)
	panel.opened.connect(_update_progress)
	_update_progress()
	show_message("Inspect the old dispenser, then use your altered arm to open the side route.", 9.0)

func _configure_input() -> void:
	var bindings := {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_forward": [KEY_W, KEY_UP],
		"move_back": [KEY_S, KEY_DOWN],
		"interact": [KEY_E],
		"pause_game": [KEY_ESCAPE],
		"reset_courtyard": [KEY_R],
	}
	for action: String in bindings:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for key in bindings[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_courtyard") and not event.is_echo():
		get_tree().paused = false
		get_tree().reload_current_scene()
	elif event.is_action_pressed("pause_game") and not event.is_echo():
		toggle_pause()
	elif event.is_action_pressed("interact") and not event.is_echo() and not get_tree().paused:
		interact_nearest()

func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	pause_overlay.visible = get_tree().paused

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	var nearby := nearest_interactable()
	prompt_label.text = str(nearby.call("get_prompt")) if nearby else "Explore the courtyard"
	if message_time > 0.0:
		message_time -= delta
		if message_time <= 0.0:
			message_label.text = ""
	if player.position.y < -5.0:
		player.position = Vector3(-4.8, 0.2, 3.6)
		player.velocity = Vector3.ZERO
		show_message("Returned to the courtyard entrance.")

func nearest_interactable() -> Node3D:
	var nearest: Node3D
	var shortest := INTERACTION_DISTANCE
	for candidate in get_tree().get_nodes_in_group("interactables"):
		var node := candidate as Node3D
		if not is_ancestor_of(node):
			continue
		var distance := player.global_position.distance_to(node.global_position)
		if distance < shortest:
			nearest = node
			shortest = distance
	return nearest

func interact_nearest() -> void:
	var nearby := nearest_interactable()
	if nearby:
		show_message(str(nearby.call("interact", player)), 7.0)

func show_message(message: String, seconds: float = 5.0) -> void:
	message_label.text = message
	message_time = seconds

func _on_side_route_entered(body: Node3D) -> void:
	if body == player and panel.is_open and not route_reached:
		route_reached = true
		_update_progress()
		show_message("Side route reached. A useful arm changes where you can go.", 7.0)

func _update_progress() -> void:
	var knowledge := "1 / 1" if heirloom.is_inspected else "0 / 1"
	var route := "REACHED" if route_reached else ("OPEN" if panel.is_open else "SEALED")
	progress_label.text = "NOTEBOOK  %s     •     SIDE ROUTE  %s" % [knowledge, route]
	if heirloom.is_inspected and route_reached:
		progress_label.text = "COURTYARD COMPLETE     •     R TO REPLAY"

func _material(color: Color) -> StandardMaterial3D:
	if not materials.has(color):
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 0.85
		materials[color] = material
	return materials[color]

func _box(label: String, position_at: Vector3, dimensions: Vector3, color: Color, solid: bool = false) -> MeshInstance3D:
	var parent: Node3D = $Courtyard
	if solid:
		var body := StaticBody3D.new()
		body.name = label
		body.position = position_at
		parent.add_child(body)
		var shape := BoxShape3D.new()
		shape.size = dimensions
		var collision := CollisionShape3D.new()
		collision.shape = shape
		body.add_child(collision)
		parent = body
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	mesh.material = _material(color)
	var visual := MeshInstance3D.new()
	visual.name = label + "Mesh"
	visual.mesh = mesh
	if not solid:
		visual.position = position_at
	parent.add_child(visual)
	return visual

func _plant(position_at: Vector3, size: float, index: int) -> void:
	for leaf in range(5):
		var mesh := SphereMesh.new()
		mesh.radius = 0.5
		mesh.height = 1.0
		mesh.radial_segments = 12
		mesh.rings = 6
		mesh.material = _material(MOSS.lightened(float((index + leaf) % 3) * 0.08))
		var visual := MeshInstance3D.new()
		visual.mesh = mesh
		var angle := float(leaf) * TAU / 5.0 + float(index)
		visual.position = position_at + Vector3(cos(angle) * size * 0.22, size * 0.32, sin(angle) * size * 0.22)
		visual.scale = Vector3(size * 0.4, size * 0.95, size * 0.65)
		visual.rotation = Vector3(0.45, angle, 0.18)
		$Courtyard.add_child(visual)

func _sign(text: String, position_at: Vector3, size: int = 32) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = position_at
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = size
	label.pixel_size = 0.008
	label.modulate = Color("#f8ebc9")
	label.outline_modulate = Color("#243c3b")
	label.outline_size = 8
	$Courtyard.add_child(label)

func _build_courtyard() -> void:
	# Original modular placeholder geometry; no generated image is used as game geometry.
	_box("BackWall", Vector3(0, 0.85, -6.7), Vector3(18, 1.7, 0.5), CREAM, true)
	_box("FrontRim", Vector3(0, 0.23, 6.7), Vector3(18, 0.46, 0.5), CREAM, true)
	_box("LeftRim", Vector3(-8.7, 0.5, 0), Vector3(0.5, 1, 13), CREAM, true)
	_box("RightRim", Vector3(8.7, 0.5, 0), Vector3(0.5, 1, 13), CREAM, true)
	_box("DividerLeft", Vector3(-6.5, 0.6, -2.5), Vector3(5, 1.2, 0.4), CREAM, true)
	_box("DividerRight", Vector3(3.7, 0.6, -2.5), Vector3(10.6, 1.2, 0.4), CREAM, true)
	for x in range(-7, 9, 2):
		for z in range(-5, 7, 2):
			var tint := Color("#c4b390").lightened(float(posmod(x + z, 3)) * 0.018)
			_box("Paving", Vector3(x - 0.1, 0.012, z - 0.05), Vector3(1.85, 0.025, 1.84), tint)
	for x in [-7.2, 0.2, 7.3]:
		_box("ServicePillar", Vector3(x, 1.65, -5.9), Vector3(1, 3.3, 1), CREAM, true)
		_box("PillarCap", Vector3(x, 3.35, -5.9), Vector3(1.16, 0.2, 1.16), TEAL)
	_box("Lintel", Vector3(3.7, 3.4, -5.9), Vector3(7.2, 0.5, 1.05), CREAM)
	_box("ServiceCabinet", Vector3(6.7, 1.1, -4.8), Vector3(1.2, 2.2, 0.8), TEAL, true)
	_box("CabinetLight", Vector3(6.7, 1.4, -4.35), Vector3(0.55, 0.4, 0.06), AMBER)
	_box("RepairCrate", Vector3(-7.2, 0.4, 0), Vector3(1, 0.8, 0.8), Color("#b78250"), true)
	_box("SideRouteMarker", Vector3(-3, 0.055, -4.8), Vector3(1.9, 0.1, 1.7), TEAL)
	_sign("SIDE ROUTE", Vector3(-3, 0.6, -5.5), 24)
	_sign("STILL USEFUL", Vector3(-5.7, 2.65, -0.4), 22)
	var patches := [
		Vector3(-7.8, 0, -5.7), Vector3(-5.7, 0, -5.8), Vector3(-0.8, 0, -5.8),
		Vector3(7.8, 0, -5.7), Vector3(7.8, 0, -1.4), Vector3(8, 0, 3.8),
		Vector3(-7.8, 0, 4.8), Vector3(-6.6, 0, 5.9), Vector3(5.8, 0, 5.9),
		Vector3(1.5, 0, -1.9), Vector3(6, 0, -1.9), Vector3(-7.7, 0, 1.7)]
	for index in patches.size():
		_plant(patches[index], 0.9 + float(index % 3) * 0.25, index)

func _label(parent: Node, text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("#f2e7ce"))
	label.add_theme_color_override("font_shadow_color", Color(0.06, 0.12, 0.13, 0.85))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUD"
	add_child(layer)
	var screen := Control.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(screen)
	var header := VBoxContainer.new()
	header.position = Vector2(30, 22)
	header.add_theme_constant_override("separation", 4)
	screen.add_child(header)
	_label(header, "AFTERMARKET", 31)
	_label(header, "SERVICE COURTYARD  /  FIRST PLAYABLE", 14)
	progress_label = _label(header, "", 16)

	var footer := VBoxContainer.new()
	screen.add_child(footer)
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_left = 30
	footer.offset_right = -30
	footer.offset_top = -132
	footer.offset_bottom = -18
	footer.add_theme_constant_override("separation", 8)
	message_label = _label(footer, "", 16)
	message_label.custom_minimum_size.y = 44
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_label = _label(footer, "", 22)
	_label(footer, "WASD / ARROWS  Move     E  Interact     ESC  Pause     R  Reset", 15)

	pause_overlay = ColorRect.new()
	pause_overlay.color = Color(0.06, 0.13, 0.14, 0.86)
	screen.add_child(pause_overlay)
	pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_overlay.visible = false
	var pause_text := _label(pause_overlay, "PAUSED\n\nESC to continue  •  R to reset", 28)
	pause_text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
