@tool
extends RefCounted
## Shared, editable material definitions for the Blender-authored corner kit.

const Surface := preload("res://art/corner/surface.gdshader")
const Leaf := preload("res://art/corner/leaf.gdshader")
static var library: Dictionary = {}
static var noise: NoiseTexture2D

static func _noise() -> NoiseTexture2D:
	if noise == null:
		var source := FastNoiseLite.new()
		source.seed = 1937
		source.frequency = 0.045
		source.fractal_octaves = 4
		noise = NoiseTexture2D.new()
		noise.width = 256
		noise.height = 256
		noise.seamless = true
		noise.generate_mipmaps = true
		noise.noise = source
	return noise

static func get_material(kind: String) -> Material:
	if library.has(kind):
		return library[kind]
	if kind == "Leaf":
		var leaf := ShaderMaterial.new()
		leaf.shader = Leaf
		leaf.resource_name = "Thin veined leaf"
		library[kind] = leaf
		return leaf
	var values := {
		"Ceramic": ["#d0c6a9", "#a59b7d", 0.36, 0.0, 2.0, 0.0015, 0.10, 0.35, 0.16],
		"Stone": ["#b8b39c", "#777b60", 0.87, 0.0, 2.6, 0.006, 0.34, 0.50, 0.0],
		"Enamel": ["#396c69", "#839388", 0.34, 0.12, 4.8, 0.0015, 0.13, 0.60, 0.24],
		"Brass": ["#ad894c", "#55756a", 0.38, 0.76, 7.0, 0.0007, 0.10, 0.45, 0.0],
		"Rubber": ["#29332f", "#485447", 0.92, 0.0, 6.0, 0.006, 0.18, 0.15, 0.0],
		"Soil": ["#4b553a", "#6b714a", 0.98, 0.0, 3.0, 0.025, 0.38, 0.30, 0.0],
		"Bark": ["#61563e", "#818565", 0.90, 0.0, 2.0, 0.022, 0.32, 0.40, 0.0],
	}
	var settings: Array = values.get(kind, values["Stone"])
	var mat := ShaderMaterial.new()
	mat.shader = Surface
	mat.resource_name = kind
	mat.set_shader_parameter("surface_noise", _noise())
	mat.set_shader_parameter("base_color", Color(settings[0]))
	mat.set_shader_parameter("worn_color", Color(settings[1]))
	for i in 7:
		mat.set_shader_parameter(["roughness", "metallic", "grain_scale", "relief_depth", "mottling", "wear_amount", "glaze"][i], settings[i + 2])
	library[kind] = mat
	return mat

static func set_breeze(time: float) -> void:
	var leaf := get_material("Leaf") as ShaderMaterial
	leaf.set_shader_parameter("breeze_time", time)
