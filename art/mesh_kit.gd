@tool
extends RefCounted
## Original, reusable geometry for the courtyard's ceramic / botanical art kit.
## Shared meshes and materials keep scene reloads and repeated props inexpensive.

const IVORY := Color("#d6cfb0")
const STONE := Color("#a6a88b")
const TEAL := Color("#396b69")
const INK := Color("#233f43")
const BRASS := Color("#bc9351")
const LEAF := Color("#64815a")
const MINT := Color("#a8ca83")
static var meshes: Dictionary = {}
static var materials: Dictionary = {}

static func material(color: Color, glow: float = 0.0, metallic: float = 0.0) -> StandardMaterial3D:
	var key := color.to_html() + str(glow) + str(metallic)
	if not materials.has(key):
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		mat.vertex_color_use_as_albedo = true
		mat.roughness = 0.78 if metallic == 0.0 else 0.48
		mat.metallic = metallic
		mat.metallic_specular = 0.3
		if glow > 0.0:
			mat.emission_enabled = true
			mat.emission = color
			mat.emission_energy_multiplier = glow
		materials[key] = mat
	return materials[key]

static func node(parent: Node3D, label: String, at: Vector3 = Vector3.ZERO) -> Node3D:
	var result := Node3D.new()
	result.name = label
	result.position = at
	parent.add_child(result)
	return result

static func instance(parent: Node3D, mesh: Mesh, at: Vector3, color: Color) -> MeshInstance3D:
	var result := MeshInstance3D.new()
	result.mesh = mesh
	result.position = at
	result.material_override = material(color)
	parent.add_child(result)
	return result

static func _triangle(st: SurfaceTool, points: Array[Vector3], normals: Array[Vector3], color: Color = Color.WHITE) -> void:
	# Godot front faces wind clockwise when viewed from outside the model.
	var order := [0, 1, 2]
	if (points[1] - points[0]).cross(points[2] - points[0]).dot(normals[0]) > 0.0:
		order = [0, 2, 1]
	for index: int in order:
		st.set_normal(normals[index])
		st.set_color(color)
		st.add_vertex(points[index])

static func quad(st: SurfaceTool, points: Array[Vector3], normal: Vector3, color: Color = Color.WHITE) -> void:
	_triangle(st, [points[0], points[1], points[2]], [normal, normal, normal], color)
	_triangle(st, [points[0], points[2], points[3]], [normal, normal, normal], color)

static func _rounded(point: Vector3, half: Vector3, radius: float) -> Vector3:
	var core := point.clamp(-half + Vector3.ONE * radius, half - Vector3.ONE * radius)
	return core + (point - core).normalized() * radius

static func box(parent: Node3D, at: Vector3, dimensions: Vector3, color: Color, bevel: float = 0.06) -> MeshInstance3D:
	var radius := clampf(bevel, 0.001, minf(dimensions.x, minf(dimensions.y, dimensions.z)) * 0.48)
	var key := "box" + str(dimensions) + str(radius)
	if not meshes.has(key):
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var half := dimensions * 0.5
		for axis in 3:
			var u := (axis + 1) % 3
			var v := (axis + 2) % 3
			var us := [-half[u], -half[u] + radius, half[u] - radius, half[u]]
			var vs := [-half[v], -half[v] + radius, half[v] - radius, half[v]]
			for side: float in [-1.0, 1.0]:
				for i in 3:
					for j in 3:
						var points: Array[Vector3] = []
						var normals: Array[Vector3] = []
						for corner: Vector2i in [Vector2i(i, j), Vector2i(i + 1, j), Vector2i(i + 1, j + 1), Vector2i(i, j + 1)]:
							var p := Vector3.ZERO
							p[axis] = half[axis] * side
							p[u] = us[corner.x]
							p[v] = vs[corner.y]
							var core := p.clamp(-half + Vector3.ONE * radius, half - Vector3.ONE * radius)
							normals.append((p - core).normalized())
							points.append(_rounded(p, half, radius))
						_triangle(st, [points[0], points[1], points[2]], [normals[0], normals[1], normals[2]])
						_triangle(st, [points[0], points[2], points[3]], [normals[0], normals[2], normals[3]])
		st.index()
		meshes[key] = st.commit()
	return instance(parent, meshes[key], at, color)

static func sphere(parent: Node3D, at: Vector3, dimensions: Vector3, color: Color) -> MeshInstance3D:
	if not meshes.has("sphere"):
		var mesh := SphereMesh.new()
		mesh.radius = 0.5
		mesh.height = 1.0
		mesh.radial_segments = 20
		mesh.rings = 12
		meshes["sphere"] = mesh
	var result := instance(parent, meshes["sphere"], at, color)
	result.scale = dimensions
	return result

static func cylinder(parent: Node3D, at: Vector3, radius: float, height: float, color: Color, top_radius: float = -1.0) -> MeshInstance3D:
	var top := radius if top_radius < 0.0 else top_radius
	var key := "cylinder" + str(radius) + "/" + str(height) + "/" + str(top)
	if not meshes.has(key):
		var mesh := CylinderMesh.new()
		mesh.bottom_radius = radius
		mesh.top_radius = top
		mesh.height = height
		mesh.radial_segments = 20
		meshes[key] = mesh
	return instance(parent, meshes[key], at, color)

static func rod(parent: Node3D, start: Vector3, end: Vector3, radius: float, color: Color, tip_radius: float = -1.0) -> MeshInstance3D:
	var delta := end - start
	var result := cylinder(parent, (start + end) * 0.5, radius, delta.length(), color, tip_radius)
	result.quaternion = Quaternion(Vector3.UP, delta.normalized())
	return result

static func ring(parent: Node3D, at: Vector3, radius: float, thickness: float, color: Color) -> MeshInstance3D:
	var key := "ring" + str(radius) + "/" + str(thickness)
	if not meshes.has(key):
		var mesh := TorusMesh.new()
		mesh.inner_radius = radius - thickness
		mesh.outer_radius = radius + thickness
		mesh.rings = 32
		mesh.ring_segments = 8
		meshes[key] = mesh
	return instance(parent, meshes[key], at, color)

static func label(parent: Node3D, words: String, at: Vector3, size: int = 32, pixel_size: float = 0.008) -> Label3D:
	var result := Label3D.new()
	result.text = words
	result.position = at
	result.font_size = size
	result.pixel_size = pixel_size
	result.modulate = IVORY.lightened(0.2)
	result.outline_modulate = INK
	result.outline_size = 5
	parent.add_child(result)
	return result

static func _leaf(st: SurfaceTool, base: Vector3, tip: Vector3, width: float, color: Color) -> void:
	var span := tip - base
	var across := span.cross(Vector3.UP).normalized() * width
	var middle := base + span * 0.48
	var ridge := middle + Vector3.UP * width * 0.3
	var left := middle + across
	var right := middle - across
	for raw: Array in [[base, left, ridge], [left, tip, ridge], [tip, right, ridge], [right, base, ridge]]:
		var points: Array[Vector3] = [raw[0], raw[1], raw[2]]
		var normal := (points[1] - points[0]).cross(points[2] - points[0]).normalized()
		if normal.y < 0:
			normal = -normal
		_triangle(st, points, [normal, normal, normal], color)

static func fern(parent: Node3D, at: Vector3, size: float, color: Color) -> MeshInstance3D:
	if not meshes.has("fern"):
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for frond in 7:
			var direction := Vector3(sin(float(frond) * TAU / 7.0), 0, cos(float(frond) * TAU / 7.0))
			var across := direction.cross(Vector3.UP)
			for pair in 6:
				var t := 0.12 + float(pair) * 0.14
				var base := direction * t * 0.95 + Vector3.UP * sin(t * PI * 0.75) * 0.56
				var reach := sin(t * PI) * 0.28 + 0.025
				for side: float in [-1.0, 1.0]:
					var tip := base + across * reach * side + direction * 0.17 + Vector3.UP * 0.09
					_leaf(st, base - direction * 0.05, tip, reach * 0.34, Color.WHITE.darkened(float(pair % 3) * 0.045))
			_leaf(st, direction * 0.73 + Vector3.UP * 0.55, direction * 1.15 + Vector3.UP * 0.6, 0.09, Color.WHITE)
		meshes["fern"] = st.commit()
	var result := instance(parent, meshes["fern"], at, color)
	result.scale = Vector3.ONE * size
	return result

static func broadleaf(parent: Node3D, at: Vector3, size: float, color: Color) -> MeshInstance3D:
	if not meshes.has("broadleaf"):
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for leaf in 6:
			var angle := float(leaf) * TAU / 6.0
			var tip := Vector3(sin(angle) * 0.62, 0.65 + float(leaf % 2) * 0.24, cos(angle) * 0.62)
			_leaf(st, Vector3(0, 0.05, 0), tip, 0.24, Color.WHITE.darkened(float(leaf % 3) * 0.05))
		meshes["broadleaf"] = st.commit()
	var result := instance(parent, meshes["broadleaf"], at, color)
	result.scale = Vector3.ONE * size
	return result

static func arch(parent: Node3D, at: Vector3, radii: Vector2, thickness: float, depth: float, color: Color) -> Node3D:
	var root := node(parent, "CeramicArch", at)
	for segment in 13:
		var a := float(segment) / 13.0 * PI + 0.004
		var b := float(segment + 1) / 13.0 * PI - 0.004
		var outline: Array[Vector3] = [
			Vector3(cos(a) * radii.x, sin(a) * radii.y, 0),
			Vector3(cos(b) * radii.x, sin(b) * radii.y, 0),
			Vector3(cos(b) * (radii.x - thickness), sin(b) * (radii.y - thickness), 0),
			Vector3(cos(a) * (radii.x - thickness), sin(a) * (radii.y - thickness), 0)]
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var front: Array[Vector3] = []
		var back: Array[Vector3] = []
		for p: Vector3 in outline:
			front.append(p + Vector3.BACK * depth * 0.5)
			back.append(p + Vector3.FORWARD * depth * 0.5)
		quad(st, front, Vector3.BACK)
		quad(st, back, Vector3.FORWARD)
		for edge in 4:
			var next := (edge + 1) % 4
			var normal := (outline[next] - outline[edge]).cross(Vector3.BACK).normalized()
			quad(st, [front[edge], front[next], back[next], back[edge]], normal)
		instance(root, st.commit(), Vector3.ZERO, color.darkened(float(segment % 3) * 0.025))
	return root
