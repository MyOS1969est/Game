@tool
extends Node3D
## A compact ceramic scavenger with articulated brass legs and a warm optic.

const Kit := preload("res://art/mesh_kit.gd")
var legs: Array[Node3D] = []
var shell: Node3D
var antennae: Array[Node3D] = []
var phase := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	shell = Kit.node(self, "Shell", Vector3(0, 0.57, 0))
	Kit.sphere(shell, Vector3.ZERO, Vector3(1.01, 0.56, 1.12), Kit.INK)
	Kit.sphere(shell, Vector3(-0.23, 0.16, 0.06), Vector3(0.50, 0.40, 1.0), Kit.IVORY)
	Kit.sphere(shell, Vector3(0.23, 0.16, 0.06), Vector3(0.50, 0.40, 1.0), Kit.IVORY.darkened(0.06))
	Kit.rod(shell, Vector3(0, 0.37, -0.34), Vector3(0, 0.37, 0.4), 0.035, Kit.BRASS)
	Kit.cylinder(shell, Vector3(0, 0.02, -0.53), 0.21, 0.11, Kit.TEAL).rotation.x = PI * 0.5
	Kit.ring(shell, Vector3(0, 0.02, -0.60), 0.17, 0.032, Kit.BRASS).rotation.x = PI * 0.5
	Kit.sphere(shell, Vector3(0, 0.02, -0.62), Vector3(0.23, 0.23, 0.08), Color("#e7b95b")).material_override = Kit.material(Color("#e7b95b"), 0.38)
	for side: float in [-1.0, 1.0]:
		for i in 3:
			var z := -0.32 + float(i) * 0.32
			var leg := Kit.node(self, "Leg", Vector3(side * 0.37, 0.46, z))
			Kit.rod(leg, Vector3.ZERO, Vector3(side * 0.20, -0.15, 0.07), 0.055, Kit.BRASS)
			Kit.rod(leg, Vector3(side * 0.20, -0.15, 0.07), Vector3(side * 0.25, -0.39, 0), 0.04, Kit.TEAL)
			Kit.sphere(leg, Vector3(side * 0.25, -0.39, -0.015), Vector3(0.16, 0.12, 0.20), Kit.INK)
			legs.append(leg)
		var antenna := Kit.node(shell, "Antenna", Vector3(side * 0.28, 0.19, -0.39))
		Kit.rod(antenna, Vector3.ZERO, Vector3(side * 0.12, 0.32, -0.08), 0.026, Kit.BRASS)
		Kit.sphere(antenna, Vector3(side * 0.12, 0.32, -0.08), Vector3.ONE * 0.09, Kit.TEAL)
		antennae.append(antenna)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	phase += delta * 11.0
	for i in legs.size():
		legs[i].rotation.x = sin(phase + float(i % 2) * PI) * 0.32
		legs[i].position.y = 0.46 + maxf(0.0, sin(phase + float(i % 2) * PI)) * 0.045
	shell.position.y = 0.57 + sin(phase * 2.0) * 0.012
	for i in antennae.size():
		antennae[i].rotation.z = sin(phase * 0.24 + float(i)) * 0.09
