extends Node3D

const INTERACTION_DISTANCE := 2.15
const FieldHUD := preload("res://ui/courtyard_hud.gd")
@onready var player: CharacterBody3D = $Player
@onready var heirloom: Area3D = $Heirloom
@onready var panel: StaticBody3D = $MaintenancePanel
var route_reached := false
var prompt_label: Label
var progress_label: Label
var message_label: Label
var pause_overlay: ColorRect
var hud: CanvasLayer
var focused: Node3D
var message_time := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_configure_input()
	$Camera.look_at(Vector3(0, 0.25, -0.4), Vector3.UP)
	player.camera = $Camera
	hud = FieldHUD.new()
	add_child(hud)
	prompt_label = hud.prompt_label
	progress_label = hud.progress_label
	message_label = hud.message_label
	pause_overlay = hud.pause_overlay
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
	if nearby != focused:
		if is_instance_valid(focused):
			focused.set_focused(false)
		focused = nearby
		if is_instance_valid(focused):
			focused.set_focused(true)
	prompt_label.text = str(nearby.call("get_prompt")) if nearby else "Explore the courtyard"
	if message_time > 0.0:
		message_time -= delta
		if message_time <= 0.0:
			message_label.text = "Your notebook remembers what the machinery forgot."
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
		player.play_interaction(nearby.global_position, nearby == panel and not panel.is_open and player.can_shift_panels)
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
	hud.update_progress(heirloom.is_inspected, panel.is_open, route_reached)
