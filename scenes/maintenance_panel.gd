extends StaticBody3D

signal opened
var is_open: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("interactables")

func get_prompt() -> String:
	return "E  Read maintenance label" if is_open else "E  Use altered arm to shift panel"

func interact(player: CharacterBody3D) -> String:
	if is_open:
		return "Side route open. Maintenance thanks you for your additional leverage."
	if not player.get("can_shift_panels"):
		return "The panel needs more leverage. Your altered arm can provide it."
	is_open = true
	$Collision.set_deferred("disabled", true)
	create_tween().tween_property($Visuals, "position:x", 2.4, 0.55).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	opened.emit()
	return "Side route opened.\n\"Panel relocated. Paperwork remains in its original position.\""
