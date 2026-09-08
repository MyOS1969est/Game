@tool
extends Node3D

const Kit := preload("res://art/mesh_kit.gd")
var light: MeshInstance3D
var focus_ring: MeshInstance3D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	Kit.box(self, Vector3(0, 0.71, 0), Vector3(2.18, 1.40, 0.38), Kit.TEAL, 0.11)
	Kit.box(self, Vector3(0, 0.72, 0.21), Vector3(1.82, 1.05, 0.075), Kit.TEAL.lightened(0.065), 0.07)
	for x: float in [-0.90, 0.90]:
		Kit.box(self, Vector3(x, 0.70, 0.02), Vector3(0.11, 1.29, 0.42), Kit.IVORY, 0.04)
		for y: float in [0.20, 1.20]:
			Kit.sphere(self, Vector3(x, y, 0.245), Vector3.ONE * 0.08, Kit.BRASS)
	Kit.box(self, Vector3(0, 0.72, 0.265), Vector3(0.70, 0.32, 0.09), Kit.INK, 0.035)
	Kit.rod(self, Vector3(-0.25, 0.69, 0.37), Vector3(0.25, 0.69, 0.37), 0.055, Kit.BRASS)
	for x: float in [-0.25, 0.25]:
		Kit.rod(self, Vector3(x, 0.69, 0.27), Vector3(x, 0.69, 0.37), 0.045, Kit.BRASS)
	Kit.label(self, "MANUAL RELEASE", Vector3(0, 1.02, 0.27), 22, 0.014)
	for i in 5:
		Kit.box(self, Vector3(-0.54 + float(i) * 0.27, 0.24, 0.242), Vector3(0.13, 0.065, 0.03), Kit.BRASS, 0.012)
	light = Kit.sphere(self, Vector3(0.61, 1.02, 0.27), Vector3.ONE * 0.10, Kit.BRASS)
	focus_ring = Kit.ring(self, Vector3(0, 0.046, 0.5), 0.73, 0.026, Kit.MINT)
	focus_ring.scale.z = 0.52
	focus_ring.visible = false

func set_focused(value: bool) -> void:
	focus_ring.visible = value

func mark_open() -> void:
	light.material_override = Kit.material(Kit.MINT, 0.3)
	focus_ring.visible = false
