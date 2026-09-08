# Service courtyard — diorama art pass

This is an original art study for the approved clean, elevated 3D direction. The existing service courtyard becomes an overgrown parcel-service ruin, with rounded ceramic architecture, teal machinery, brass fittings, broad foliage clusters, and a small Bloomed traveler. The Universe Bible's sincere world and dry machine-policy humor guide the details. Character design and room-specific details remain proposals, not new final canon.

## What changed

- A layered stone plinth, gently rounded flagstones, an inlaid parcel-service seal, banded columns, and an arch assembled from individual ceramic sections.
- Fern beds, broad leaves, branching trees, ivy, small flowers, and drifting motes. Movement stays subtle and stops when the game pauses.
- A traveler with boots, hood, face, coat, scarf, salvage pack, bedroll, and a visibly enlarged botanical arm. The visual rig supports idle motion, walking, and a reaching/pushing gesture without moving the collision shape.
- A ceramic scavenger with brass legs, warm optic, and articulated antennae. Its existing patrol behavior is retained.
- A pressure vessel, hose, parcel slot, controls, and indicator on the dispenser. Inspecting it changes its visible question mark to a discovery checkmark. Nearby interactables receive a restrained ground-ring cue.
- A layered sliding panel, release handle, status light, and hazard markings. The same mutation eligibility and passage collision rules apply.
- A compact field-notebook interface with an original vector crest, contextual instructions, objective progress, and a pause screen.

## Editing the art

The models are code-authored meshes built from original reusable geometry, without external art dependencies or raster concept images used as geometry. The `@tool` art scripts preview the models in Godot's 3D editor; animation runs during play. Change model dimensions, placement, and colors in these scripts. Generated child nodes are rebuilt from that source, so persistent changes belong in the scripts rather than the remote runtime scene tree.

| Source | Responsibility |
| --- | --- |
| `art/mesh_kit.gd` | Shared rounded boxes, surface normals, cylinders, rings, leaf geometry, materials, and arch sections |
| `art/courtyard_art.gd` | Environment composition, unchanged structural collision layout, gardens, trees, and ambient motion |
| `art/traveler_rig.gd` | Original traveler model and limb/scarf/interaction animation |
| `art/scavenger_rig.gd` | Original patrol model and leg/antenna animation |
| `art/dispenser_art.gd`, `art/panel_art.gd` | Interactive prop models and visible state changes |
| `ui/courtyard_hud.gd`, `ui/crest.svg` | Field-notebook interface and original crest |

Meshes and materials are shared where possible. The project keeps the Compatibility renderer and adds 4× MSAA. Generated triangle meshes follow [Godot's clockwise front-face convention](https://docs.godotengine.org/en/stable/classes/class_surfacetool.html).

## Verification

The gameplay test now includes 30 checks. In addition to the existing movement, physics, knowledge, route, pause, and reset checks, it verifies walking animation, paused animation, interaction focus, the dispenser's visible discovery state, the arm gesture, and return from that gesture.

`python tools/check_project.py --godot godot --render --showcase` captures the normal courtyard, the traveler at close range, the completed objectives, and a sequence of real Godot motion frames. CI encodes the motion frames as an MP4 and uploads them with the three PNGs in `courtyard-render`. The motion study uses programmatic input and a close-up camera for art inspection; the game retains its fixed elevated camera.

At initial publication, the 30 gameplay checks pass locally. Graphical inspection of this art pass is pending CI. The earlier repair's Windows play test remains a baseline result, not a Windows test of these new models and UI.

## Scope

This is the first detailed modular art pass, not final production character sculpting or animation. It does not add combat, crafting, extraction, settlement progression, persistence, or runtime AI. No audio system or hardware performance benchmark is introduced.
