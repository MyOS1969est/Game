extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: ", label)
	else:
		failures.append(label)
		push_error("FAIL: " + label)

func frames(count: int) -> void:
	for frame in count:
		await physics_frame
	await process_frame

func tap(key: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = InputEventKey.new()
	event.physical_keycode = key
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame

func _run() -> void:
	var packed := load("res://main.tscn") as PackedScene
	if packed == null:
		push_error("Main scene failed to load.")
		quit(1)
		return
	var game := packed.instantiate()
	root.add_child(game)
	current_scene = game
	await frames(60)
	var player := game.get_node("Player") as CharacterBody3D
	var patrol := game.get_node("Scavenger") as CharacterBody3D
	var heirloom := game.get_node("Heirloom")
	var panel := game.get_node("MaintenancePanel")
	var camera := game.get_node("Camera") as Camera3D
	var rig := player.get_node("Visuals")
	var diorama := game.get_node("Courtyard/DioramaArt")
	check(player.get_script() != null and patrol.get_script() != null and heirloom.get_script() != null, "Behavior scripts are attached")
	check(player.is_on_floor() and player.position.y > -0.05, "Player rests on a solid floor")
	check(patrol.is_on_floor(), "Patrol rests on a solid floor")
	check(camera.is_current() and not camera.is_position_behind(player.global_position), "Camera faces the player")
	check(InputMap.action_has_event("move_forward", _key(KEY_W)), "WASD bindings exist")
	check(InputMap.action_has_event("move_forward", _key(KEY_UP)), "Arrow bindings exist")

	await tap(KEY_E)
	check(not heirloom.is_inspected and not panel.is_open, "Distant interaction has no effect")
	var start := player.position
	var patrol_start := patrol.position
	Input.action_press("move_right")
	await frames(20)
	Input.action_release("move_right")
	var movement := player.position - start
	check(movement.dot(camera.global_basis.x) > 0.8, "Movement follows camera right")
	check(patrol.position.distance_to(patrol_start) > 0.1, "Patrol advances")
	check(absf(rig.left_leg.rotation.x) > 0.04 and rig.stride_weight > 0.1, "Walking drives the traveler limb animation")
	Input.action_press("move_right")
	Input.action_press("move_forward")
	await frames(2)
	check(Vector2(player.velocity.x, player.velocity.z).length() <= float(player.speed) + 0.01, "Diagonal speed is normalized")
	Input.action_release("move_right")
	Input.action_release("move_forward")

	await tap(KEY_ESCAPE)
	start = player.position
	patrol_start = patrol.position
	var paused_gait: float = rig.gait_phase
	var paused_breeze: float = diorama.time
	Input.action_press("move_right")
	for frame in 12:
		await process_frame
	check(paused and player.position.is_equal_approx(start) and patrol.position.is_equal_approx(patrol_start), "Pause freezes both actors")
	check(is_equal_approx(rig.gait_phase, paused_gait) and is_equal_approx(diorama.time, paused_breeze), "Pause freezes character and environmental animation")
	Input.action_release("move_right")
	await tap(KEY_ESCAPE)
	check(not paused, "Escape resumes gameplay")

	player.position = Vector3(-5.7, 0.1, 1.1)
	player.velocity = Vector3.ZERO
	await frames(4)
	check(heirloom.get_node("Visuals").focus_ring.visible, "Nearby heirloom receives a visible focus cue")
	await tap(KEY_E)
	check(heirloom.is_inspected and not str(heirloom.learned_principle).is_empty(), "E inspection records knowledge")
	check(heirloom.condition == "Powered; feedstock empty", "Inspection preserves separate device condition")
	check("Notebook updated" in str(game.message_label.text), "Inspection gives visible feedback")
	check(heirloom.get_node("Visuals").glyph.text == "✓", "Discovery updates the machine's visible state")

	player.position = Vector3(-2.8, 0.1, -1.1)
	player.velocity = Vector3.ZERO
	await frames(4)
	var ray := PhysicsRayQueryParameters3D.create(Vector3(-2.8, 0.7, -1.7), Vector3(-2.8, 0.7, -3.4), 1)
	var hit := player.get_world_3d().direct_space_state.intersect_ray(ray)
	check(not hit.is_empty() and hit.collider == panel, "Closed panel physically blocks the route")
	player.can_shift_panels = false
	await tap(KEY_E)
	check(not panel.is_open, "Panel requires the bodily capability")
	player.can_shift_panels = true
	await tap(KEY_E)
	check(rig.reach_time > 0.0 and rig.heavy_reach, "Panel interaction triggers the altered-arm animation")
	await frames(40)
	check(panel.is_open and panel.get_node("Collision").disabled, "Mutation opens the route and removes its blocker")
	hit = player.get_world_3d().direct_space_state.intersect_ray(ray)
	check(hit.is_empty(), "Opened route is clear to physics")
	await frames(8)
	check(rig.reach_time <= 0.001, "Interaction animation settles after the push")
	# Use the player's unrotated movement fallback to walk straight through the tested gap.
	player.camera = null
	Input.action_press("move_forward")
	await frames(55)
	Input.action_release("move_forward")
	player.camera = camera
	check(game.route_reached, "Walking through the opened route completes its objective")
	check("COURTYARD COMPLETE" in str(game.progress_label.text), "Completing both objectives updates the HUD")
	Input.action_press("move_forward")
	await frames(140)
	Input.action_release("move_forward")
	check(player.position.y > -0.1 and absf(player.position.x) < 9 and absf(player.position.z) < 7, "Boundary collision keeps the player in the courtyard")

	var original_instance_id := game.get_instance_id()
	await tap(KEY_ESCAPE)
	await tap(KEY_R)
	await frames(8)
	check(current_scene != null and current_scene.get_instance_id() != original_instance_id and not paused, "R reloads and resumes the scene from pause")
	check(not current_scene.get_node("Heirloom").is_inspected and not current_scene.get_node("MaintenancePanel").is_open, "Reset clears prototype state")
	print("SMOKE RESULT: ", "PASS" if failures.is_empty() else "FAIL", " (", failures.size(), " failures)")
	quit(0 if failures.is_empty() else 1)

func _key(code: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = code
	return event
