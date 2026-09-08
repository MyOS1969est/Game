@tool
extends Node3D

const Kit := preload("res://art/mesh_kit.gd")
var focus_ring: MeshInstance3D
var optic: MeshInstance3D
var glyph: Label3D
var light: MeshInstance3D
var time := 0.0
var known := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	Kit.box(self, Vector3(0, 0.12, 0), Vector3(1.35, 0.24, 1.0), Kit.INK, 0.10)
	Kit.box(self, Vector3(0, 1.08, 0), Vector3(1.18, 1.86, 0.92), Kit.IVORY, 0.20)
	Kit.box(self, Vector3(0, 1.93, 0), Vector3(1.30, 0.23, 1.00), Kit.TEAL, 0.10)
	Kit.box(self, Vector3(0, 1.18, 0.476), Vector3(0.86, 1.06, 0.10), Kit.TEAL, 0.10)
	Kit.cylinder(self, Vector3(0, 1.40, 0.56), 0.29, 0.04, Kit.INK).rotation.x = PI * 0.5
	Kit.ring(self, Vector3(0, 1.4, 0.592), 0.275, 0.027, Kit.BRASS).rotation.x = PI * 0.5
	optic = Kit.sphere(self, Vector3(0, 1.4, 0.59), Vector3(0.48, 0.48, 0.03), Kit.INK)
	glyph = Kit.label(self, "?", Vector3(0, 1.41, 0.622), 48, 0.010)
	glyph.modulate = Color("#ddba69")
	Kit.box(self, Vector3(0, 0.86, 0.545), Vector3(0.62, 0.15, 0.055), Kit.INK, 0.025)
	Kit.box(self, Vector3(0, 0.77, 0.61), Vector3(0.68, 0.075, 0.19), Kit.BRASS, 0.025)
	for i in 3:
		Kit.sphere(self, Vector3(-0.17 + float(i) * 0.17, 0.52, 0.468), Vector3.ONE * 0.075, Kit.BRASS)
	Kit.label(self, "PARCEL CARE", Vector3(0, 1.96, 0.53), 24, 0.010)
	Kit.box(self, Vector3(0.34, 0.26, 0.47), Vector3(0.15, 0.07, 0.025), Kit.TEAL, 0.01)
	# A side pressure vessel and returning hose explain the machine physically.
	Kit.cylinder(self, Vector3(-0.70, 1.03, -0.02), 0.17, 0.91, Kit.TEAL)
	Kit.sphere(self, Vector3(-0.70, 1.5, -0.02), Vector3(0.33, 0.19, 0.33), Kit.BRASS)
	for y: float in [0.65, 1.35]:
		Kit.ring(self, Vector3(-0.70, y, -0.02), 0.175, 0.025, Kit.BRASS)
	var hose: Array[Vector3] = [Vector3(-0.70, 0.62, -0.02), Vector3(-0.81, 0.36, -0.06), Vector3(-0.71, 0.19, -0.12), Vector3(-0.40, 0.18, -0.12)]
	for i in 3:
		Kit.rod(self, hose[i], hose[i + 1], 0.042, Kit.INK)
		Kit.sphere(self, hose[i], Vector3.ONE * 0.088, Kit.INK)
	Kit.rod(self, Vector3(0.37, 2.0, 0), Vector3(0.37, 2.24, 0), 0.035, Kit.BRASS)
	light = Kit.sphere(self, Vector3(0.37, 2.27, 0), Vector3(0.17, 0.21, 0.17), Color("#e0b964"))
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
	create_tween().tween_property(glyph, "scale", Vector3.ONE * 1.18, 0.12).set_trans(Tween.TRANS_SINE)
	create_tween().tween_property(glyph, "scale", Vector3.ONE, 0.30).set_delay(0.12)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	time += delta
	if focus_ring.visible:
		focus_ring.scale = Vector3.ONE * (1.0 + sin(time * 3.0) * 0.025)
	light.scale = Vector3.ONE * (1.0 + sin(time * 2.0) * 0.035)
