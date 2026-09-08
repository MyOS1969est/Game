@tool
extends Node3D
## A deliberately composed, reusable diorama. Decorations do not change the
## verified collision layout or the two courtyard objectives.

const Kit := preload("res://art/mesh_kit.gd")
var breeze: Array[Node3D] = []
var motes: Array[Node3D] = []
var time := 0.0

func _ready() -> void:
	name = "DioramaArt"
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_floor_and_inlay()
	_structure()
	_service_props()
	_gardens()
	for i in 12:
		var mote := Kit.sphere(self, Vector3.ZERO, Vector3.ONE * (0.018 + float(i % 3) * 0.009), Color("#d5d6a3"))
		mote.material_override = Kit.material(Color("#d5d6a3"), 0.35)
		mote.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		motes.append(mote)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	time += delta
	for i in breeze.size():
		breeze[i].rotation.z = sin(time * 0.8 + float(i) * 1.7) * 0.018
	for i in motes.size():
		var phase := float(i) * 2.399
		motes[i].position = Vector3(sin(phase + time * 0.035) * 7.3, 0.9 + float(i % 4) * 0.46 + sin(time * 0.5 + phase) * 0.16, cos(phase) * 4.6)

func _solid(label: String, at: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = label
	body.position = at
	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	add_child(body)

func _floor_and_inlay() -> void:
	Kit.box(self, Vector3(0, -0.57, 0), Vector3(18.45, 0.95, 14.4), Color("#46574c"), 0.36)
	Kit.box(self, Vector3(0, -0.24, 0), Vector3(18.1, 0.45, 14.1), Color("#817e61"), 0.18)
	Kit.box(self, Vector3(0, -0.10, 0), Vector3(17.6, 0.20, 13.6), Color("#929174"), 0.1)
	# Wide quiet paving keeps the walkable space readable against the plant beds.
	for x in 12:
		for z in 9:
			if (x == 0 or x == 11) and z % 3 != 0:
				continue
			var at := Vector3(-7.5 + float(x) * 1.37, 0.014, -5.47 + float(z) * 1.36)
			var shade := float(posmod(x * 7 + z * 3, 5)) * 0.019
			var tile := Kit.box(self, at, Vector3(1.30, 0.028, 1.29), Color("#bcb493").darkened(shade), 0.018)
			tile.rotation.y = sin(float(x * 31 + z * 17)) * 0.014
	# The old parcel-service seal is inlaid into the floor, not a new game system.
	var seal := Kit.node(self, "ParcelServiceSeal", Vector3(0.3, 0.032, 1.3))
	Kit.cylinder(seal, Vector3.ZERO, 1.66, 0.012, Color("#8e9b83"))
	Kit.ring(seal, Vector3(0, 0.011, 0), 1.48, 0.018, Kit.IVORY)
	Kit.ring(seal, Vector3(0, 0.012, 0), 1.36, 0.011, Kit.TEAL)
	for angle in 8:
		var a := float(angle) * TAU / 8.0
		var direction := Vector3(sin(a), 0, cos(a))
		Kit.rod(seal, direction * 1.39 + Vector3.UP * 0.015, direction * 1.53 + Vector3.UP * 0.015, 0.021, Kit.TEAL)
	var parcel := Kit.box(seal, Vector3(0, 0.018, 0), Vector3(0.95, 0.016, 0.95), Kit.IVORY, 0.007)
	parcel.rotation.y = PI * 0.25
	Kit.box(seal, Vector3(0, 0.03, 0), Vector3(0.09, 0.018, 0.8), Kit.TEAL, 0.008)
	# The low plinth has a cut-stone edge rather than a floating white slab.
	for i in 9:
		Kit.box(self, Vector3(-7.8 + float(i) * 1.95, -0.45, 6.98), Vector3(1.83, 0.51, 0.25), Kit.STONE.darkened(float(i % 3) * 0.025), 0.07)
	for i in 7:
		Kit.box(self, Vector3(8.83, -0.45, -5.7 + float(i) * 1.9), Vector3(0.28, 0.51, 1.78), Kit.STONE, 0.07)

func _wall(at: Vector3, size: Vector3) -> void:
	Kit.box(self, at, size, Kit.IVORY, 0.075)
	Kit.box(self, at + Vector3.UP * (size.y * 0.5 + 0.015), Vector3(size.x + 0.08, 0.12, size.z + 0.10), Kit.STONE.lightened(0.12), 0.05)

func _structure() -> void:
	# Keep the repaired topology: same solid rims, dividers and 2.4 m gate opening.
	_solid("BackWall", Vector3(0, 0.85, -6.7), Vector3(18, 1.7, 0.5))
	_solid("FrontRim", Vector3(0, 0.23, 6.7), Vector3(18, 0.46, 0.5))
	_solid("LeftRim", Vector3(-8.7, 0.5, 0), Vector3(0.5, 1, 13))
	_solid("RightRim", Vector3(8.7, 0.5, 0), Vector3(0.5, 1, 13))
	_solid("DividerLeft", Vector3(-6.5, 0.6, -2.5), Vector3(5, 1.2, 0.4))
	_solid("DividerRight", Vector3(3.7, 0.6, -2.5), Vector3(10.6, 1.2, 0.4))
	for x in 9:
		_wall(Vector3(-7.94 + float(x) * 1.98, 0.83, -6.7), Vector3(1.92, 1.66, 0.5))
	for x in 9:
		_wall(Vector3(-7.94 + float(x) * 1.98, 0.23, 6.7), Vector3(1.92, 0.46, 0.5))
	for z in 7:
		_wall(Vector3(-8.7, 0.49, -5.6 + float(z) * 1.87), Vector3(0.5, 0.98, 1.80))
		_wall(Vector3(8.7, 0.49, -5.6 + float(z) * 1.87), Vector3(0.5, 0.98, 1.80))
	_wall(Vector3(-6.5, 0.6, -2.5), Vector3(5, 1.2, 0.4))
	_wall(Vector3(3.7, 0.6, -2.5), Vector3(10.6, 1.2, 0.4))
	# Rounded pier bases, banded ceramic columns, and individual arch stones.
	for x: float in [-7.2, 0.2, 7.3]:
		_solid("ServicePillar", Vector3(x, 1.65, -5.9), Vector3(1, 3.3, 1))
		Kit.box(self, Vector3(x, 0.16, -5.9), Vector3(1.35, 0.32, 1.35), Kit.STONE, 0.12)
		Kit.box(self, Vector3(x, 1.7, -5.9), Vector3(0.96, 2.95, 0.96), Kit.IVORY, 0.18)
		Kit.box(self, Vector3(x, 2.86, -5.9), Vector3(1.15, 0.19, 1.15), Kit.TEAL, 0.045)
		Kit.box(self, Vector3(x, 3.13, -5.9), Vector3(1.28, 0.22, 1.28), Kit.IVORY, 0.075)
		Kit.box(self, Vector3(x, 1.24, -5.39), Vector3(0.34, 0.70, 0.03), Kit.STONE, 0.012)
	Kit.arch(self, Vector3(3.75, 2.93, -5.9), Vector2(3.54, 1.35), 0.35, 0.86, Kit.IVORY)
	var badge := Kit.node(self, "ServiceSeal", Vector3(3.75, 3.72, -5.35))
	Kit.cylinder(badge, Vector3.ZERO, 0.48, 0.10, Kit.TEAL).rotation.x = PI * 0.5
	Kit.ring(badge, Vector3(0, 0, 0.07), 0.43, 0.025, Kit.BRASS).rotation.x = PI * 0.5
	Kit.label(badge, "03", Vector3(0, 0, 0.11), 50, 0.011)
	# A partially surviving lintel beside the tree gives the ruin an asymmetry.
	Kit.box(self, Vector3(-6.25, 3.3, -5.9), Vector3(2.7, 0.32, 1.05), Kit.IVORY, 0.09).rotation.z = -0.055
	for x: float in [-4.0, -1.6]:
		Kit.box(self, Vector3(x, 0.81, -2.52), Vector3(0.15, 1.62, 0.58), Kit.TEAL, 0.04)
		Kit.sphere(self, Vector3(x, 1.63, -2.51), Vector3(0.22, 0.17, 0.22), Kit.BRASS)
	Kit.rod(self, Vector3(-4.0, 0.08, -2.57), Vector3(0.9, 0.08, -2.57), 0.045, Kit.TEAL)
	# Inlaid wayfinding on the already tested side-route area.
	Kit.box(self, Vector3(-3, 0.024, -4.8), Vector3(1.8, 0.025, 1.6), Kit.TEAL, 0.012)
	for offset: float in [-0.28, 0.28]:
		Kit.rod(self, Vector3(-3 + offset, 0.06, -4.7), Vector3(-3, 0.06, -5.0), 0.04, Kit.IVORY)
	var wayfinding := Kit.label(self, "SIDE ROUTE", Vector3(-3, 0.47, -5.54), 24, 0.014)
	wayfinding.billboard = BaseMaterial3D.BILLBOARD_ENABLED

func _service_props() -> void:
	_solid("ServiceCabinet", Vector3(6.7, 1.1, -4.8), Vector3(1.2, 2.2, 0.8))
	var cabinet := Kit.node(self, "OldServiceCabinet", Vector3(6.7, 0, -4.8))
	Kit.box(cabinet, Vector3(0, 1.0, 0), Vector3(1.18, 2.0, 0.75), Kit.TEAL, 0.14)
	Kit.box(cabinet, Vector3(0, 2.04, 0), Vector3(1.3, 0.18, 0.89), Kit.IVORY, 0.08)
	Kit.box(cabinet, Vector3(0, 1.22, 0.4), Vector3(0.76, 0.62, 0.04), Kit.INK, 0.012)
	Kit.box(cabinet, Vector3(0, 1.25, 0.44), Vector3(0.51, 0.27, 0.02), Kit.BRASS, 0.009)
	for i in 4:
		Kit.box(cabinet, Vector3(0, 0.4 + float(i) * 0.13, 0.4), Vector3(0.74, 0.035, 0.04), Kit.INK, 0.012)
	Kit.rod(cabinet, Vector3(-0.9, 0.1, -0.1), Vector3(-0.9, 1.6, -0.1), 0.10, Kit.BRASS)
	Kit.rod(cabinet, Vector3(-0.9, 1.6, -0.1), Vector3(-0.55, 1.6, -0.1), 0.10, Kit.BRASS)
	_solid("RepairCrate", Vector3(-7.2, 0.4, 0), Vector3(1, 0.8, 0.8))
	_crate(Vector3(-7.2, 0, 0), 1.0, -0.08)
	_crate(Vector3(-7.15, 0.78, -0.12), 0.62, 0.14)
	# Small parcel stacks frame the back wall; they stay outside the route lane.
	_crate(Vector3(1.5, 0, -5.4), 0.75, 0.09)
	_crate(Vector3(2.25, 0, -5.6), 0.55, -0.12)
	for at: Vector3 in [Vector3(-6.1, 0, -4.9), Vector3(5.8, 0, -0.9)]:
		Kit.cylinder(self, at + Vector3.UP * 0.34, 0.27, 0.66, Kit.IVORY, 0.22)
		Kit.ring(self, at + Vector3.UP * 0.62, 0.23, 0.045, Kit.TEAL)
		Kit.ring(self, at + Vector3.UP * 0.11, 0.26, 0.027, Kit.BRASS)
	# Light posts establish warmth and the old service facility's visual language.
	for at: Vector3 in [Vector3(-7.8, 0, 3.2), Vector3(7.8, 0, 2.5)]:
		Kit.cylinder(self, at + Vector3.UP * 0.1, 0.24, 0.2, Kit.STONE)
		Kit.rod(self, at + Vector3.UP * 0.2, at + Vector3.UP * 1.42, 0.07, Kit.TEAL)
		Kit.sphere(self, at + Vector3.UP * 1.48, Vector3(0.32, 0.40, 0.32), Color("#e9c779")).material_override = Kit.material(Color("#e9c779"), 0.35)
		Kit.cylinder(self, at + Vector3.UP * 1.73, 0.24, 0.12, Kit.TEAL, 0.09)

func _crate(at: Vector3, size: float, angle: float) -> void:
	var root := Kit.node(self, "SalvagedParcel", at)
	root.rotation.y = angle
	root.scale = Vector3.ONE * size
	Kit.box(root, Vector3(0, 0.37, 0), Vector3(0.95, 0.74, 0.76), Color("#a4794e"), 0.07)
	for x: float in [-0.29, 0.29]:
		Kit.box(root, Vector3(x, 0.37, 0), Vector3(0.07, 0.77, 0.80), Kit.INK, 0.018)
	Kit.box(root, Vector3(0, 0.42, 0.4), Vector3(0.31, 0.21, 0.025), Kit.IVORY, 0.008)

func _garden(at: Vector3, size: float, index: int) -> void:
	var patch := Kit.node(self, "FernBed", at)
	patch.rotation.y = float(index) * 1.7
	Kit.sphere(patch, Vector3(0, 0.015, 0), Vector3(size * 1.95, 0.11, size * 1.35), Color("#58694c"))
	for i in 3:
		var angle := float(i) * 2.4
		var spot := Vector3(sin(angle) * size * 0.48, 0.07, cos(angle) * size * 0.34)
		var plant := Kit.node(patch, "Fronds", spot)
		if i == 1:
			Kit.broadleaf(plant, Vector3.ZERO, size * 0.73, Kit.LEAF.lightened(0.1))
		else:
			Kit.fern(plant, Vector3.ZERO, size * (0.67 + float(i) * 0.12), Kit.LEAF.lightened(float(index % 3) * 0.06))
		breeze.append(plant)
	for i in 3:
		var p := Vector3(sin(float(i * 7 + index)) * size * 0.7, 0.09, cos(float(i * 4 + index)) * size * 0.48)
		Kit.sphere(patch, p, Vector3(0.31, 0.21, 0.28), Kit.STONE.darkened(0.14))
	if index % 3 == 0:
		for i in 3:
			var p := Vector3(-0.23 + float(i) * 0.2, 0, 0.15)
			Kit.rod(patch, p, p + Vector3.UP * (0.3 + float(i % 2) * 0.15), 0.017, Kit.LEAF)
			Kit.sphere(patch, p + Vector3.UP * (0.33 + float(i % 2) * 0.15), Vector3(0.13, 0.11, 0.13), Color("#d9ae64"))

func _tree(at: Vector3, size: float, angle: float) -> void:
	var root := Kit.node(self, "CourtyardTree", at)
	root.rotation.y = angle
	root.scale = Vector3.ONE * size
	var bark := Color("#716b50")
	var points: Array[Vector3] = [Vector3.ZERO, Vector3(-0.12, 1.45, 0.1), Vector3(0.14, 2.75, -0.1), Vector3(0, 3.95, 0)]
	for i in 3:
		Kit.rod(root, points[i], points[i + 1], 0.25 - float(i) * 0.045, bark, 0.20 - float(i) * 0.045)
	for i in 5:
		var a := float(i) * TAU / 5.0
		var end := Vector3(sin(a) * 0.85, 0.07, cos(a) * 0.85)
		Kit.rod(root, Vector3(0, 0.42, 0), end, 0.12, bark, 0.025)
	for i in 5:
		var a := float(i) * 2.4
		var end := Vector3(sin(a) * 0.96, 3.48 + float(i % 3) * 0.34, cos(a) * 0.8)
		Kit.rod(root, Vector3(0, 2.6 + float(i % 2) * 0.35, 0), end, 0.095, bark, 0.045)
		Kit.sphere(root, end + Vector3.UP * 0.3, Vector3(1.9, 1.1, 1.65), Kit.LEAF.darkened(float(i % 3) * 0.07))
	Kit.sphere(root, Vector3(0, 4.18, 0), Vector3(2.1, 1.08, 1.8), Kit.LEAF.lightened(0.10))
	for i in 4:
		Kit.broadleaf(root, Vector3(sin(float(i) * 2.4) * 0.4, float(i) * 0.45 + 0.15, cos(float(i) * 2.4) * 0.2), 0.37, Kit.LEAF)

func _gardens() -> void:
	var patches: Array[Vector3] = [Vector3(-7.8, 0, -4.3), Vector3(-5.6, 0, -5.8), Vector3(-0.8, 0, -5.8), Vector3(7.6, 0, -3.7), Vector3(7.8, 0, -1.4), Vector3(8, 0, 4.7), Vector3(-7.8, 0, 4.8), Vector3(-6.5, 0, 5.9), Vector3(5.8, 0, 5.9), Vector3(1.5, 0, -1.9), Vector3(6.7, 0, -1.9), Vector3(-7.7, 0, 1.7), Vector3(7.8, 0, 0.7)]
	for i in patches.size():
		_garden(patches[i], 0.85 + float(i % 3) * 0.19, i)
	_tree(Vector3(-7.5, 0, -5.7), 1.0, 0.0)
	_tree(Vector3(7.9, 0, -5.9), 0.79, 1.3)
	# Ivy follows the columns instead of covering the interactive route.
	for i in 7:
		var at := Vector3(0.18 + sin(float(i) * 1.5) * 0.42, 0.25 + float(i) * 0.47, -5.35)
		Kit.broadleaf(self, at, 0.36, Kit.LEAF.darkened(0.02))
		if i < 6:
			Kit.rod(self, at, at + Vector3(0.08, 0.47, 0), 0.025, Kit.LEAF)
