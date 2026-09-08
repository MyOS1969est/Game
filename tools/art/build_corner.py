"""Editable Blender source for AFTERMARKET's first dispenser-corner model kit.

Run: blender --background --factory-startup --python-exit-code 1
             --python tools/art/build_corner.py

Coordinates in the construction helpers are Godot coordinates (Y up, +Z front).
The GLB exports are runtime assets; Blender is only needed to edit/rebuild them.
All geometry and vertex occlusion in this file are original project work.
"""
from pathlib import Path
import hashlib
import json
import math
import random

import bpy
import bmesh
from mathutils import Vector
from mathutils.bvhtree import BVHTree

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "art" / "corner" / "models"
OUT.mkdir(parents=True, exist_ok=True)
MANIFEST = []
PALETTE = {
    "Ceramic": (0.72, 0.70, 0.59), "Stone": (0.58, 0.57, 0.48),
    "Enamel": (0.10, 0.27, 0.27), "Brass": (0.55, 0.36, 0.13),
    "Rubber": (0.055, 0.075, 0.07), "Leaf": (0.22, 0.38, 0.12),
    "Soil": (0.12, 0.16, 0.08), "Bark": (0.22, 0.19, 0.12),
}


def xyz(v):
    return Vector((v[0], -v[2], v[1]))


def material(name):
    mat = bpy.data.materials.get(name)
    if mat is None:
        mat = bpy.data.materials.new(name)
        mat.diffuse_color = (*PALETTE[name], 1)
        mat.use_nodes = True
        shader = mat.node_tree.nodes.get("Principled BSDF")
        shader.inputs["Base Color"].default_value = (*PALETTE[name], 1)
        shader.inputs["Roughness"].default_value = {"Ceramic": 0.36, "Enamel": 0.32, "Brass": 0.38}.get(name, 0.82)
        shader.inputs["Metallic"].default_value = 0.8 if name == "Brass" else 0.0
    return mat


def clear():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)


def finish(obj, name, mat):
    obj.name = name
    obj.data.materials.append(material(mat))
    return obj


def cube(name, at, size, mat="Ceramic", bevel=0.03, segments=3):
    bpy.ops.mesh.primitive_cube_add(size=1, location=xyz(at))
    obj = bpy.context.object
    obj.dimensions = (size[0], size[2], size[1])
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel:
        mod = obj.modifiers.new("Modeled edge profile", "BEVEL")
        mod.width = bevel
        mod.segments = segments
        mod.harden_normals = True
        bpy.ops.object.modifier_apply(modifier=mod.name)
        for face in obj.data.polygons:
            face.use_smooth = True
        mod = obj.modifiers.new("Face-weighted normals", "WEIGHTED_NORMAL")
        mod.keep_sharp = True
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return finish(obj, name, mat)


def mesh(name, vertices, faces, mat, uvs=None, closed=True):
    data = bpy.data.meshes.new(name)
    data.from_pydata([xyz(v) for v in vertices], [], faces)
    data.update()
    obj = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(obj)
    if closed:
        bm = bmesh.new()
        bm.from_mesh(data)
        bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
        if bm.calc_volume(signed=True) < 0:
            bmesh.ops.reverse_faces(bm, faces=list(bm.faces))
        bm.to_mesh(data)
        bm.free()
    if uvs:
        layer = data.uv_layers.new(name="SurfaceUV")
        for loop in data.loops:
            layer.data[loop.index].uv = uvs[loop.vertex_index]
    return finish(obj, name, mat)


def lathe(name, profile, at, mat="Brass", axis="y", sides=32):
    verts, faces = [], []
    for h, r in profile:
        for k in range(sides):
            a = k * math.tau / sides
            p = (math.cos(a) * r, h, math.sin(a) * r)
            if axis == "z":
                p = (p[0], p[2], p[1])
            verts.append(tuple(p[i] + at[i] for i in range(3)))
    for j in range(len(profile) - 1):
        for k in range(sides):
            a, b = j * sides + k, j * sides + (k + 1) % sides
            faces.append((a, b, b + sides, a + sides))
    faces.extend([tuple(reversed(range(sides))), tuple(range((len(profile) - 1) * sides, len(profile) * sides))])
    obj = mesh(name, verts, faces, mat)
    for face in obj.data.polygons:
        face.use_smooth = len(face.vertices) == 4
    return obj


def ring(name, at, radius, tube, mat="Brass", axis="y", sides=36, steps=6):
    verts, faces = [], []
    for i in range(sides):
        a = math.tau * i / sides
        for j in range(steps):
            b = math.tau * j / steps
            p = ((radius + tube * math.cos(b)) * math.cos(a), tube * math.sin(b), (radius + tube * math.cos(b)) * math.sin(a))
            if axis == "z":
                p = (p[0], p[2], p[1])
            verts.append(tuple(p[k] + at[k] for k in range(3)))
    for i in range(sides):
        for j in range(steps):
            faces.append((i * steps + j, ((i + 1) % sides) * steps + j, ((i + 1) % sides) * steps + (j + 1) % steps, i * steps + (j + 1) % steps))
    obj = mesh(name, verts, faces, mat)
    for face in obj.data.polygons:
        face.use_smooth = True
    return obj


def tube(name, points, radius, mat="Rubber", resolution=3):
    data = bpy.data.curves.new(name, "CURVE")
    data.dimensions = "3D"
    data.resolution_u = 6
    data.bevel_depth = radius
    data.bevel_resolution = resolution
    data.use_fill_caps = True
    spline = data.splines.new("BEZIER")
    spline.bezier_points.add(len(points) - 1)
    for bp, point in zip(spline.bezier_points, points):
        bp.co = xyz(point)
        bp.handle_left_type = "AUTO"
        bp.handle_right_type = "AUTO"
    obj = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(material(mat))
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.convert(target="MESH")
    return bpy.context.object


def subtract(obj, cutter):
    bpy.context.view_layer.objects.active = obj
    mod = obj.modifiers.new("Recess", "BOOLEAN")
    mod.operation = "DIFFERENCE"
    mod.solver = "EXACT"
    mod.object = cutter
    bpy.ops.object.modifier_apply(modifier=mod.name)
    bpy.data.objects.remove(cutter, do_unlink=True)


def bake_vertex_occlusion(obj, foliage=False):
    data = obj.data
    if foliage:
        layer = data.color_attributes.new(name="SurfaceData", type="BYTE_COLOR", domain="POINT")
        for v in data.vertices:
            layer.data[v.index].color = (1, min(1, max(0, v.co.z)), 1, 1)
        data.color_attributes.active_color_index = 0
        return
    vertices = [v.co.copy() for v in data.vertices]
    faces = [tuple(p.vertices) for p in data.polygons]
    # Include the supporting ground in the local bake, so a resting object's
    # lower recesses receive consistent occlusion without a painted screenshot.
    n = len(vertices)
    vertices.extend([Vector((-30, -30, -0.015)), Vector((30, -30, -0.015)), Vector((30, 30, -0.015)), Vector((-30, 30, -0.015))])
    faces.extend([(n, n + 1, n + 2), (n, n + 2, n + 3)])
    bvh = BVHTree.FromPolygons(vertices, faces, all_triangles=False)
    layer = data.color_attributes.new(name="SurfaceData", type="BYTE_COLOR", domain="POINT")
    for vertex in data.vertices:
        normal = vertex.normal.normalized()
        if normal.length < 0.1:
            normal = Vector((0, 0, 1))
        basis = normal.to_track_quat("Z", "Y")
        blocked = 0.0
        for i in range(16):
            h = (i + 0.5) / 16
            a = i * 2.3999632297
            r = math.sqrt(1 - h * h)
            direction = basis @ Vector((r * math.cos(a), r * math.sin(a), h))
            hit, _, _, distance = bvh.ray_cast(vertex.co + normal * 0.004, direction, 0.42)
            if hit is not None:
                blocked += 1 - min(distance / 0.42, 1) * 0.35
        ao = max(0.38, 1 - blocked / 16 * 0.7)
        layer.data[vertex.index].color = (ao, ao, ao, 1)
    data.color_attributes.active_color_index = 0


def export(name, foliage=False):
    objects = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.object.join()
    obj = bpy.context.object
    obj.name = name
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    if not obj.data.uv_layers:
        bpy.ops.object.mode_set(mode="EDIT")
        bpy.ops.mesh.select_all(action="SELECT")
        bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.025)
        bpy.ops.object.mode_set(mode="OBJECT")
    bake_vertex_occlusion(obj, foliage)
    out = OUT / f"{name}.glb"
    options = dict(filepath=str(out), export_format="GLB", use_selection=True,
                   export_yup=True, export_apply=True, export_normals=True,
                   export_tangents=False, export_texcoords=True, export_materials="EXPORT",
                   export_animations=False, export_cameras=False, export_lights=False,
                   export_colors=True, export_vertex_color="ACTIVE", export_all_vertex_colors=False)
    available = bpy.ops.export_scene.gltf.get_rna_type().properties.keys()
    bpy.ops.export_scene.gltf(**{k: v for k, v in options.items() if k in available})
    # Small reusable exports stay in ordinary Git. Large editable projects are
    # LFS-managed; fail before silently introducing a large runtime binary.
    if out.stat().st_size > 256 * 1024:
        raise RuntimeError(f"{out.name} exceeds the small-module budget; split the model or configure LFS.")
    obj.data.calc_loop_triangles()
    MANIFEST.append(dict(file=out.name, bytes=out.stat().st_size,
                         triangles=len(obj.data.loop_triangles),
                         sha256=hashlib.sha256(out.read_bytes()).hexdigest()))
    print("EXPORTED", MANIFEST[-1], flush=True)


def paving(index):
    clear()
    rng = random.Random(1300 + index)
    outline = [(-0.58, -0.635), (0.54, -0.635), (0.65, -0.53),
               (0.65, 0.53), (0.56, 0.645), (-0.54, 0.645),
               (-0.65, 0.55), (-0.65, -0.54)]
    outline = [(x + rng.uniform(-0.015, 0.015), z + rng.uniform(-0.012, 0.012)) for x, z in outline]
    verts, faces = [], []
    for inset, height in [(0.00, -0.095), (0.00, -0.018), (0.025, 0.00)]:
        for x, z in outline:
            verts.append((x * (1 - inset), height, z * (1 - inset)))
    for ring_index in range(2):
        for k in range(8):
            a, b = ring_index * 8 + k, ring_index * 8 + (k + 1) % 8
            faces.append((a, b, b + 8, a + 8))
    faces.append(tuple(reversed(range(8))))
    faces.append(tuple(range(16, 24)))
    mesh("Hand-shaped slab", verts, faces, "Stone")
    export(f"paving_{index + 1:02d}")


def wall(damaged=False):
    clear()
    body = cube("Ceramic wall", (0, 0.78, 0), (1.92, 1.56, 0.46), bevel=0.055)
    if damaged:
        cut = cube("Corner loss", (0.95, 1.52, 0.18), (0.40, 0.27, 0.35), bevel=0.035)
        cut.rotation_euler.y = 0.35
        subtract(body, cut)
    cube("Crown stone", (0, 1.60, 0), (2.01, 0.16, 0.57), "Stone", 0.045)
    cube("Footing", (0, 0.10, 0), (1.98, 0.20, 0.54), "Stone", 0.025)
    cube("Recessed face", (0, 0.84, 0.237), (1.62, 1.15, 0.035), "Ceramic", 0.025)
    for x in [-0.86, 0.86]:
        cube("Vertical joint", (x, 0.80, 0.233), (0.022, 1.32, 0.012), "Stone", 0.003, 1)
    cube("Crown separation", (0, 1.485, 0.237), (1.84, 0.018, 0.013), "Stone", 0.003, 1)
    export("wall_worn" if damaged else "wall_panel")


def pillar():
    clear()
    cube("Foot", (0, 0.14, 0), (1.27, 0.28, 1.20), "Stone", 0.09)
    body = cube("Fluted ceramic pier", (0, 1.69, 0), (0.95, 2.98, 0.94), bevel=0.13, segments=4)
    for x in [-0.19, 0.0, 0.19]:
        cut = cube("Service fluting", (x, 1.26, 0.48), (0.060, 0.89, 0.10), bevel=0.024)
        subtract(body, cut)
    cube("Capital gasket", (0, 2.94, 0), (1.01, 0.12, 1.0), "Enamel", 0.035)
    cube("Capital", (0, 3.14, 0), (1.26, 0.24, 1.22), bevel=0.07)
    export("service_pillar")


def dispenser_shell():
    clear()
    cube("Lower casting", (0, 0.12, 0), (1.32, 0.24, 1.04), "Enamel", 0.085, 4)
    shell = cube("Glazed ceramic case", (0, 1.12, 0), (1.23, 1.97, 1.0), bevel=0.15, segments=5)
    cut = cube("Recessed parcel mouth", (0, 0.72, 0.51), (0.70, 0.27, 0.43), "Rubber", 0.035)
    subtract(shell, cut)
    cube("Parcel cavity", (0, 0.72, 0.33), (0.68, 0.25, 0.03), "Rubber", 0.015)
    cube("Teal lid", (0, 2.07, -0.01), (1.28, 0.22, 1.02), "Enamel", 0.10, 4)
    plate = cube("Instrument fascia", (0, 1.42, 0.49), (0.90, 0.84, 0.115), "Enamel", 0.075, 4)
    cut = lathe("Optic recess", [(-0.15, 0.264), (0.15, 0.264)], (0, 1.43, 0.52), "Rubber", axis="z", sides=40)
    subtract(plate, cut)
    cube("Side service cover", (0.619, 1.05, -0.07), (0.024, 1.16, 0.66), "Enamel", 0.01, 2)
    for i in range(4):
        cube("Cooling slot", (0.635, 0.68 + i * 0.105, -0.04), (0.017, 0.038, 0.37), "Rubber", 0.005, 2)
    export("dispenser_shell")


def dispenser_hardware():
    clear()
    lathe("Optic barrel", [(-0.06, 0.264), (0.0, 0.28), (0.035, 0.28)], (0, 1.43, 0.52), "Brass", "z", 40)
    lathe("Recessed optic bed", [(0, 0.234), (0.02, 0.234)], (0, 1.43, 0.555), "Rubber", "z", 40)
    ring("Optic rim", (0, 1.43, 0.578), 0.25, 0.017, axis="z", sides=40)
    cube("Parcel mouth lip", (0, 0.584, 0.55), (0.75, 0.055, 0.23), "Brass", 0.016, 3)
    for x in [-0.505, 0.505]:
        for y in [0.32, 1.80]:
            lathe("Case fastener", [(0, 0.028), (0.012, 0.035), (0.018, 0.029)], (x, y, 0.455), "Brass", "z", 12)
            cube("Screw slot", (x, y, 0.474), (0.025, 0.008, 0.006), "Rubber", 0.002, 1)
    for x in [-0.19, 0.0, 0.19]:
        lathe("Tactile control", [(0, 0.048), (0.026, 0.048), (0.037, 0.037)], (x, 0.36, 0.496), "Brass", "z", 16)
    tube("Carry handle", [(-0.34, 2.17, -0.12), (-0.30, 2.33, -0.12), (0.30, 2.33, -0.12), (0.34, 2.17, -0.12)], 0.027, "Brass", 2)
    for x in [-0.34, 0.34]:
        cube("Handle mount", (x, 2.15, -0.12), (0.10, 0.08, 0.13), "Brass", 0.02, 3)
    export("dispenser_hardware")


def dispenser_vessel():
    clear()
    at = (-0.78, 0, -0.09)
    lathe("Pressure vessel", [(0.43, 0.08), (0.47, 0.145), (0.55, 0.17), (1.42, 0.17), (1.51, 0.12), (1.57, 0.065)], at, "Ceramic", sides=32)
    for y in [0.59, 1.38]:
        ring("Vessel band", (at[0], y, at[2]), 0.171, 0.021, "Brass", sides=32)
        cube("Vessel support", (-0.64, y, -0.09), (0.19, 0.075, 0.18), "Enamel", 0.016)
    lathe("Valve stem", [(1.55, 0.06), (1.64, 0.06), (1.64, 0.10), (1.68, 0.10)], at, "Brass", sides=20)
    ring("Valve wheel", (at[0], 1.71, at[2]), 0.105, 0.019, "Brass", sides=24)
    for i in range(3):
        a = i * math.tau / 3
        tube("Valve spoke", [(at[0], 1.71, at[2]), (at[0] + math.cos(a) * 0.09, 1.71, at[2] + math.sin(a) * 0.09)], 0.009, "Brass", 1)
    tube("Flexible return hose", [(-0.78, 0.45, -0.09), (-0.90, 0.28, 0.03), (-0.78, 0.13, 0.15), (-0.44, 0.18, 0.14)], 0.046, "Rubber", 3)
    for i in range(10):
        y = 0.69 + i * 0.06
        cube("Gauge tick", (-0.78, y, 0.083), (0.065 if i % 2 == 0 else 0.04, 0.012, 0.005), "Enamel", 0.002, 1)
    export("dispenser_vessel")


def leaf_piece(name, start, end, width, mat="Leaf", ridge=0.025):
    start, end = Vector(start), Vector(end)
    span = end - start
    side = span.cross(Vector((0, 1, 0))).normalized()
    if side.length < 0.1:
        side = Vector((1, 0, 0))
    verts, faces, uvs = [], [], []
    steps = 7
    for i in range(steps + 1):
        t = i / steps
        center = start + span * t + Vector((0, math.sin(t * math.pi) * width * 0.45, 0))
        breadth = math.sin(t * math.pi) ** 0.85 * width
        for s in [-1, 0, 1]:
            point = center + side * (breadth * s)
            point.y += ridge * math.sin(t * math.pi) * (1 - abs(s))
            verts.append(tuple(point))
            uvs.append(((s + 1) * 0.5, t))
    for i in range(steps):
        for j in range(2):
            a = i * 3 + j
            faces.append((a, a + 1, a + 4, a + 3))
    obj = mesh(name, verts, faces, mat, uvs=uvs, closed=False)
    for face in obj.data.polygons:
        face.use_smooth = True
    return obj


def plant(fern, variant):
    clear()
    rng = random.Random(400 + variant + (10 if fern else 0))
    count = 7 if fern else 9
    for i in range(count):
        angle = i * 2.39996 + variant * 0.7
        direction = Vector((math.sin(angle), 0, math.cos(angle)))
        length = rng.uniform(0.48, 0.90) if fern else rng.uniform(0.40, 0.78)
        height = rng.uniform(0.25, 0.60)
        if fern:
            points = [tuple(direction * length * t + Vector((0, height * math.sin(t * math.pi * 0.75), 0))) for t in [0, 0.33, 0.66, 1]]
            tube("Frond stem", points, 0.009, "Leaf", 1)
            side = Vector((direction.z, 0, -direction.x))
            for j in range(1, 11):
                t = j / 12
                p = direction * length * t + Vector((0, height * math.sin(t * math.pi * 0.75), 0))
                reach = math.sin(math.pi * t) ** 0.8 * length * 0.23
                for sign in [-1, 1]:
                    tip = p + side * reach * sign + direction * length * 0.13 + Vector((0, -0.018, 0))
                    leaf_piece("Fern leaflet", p, tip, 0.026 + reach * 0.09, ridge=0.01)
            leaf_piece("Frond tip", Vector(points[-2]), Vector(points[-1]), 0.04, ridge=0.01)
        else:
            p = direction * 0.10 + Vector((0, 0.12, 0))
            tip = direction * length + Vector((0, height, 0))
            tube("Leaf stem", [(0, 0.0, 0), tuple(p)], 0.012, "Leaf", 1)
            leaf_piece("Broad leaf", p, tip, length * (0.19 if variant == 0 else 0.25))
    export(("fern" if fern else "broadleaf") + f"_{variant + 1:02d}", foliage=True)


def main():
    for i in range(4):
        paving(i)
    for damaged in [False, True]:
        wall(damaged)
    pillar()
    dispenser_shell()
    dispenser_hardware()
    dispenser_vessel()
    for fern in [True, False]:
        for variant in range(2):
            plant(fern, variant)
    (OUT / "manifest.json").write_text(json.dumps({"generator": "tools/art/build_corner.py", "blender": bpy.app.version_string, "assets": MANIFEST}, indent=2) + "\n")
    print("CORNER MODEL BUILD COMPLETE", flush=True)


if __name__ == "__main__":
    main()
