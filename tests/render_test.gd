extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func frames(count: int) -> void:
	for frame in count:
		await physics_frame
	await process_frame

func capture(path: String) -> bool:
	await RenderingServer.frame_post_draw
	var picture := root.get_texture().get_image()
	if picture == null or picture.is_empty():
		push_error("Renderer returned no image.")
		return false
	var error := picture.save_png(path)
	if error != OK:
		push_error("Screenshot could not be saved: " + error_string(error))
		return false
	return true

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Visual verification requires a rendering display; headless is not a screenshot test.")
		quit(1)
		return
	var output := "user://courtyard.png"
	var showcase := false
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--screenshot="):
			output = argument.trim_prefix("--screenshot=")
		if argument == "--showcase":
			showcase = true
	var packed := load("res://main.tscn") as PackedScene
	var game := packed.instantiate()
	root.add_child(game)
	current_scene = game
	await frames(30)
	if not await capture(output):
		quit(1)
		return
	if showcase:
		var camera := game.get_node("Camera") as Camera3D
		var player := game.get_node("Player") as CharacterBody3D
		var original_camera := camera.transform
		var original_size := camera.size
		game.hud.visible = false
		camera.size = 4.8
		var subject := player.position + Vector3.UP * 1.0
		camera.position = subject + Vector3(3.0, 2.0, 4.5)
		camera.look_at(subject)
		await frames(6)
		if not await capture(output.get_basename() + "-traveler.png"):
			quit(1)
			return
		var motion_dir := output.get_base_dir().path_join("courtyard-motion")
		DirAccess.make_dir_recursive_absolute(motion_dir)
		# These are real engine frames: normal movement input, followed by the
		# same visual push gesture that the maintenance-panel interaction calls.
		player.camera = null
		Input.action_press("move_right")
		for index in 75:
			if index == 45:
				Input.action_release("move_right")
				player.play_interaction(player.position + Vector3.BACK, true)
			await frames(2)
			subject = player.position + Vector3.UP * 1.0
			camera.position = subject + Vector3(3.0, 2.0, 4.5)
			camera.look_at(subject)
			if not await capture(motion_dir.path_join("frame%03d.png" % index)):
				quit(1)
				return
		Input.action_release("move_right")
		camera.transform = original_camera
		camera.size = original_size
		game.hud.visible = true
		# Capture the full scene with both objectives completed to check the HUD
		# and the open passage as well as the pristine opening composition.
		player.position = Vector3(-5.7, 0.1, 1.1)
		player.velocity = Vector3.ZERO
		await frames(5)
		game.interact_nearest()
		player.position = Vector3(-2.8, 0.1, -1.1)
		player.velocity = Vector3.ZERO
		await frames(5)
		game.interact_nearest()
		await frames(45)
		Input.action_press("move_forward")
		await frames(55)
		Input.action_release("move_forward")
		player.camera = camera
		await frames(5)
		if not game.route_reached or not game.heirloom.is_inspected:
			push_error("Rendered walkthrough did not complete both objectives.")
			quit(1)
			return
		if not await capture(output.get_basename() + "-complete.png"):
			quit(1)
			return
	print("RENDER RESULT: PASS — ", root.size.x, "x", root.size.y, " at ", output)
	quit(0)
