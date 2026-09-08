@tool
extends Node3D
## Original Bloomed traveler art study. Visual animation never moves the collider.

const Kit := preload("res://art/mesh_kit.gd")
const COAT := Color("#b7773e")
const SKIN := Color("#b3bd83")
var left_leg: Node3D
var right_leg: Node3D
var left_arm: Node3D
var right_arm: Node3D
var forearm: Node3D
var torso: Node3D
var head: Node3D
var scarf: Node3D
var gait_phase := 0.0
var stride_weight := 0.0
var idle_time := 0.0
var reach_time := 0.0
var reach_duration := 0.65
var heavy_reach := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	left_leg = _leg(-0.18)
	right_leg = _leg(0.18)
	torso = Kit.node(self, "Torso", Vector3(0, 1.02, 0))
	Kit.box(torso, Vector3.ZERO, Vector3(0.67, 0.70, 0.44), COAT, 0.16)
	Kit.box(torso, Vector3(0, -0.28, 0), Vector3(0.72, 0.15, 0.49), COAT.darkened(0.10), 0.06)
	Kit.box(torso, Vector3(0, -0.18, 0), Vector3(0.70, 0.075, 0.47), Kit.INK, 0.025)
	Kit.box(torso, Vector3(0.08, -0.18, -0.25), Vector3(0.11, 0.10, 0.035), Kit.BRASS, 0.02)
	Kit.rod(torso, Vector3(-0.22, 0.29, -0.26), Vector3(0.2, -0.18, -0.26), 0.037, Kit.TEAL)
	Kit.sphere(torso, Vector3(-0.10, 0.12, -0.29), Vector3(0.095, 0.11, 0.06), Kit.BRASS)
	for side: float in [-1.0, 1.0]:
		Kit.box(torso, Vector3(side * 0.22, -0.035, -0.25), Vector3(0.15, 0.17, 0.035), COAT.lightened(0.06), 0.024)
	_scarf_and_pack()
	head = Kit.node(self, "Head", Vector3(0, 1.61, 0))
	Kit.sphere(head, Vector3(0, 0.045, 0.04), Vector3(0.68, 0.70, 0.61), Kit.TEAL)
	Kit.sphere(head, Vector3(0, 0.015, -0.18), Vector3(0.48, 0.51, 0.30), SKIN)
	Kit.box(head, Vector3(0, 0.235, -0.205), Vector3(0.50, 0.10, 0.17), Kit.TEAL.lightened(0.07), 0.045)
	for side: float in [-1.0, 1.0]:
		Kit.sphere(head, Vector3(side * 0.115, 0.055, -0.329), Vector3(0.073, 0.09, 0.037), Kit.INK)
		Kit.sphere(head, Vector3(side * 0.115 + 0.013, 0.076, -0.348), Vector3.ONE * 0.022, Kit.IVORY)
		Kit.sphere(head, Vector3(side * 0.24, -0.02, -0.13), Vector3(0.14, 0.22, 0.12), SKIN.darkened(0.04)).rotation.z = side * -0.38
	Kit.sphere(head, Vector3(0, -0.039, -0.351), Vector3(0.083, 0.070, 0.086), SKIN.lightened(0.08))
	Kit.box(head, Vector3(0, -0.126, -0.31), Vector3(0.09, 0.013, 0.014), SKIN.darkened(0.28), 0.004)
	# A small seed ornament is part of this model study, not a new lore assertion.
	Kit.rod(head, Vector3(-0.15, 0.29, 0.05), Vector3(-0.26, 0.51, 0.04), 0.022, Kit.BRASS)
	Kit.sphere(head, Vector3(-0.28, 0.49, 0.04), Vector3(0.16, 0.095, 0.06), Kit.MINT).rotation.z = -0.4
	left_arm = Kit.node(self, "AlteredArm", Vector3(-0.45, 1.31, 0))
	Kit.sphere(left_arm, Vector3(0, -0.08, 0), Vector3(0.41, 0.43, 0.39), Kit.LEAF)
	Kit.sphere(left_arm, Vector3(0, -0.25, 0), Vector3(0.30, 0.46, 0.32), Kit.LEAF.lightened(0.1))
	forearm = Kit.node(left_arm, "Forearm", Vector3(0, -0.37, 0))
	Kit.sphere(forearm, Vector3(0, -0.13, -0.045), Vector3(0.44, 0.47, 0.43), Kit.LEAF.lightened(0.19))
	for finger in 3:
		Kit.sphere(forearm, Vector3(-0.12 + float(finger) * 0.12, -0.37, -0.09), Vector3(0.105, 0.25, 0.16), Kit.MINT.darkened(0.06))
	Kit.sphere(forearm, Vector3(0.22, -0.18, -0.12), Vector3(0.14, 0.23, 0.16), Kit.LEAF.lightened(0.20)).rotation.z = -0.45
	for i in 4:
		Kit.sphere(forearm, Vector3(-0.13 + float(i % 2) * 0.20, 0.02 - float(i / 2) * 0.19, -0.235), Vector3(0.17, 0.20, 0.075), Kit.MINT).rotation.z = -0.16
	Kit.rod(left_arm, Vector3(-0.13, -0.14, -0.16), Vector3(-0.14, -0.55, -0.20), 0.018, Kit.LEAF.darkened(0.23))
	right_arm = Kit.node(self, "SleevedArm", Vector3(0.43, 1.29, 0))
	Kit.sphere(right_arm, Vector3(0, -0.15, 0), Vector3(0.29, 0.49, 0.30), COAT)
	Kit.sphere(right_arm, Vector3(0, -0.44, -0.02), Vector3(0.23, 0.28, 0.26), Kit.TEAL)
	Kit.box(right_arm, Vector3(0, -0.34, 0), Vector3(0.27, 0.09, 0.29), Kit.IVORY, 0.04)

func _leg(side: float) -> Node3D:
	var limb := Kit.node(self, "Leg", Vector3(side, 0.59, 0))
	Kit.sphere(limb, Vector3(0, -0.11, 0), Vector3(0.25, 0.45, 0.28), Kit.INK)
	Kit.box(limb, Vector3(0, -0.38, -0.08), Vector3(0.28, 0.23, 0.43), Kit.TEAL.darkened(0.13), 0.075)
	Kit.box(limb, Vector3(0, -0.48, -0.08), Vector3(0.29, 0.07, 0.44), Kit.INK, 0.025)
	Kit.box(limb, Vector3(0, -0.31, -0.05), Vector3(0.29, 0.075, 0.31), Kit.IVORY.darkened(0.1), 0.027)
	return limb

func _scarf_and_pack() -> void:
	Kit.sphere(torso, Vector3(0, 0.37, 0), Vector3(0.56, 0.21, 0.48), Kit.IVORY)
	scarf = Kit.node(torso, "ScarfTail", Vector3(0.18, 0.34, -0.24))
	Kit.box(scarf, Vector3(0, -0.17, 0), Vector3(0.16, 0.38, 0.055), Kit.IVORY, 0.026).rotation.z = -0.15
	var pack := Kit.node(torso, "SalvagePack", Vector3(0, 0.07, 0.34))
	Kit.box(pack, Vector3.ZERO, Vector3(0.53, 0.61, 0.28), Kit.TEAL, 0.09)
	Kit.box(pack, Vector3(0, 0.19, 0.025), Vector3(0.56, 0.23, 0.31), Kit.TEAL.lightened(0.11), 0.065)
	Kit.box(pack, Vector3(0, 0.01, 0.163), Vector3(0.09, 0.28, 0.035), Kit.BRASS, 0.012)
	Kit.cylinder(pack, Vector3(0, 0.42, 0.0), 0.13, 0.63, Kit.IVORY).rotation.z = PI * 0.5
	for side: float in [-1.0, 1.0]:
		Kit.ring(pack, Vector3(side * 0.2, 0.42, 0), 0.133, 0.019, Kit.INK).rotation.z = PI * 0.5
	Kit.cylinder(pack, Vector3(-0.33, -0.10, 0), 0.095, 0.27, Kit.BRASS)

func perform_interaction(heavy: bool = false) -> void:
	heavy_reach = heavy
	reach_duration = 0.70 if heavy else 0.48
	reach_time = reach_duration

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var actor := get_parent() as CharacterBody3D
	var horizontal_speed := Vector2(actor.velocity.x, actor.velocity.z).length()
	stride_weight = move_toward(stride_weight, minf(horizontal_speed / 4.2, 1.0), delta * 9.0)
	gait_phase += delta * (horizontal_speed * 5.0 + 0.15)
	idle_time += delta
	reach_time = maxf(0.0, reach_time - delta)
	var reach := sin((1.0 - reach_time / reach_duration) * PI) if reach_time > 0.0 else 0.0
	var swing := sin(gait_phase) * stride_weight
	left_leg.rotation.x = swing * 0.56
	right_leg.rotation.x = -swing * 0.56
	torso.position.y = 1.02 + absf(sin(gait_phase)) * stride_weight * 0.036 + sin(idle_time * 2.0) * 0.007
	torso.rotation.z = swing * 0.024
	left_arm.rotation.x = -swing * 0.27 + reach * (1.12 if heavy_reach else 0.60)
	left_arm.rotation.z = 0.10 + reach * 0.06
	forearm.rotation.x = reach * 0.28
	right_arm.rotation.x = swing * 0.38 + reach * 0.18
	scarf.rotation.x = sin(gait_phase - 0.4) * stride_weight * 0.10 + sin(idle_time * 1.9) * 0.028
	head.position.y = 1.61 + absf(sin(gait_phase)) * stride_weight * 0.026
	head.rotation.z = sin(idle_time * 1.2) * 0.018
	head.rotation.x = -reach * 0.10
