@tool
extends RefCounted

const Materials := preload("res://art/corner/materials.gd")
static var scenes: Dictionary = {}

static func place(parent: Node3D, asset: String, at: Vector3 = Vector3.ZERO, dimensions: Vector3 = Vector3.ONE, angle: float = 0.0) -> Node3D:
	if not scenes.has(asset):
		scenes[asset] = load("res://art/corner/models/" + asset + ".glb") as PackedScene
	var packed := scenes[asset] as PackedScene
	assert(packed != null, "Corner model failed to import: " + asset)
	var model := packed.instantiate() as Node3D
	model.name = asset.to_pascal_case()
	model.position = at
	model.scale = dimensions
	model.rotation.y = angle
	_apply_materials(model)
	parent.add_child(model)
	return model

static func _apply_materials(node: Node) -> void:
	if node is MeshInstance3D:
		var instance := node as MeshInstance3D
		for i in instance.mesh.get_surface_count():
			var source := instance.mesh.surface_get_material(i)
			var kind := source.resource_name if source != null else "Stone"
			instance.set_surface_override_material(i, Materials.get_material(kind))
	for child in node.get_children():
		_apply_materials(child)
