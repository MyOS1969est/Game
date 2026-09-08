# Dispenser corner — first Blender material study

This implements the first corner of [Visual Target 01](COURTYARD_VISUAL_TARGET.md). It establishes a reusable asset pipeline and closer material detail; it is not a claim of final Moss-level fidelity. The world and traveler remain original AFTERMARKET proposals.

## Included

| Target | Implemented in this pass | Remaining target work |
| --- | --- | --- |
| ENV-01 | Four beveled, irregular paving variants | Dedicated edge kit and refined medallion |
| ENV-02 | Two molded wall panels and a fluted pillar | Authored arch assembly and further selective damage |
| PROP-01 | Ceramic dispenser shell, separate hardware, vessel and hose; existing discovery/focus cues | Art-directed texture painting and further silhouette review |
| VEG-01 | Two fern and two broadleaf meshes with UVs, vertex wind weights, two-sided leaf shading and veins | Further sculpting, authored leaf variation and density tuning |
| MAT-01 | Shared ceramic, stone, enamel and brass shaders; secondary soil, rubber and bark | Painted/baked texture sets for hero surfaces |
| LIGHT-01 | Procedural sky for ambient light and reflections, warm sun, ACES exposure, SSAO settings and vertex AO | Reference-PC review and comparison with Forward+; possible lightmap bake |

Each of the 14 GLBs is under 256 KiB. Repeated scene instances share imported meshes and materials. This does not establish a frame-rate budget on the owner's PC. Existing trees, arch, traveler, gate, patrol and some dressing retain the previous art pass.

## Blender on Windows

Blender is needed for editing or rebuilding assets. The checked-in GLBs let Godot run without launching Blender.

From PowerShell in `C:\dev\Game`, rebuild the original kit with:

```powershell
.\tools\art\build_corner.ps1
```

The helper looks on PATH and in the standard Blender Foundation installation directory. For a portable or differently installed copy:

```powershell
.\tools\art\build_corner.ps1 -Blender "C:\path\to\blender.exe"
```

The reproducible construction source is `tools/art/build_corner.py`. It is tested with Blender **4.5.13 LTS** in [the asset export run](https://github.com/MyOS1969est/Game/actions/runs/34253483464). Other installed versions have not been verified. The Windows helper has been reviewed but has not been executed on Windows here.

To refine a mesh by hand, use Blender's **File > Import > glTF 2.0** and choose a file in `art/corner/models/`. Save your editable `.blend` in `art/corner/source/`. Export the selected asset as GLB with +Y up, normals, UVs and vertex colors preserved. Keep the existing root position, scale and material names. Each component of the dispenser has the same shared origin.

The generator rebuilds all GLBs and will overwrite manual edits to those export paths. Keep your edited `.blend` as the source of truth for a hand-refined asset and re-export it after a kit rebuild. Blender previews use simple assigned colors; final surface detail and animated leaves are Godot shaders.

## Editing in Godot

- `art/corner/materials.gd`: palette, roughness, metallic response, glaze, material grain and wear strength. Changes are shared across the kit.
- `art/corner/surface.gdshader`: procedural color/roughness/bump variation and vertex occlusion. These are generated material signals, not painted 2K texture maps.
- `art/corner/leaf.gdshader`: midrib/vein color, cheap backlighting and tip movement. A custom clock allows normal pause/reset behavior.
- `art/courtyard_art.gd`: wall/paving instances, planting and corner composition.
- `art/dispenser_art.gd`: model assembly and independent discovery indicators.
- `main.tscn`: sky, sun, exposure and normal fixed camera.

AO in vertex color red is baked by the Blender generator using hemisphere rays. Leaf green contains wind weighting. This is local surface occlusion, **not baked global illumination**. Runtime scene assembly is not automatically ready for an editor lightmap bake. The current renderer stays Compatibility.

## Verification

```powershell
python tools/check_project.py --godot "C:\path\to\Godot.exe"
python tools/check_project.py --godot "C:\path\to\Godot.exe" --render --corner-study
```

The second command requires a graphical display. It captures the normal 1280x800 opening view, a separate close art-review view, the inspected machine, 48 real motion frames, and the normal view after both objectives complete. The close camera is a capture tool, not a change to normal gameplay. `--showcase` remains available separately for the previous traveler animation review.

Current local result: import passes and all 33 engine behavior checks pass. The suite covers movement, collisions, inspection, independent knowledge/device condition, altered-arm panel use, route completion, pause, reset and animation. It adds vessel collision and shader-pause checks for this pass. Graphical CI review is pending.

## Provenance and storage

All 14 meshes are original geometry generated for AFTERMARKET by the repository's Blender Python source. No Moss models, textures or animations are included. The concept is a visual reference only. `art/corner/models/manifest.json` records triangle counts, file sizes, Blender version and SHA-256 checksums. The asset workflow pins and verifies the Blender download, then publishes the GLBs as an artifact.

Small runtime GLBs are kept in ordinary Git. The generator rejects files above 256 KiB so that large exports require an explicit LFS decision. `.blend`, `.exr` and `.psd` use Git LFS alongside the repository's existing image/audio/archive rules. Use `git lfs install` before committing large editable assets. Shared source files and `.gdshader` files remain text in Git.
