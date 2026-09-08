@tool
extends Node3D

const Kit := preload("res://art/mesh_kit.gd")
const Models := preload("res://art/corner/models.gd")
var focus_ring: MeshInstance3D
var optic: MeshInstance3D
var glyph: Label3D
var light: MeshInstance3D
var time := 0.0
var known := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	for asset: String in ["dispenser_shell", "dispenser_hardware", "dispenser_vessel"]:
		Models.place(self, asset)
	# The imported geometry and gameplay indicator are separate. Inspection
	# changes knowledge and this visible state without changing device condition.
	optic = Kit.ring(self, Vector3(0, 1.43, 0.588), 0.177, 0.023, Color("#d99c43"))
	optic.rotation.x = PI * 0.5
	optic.material_override = Kit.material(Color("#d99c43"), 0.65)
	glyph = Kit.label(self, "?", Vector3(0, 1.435, 0.614), 48, 0.0057)
	glyph.modulate = Color("#e5c887")
	Kit.label(self, "PARCEL CARE", Vector3(0, 1.965, 0.481), 30, 0.0055)
	light = Kit.sphere(self, Vector3(0.46, 1.10, 0.491), Vector3(0.09, 0.09, 0.027), Color("#e0b964"))
	light.material_override = Kit.material(Color("#e0b964"), 0.28)
	focus_ring = Kit.ring(self, Vector3(0, 0.045, 0), 1.0, 0.025, Kit.MINT)
	focus_ring.material_override = Kit.material(Kit.MINT, 0.22)
	focus_ring.visible = false

func set_focused(value: bool) -> void:
	focus_ring.visible = value

func record_discovery() -> void:
	known = true
	glyph.text = "✓"
	glyph.modulate = Kit.MINT
	light.material_override = Kit.material(Kit.MINT, 0.3)
	optic.material_override = Kit.material(Kit.MINT, 0.55)
	create_tween().tween_property(glyph, "scale", Vector3.ONE * 1.18, 0.12).set_trans(Tween.TRANS_SINE)
	create_tween().tween_property(glyph, "scale", Vector3.ONE, 0.30).set_delay(0.12)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	time += delta
	if focus_ring.visible:
		focus_ring.scale = Vector3.ONE * (1.0 + sin(time * 3.0) * 0.025)
	light.scale = Vector3(0.09, 0.09, 0.027) * (1.0 + sin(time * 2.0) * 0.035)
