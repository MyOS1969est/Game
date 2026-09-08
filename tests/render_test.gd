extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Visual verification requires a rendering display; headless is not a screenshot test.")
		quit(1)
		return
	var output := "user://courtyard.png"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--screenshot="):
			output = argument.trim_prefix("--screenshot=")
	var packed := load("res://main.tscn") as PackedScene
	var game := packed.instantiate()
	root.add_child(game)
	current_scene = game
	for frame in 30:
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("Renderer returned no image.")
		quit(1)
		return
	var error := image.save_png(output)
	if error != OK:
		push_error("Screenshot could not be saved: " + error_string(error))
		quit(1)
		return
	print("RENDER RESULT: PASS — ", image.get_width(), "x", image.get_height(), " at ", output)
	quit(0)
