extends Area3D

signal inspected
var is_inspected: bool = false
var condition: String = "Powered; feedstock empty"
var learned_principle: String = ""

func _ready() -> void:
	add_to_group("interactables")

func get_prompt() -> String:
	return "E  Review dispenser" if is_inspected else "E  Inspect unidentified heirloom"

func interact(_player: CharacterBody3D) -> String:
	if is_inspected:
		return "Condition: %s. Known principle: %s." % [condition, learned_principle]
	is_inspected = true
	learned_principle = "Pressurized foam expands to cushion parcels"
	$Visuals.record_discovery()
	inspected.emit()
	return "Notebook updated: parcel-cushioning dispenser.\n\"Please remain unpackaged until processing is complete.\""

func set_focused(value: bool) -> void:
	$Visuals.set_focused(value)
