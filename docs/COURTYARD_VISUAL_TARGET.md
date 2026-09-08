# AFTERMARKET — Service Courtyard: Visual Target 01

September 8, 2026 · Working art proposal and production brief

## Purpose and status

Bring one playable courtyard toward the intended release quality. The current modular art pass establishes layout and interaction; this brief defines the next asset and lighting work. Its companion image, **AFTERMARKET — Service Courtyard — Visual Target 01**, is an AI-generated concept reference. It does not demonstrate Godot rendering, implemented assets, animation quality, or performance.

The source setting is the repository's `Universe Bible.docx`, working version 0.1, especially sections 2, 5, 7, and 12. The approved direction is clean stylized 3D with an elevated camera. Moss is a reference for craftsmanship, material definition, composition, and atmosphere. The traveler, machinery, architecture, and world details here are original proposals. They do not change the Universe Bible or finalize character canon.

## The scene to build

A Bloomed traveler finds a parcel-service courtyard whose machines still perform their duties. Pale ceramic architecture and bone-colored polymers survive beneath ferns, roots, and trees. A warm status light draws attention to a working dispenser. A substantial teal release gate offers a second readable interaction. Distant structures and vegetation suggest the larger Heirlooms beyond this one room.

The room remains sincere and useful. Humor comes from the mismatch between an overgrown ruin and dutiful public-service equipment. Keep wear selective, color masses calm, and paths clear. Avoid visual clutter and uniform surface noise.

| Visual element | Target | Review at gameplay distance |
| --- | --- | --- |
| Traveler | Connected sculpted anatomy, sewn clothing, an expressive face, and a clearly enlarged botanical left arm | The arm and facing direction read immediately; the coat separates from the background |
| Materials | Satin cream ceramic, chalky stone, teal enamel, warm brass, woven cloth, soft leather, thin leaves | Each material responds differently to light without relying on close-up inspection |
| Lighting | Filtered warm sun, cool shaded areas, reflected light, gentle contact shadows, restrained haze | Cream surfaces retain color; the face and interactables stay readable |
| Composition | Intimate elevated view, foreground framing, a clear playable middle distance, layered surroundings | The traveler, dispenser, and release gate form the first three focal points |
| Environment | Varied slabs and edge profiles, foliage grouped around structure, service details that explain function | The scene feels inhabited and grown through; walking routes remain obvious |

Working palette: ivory `#d6cfb0`, stone `#a6a88b`, teal `#396b69`, deep blue-green `#233f43`, brass `#bc9351`, leaf green `#64815a`, and mint `#a8ca83`. Use ochre-orange cloth to distinguish the traveler. Lighting may shift these colors; preserve their relationships.

## Asset list

This table records the **target scope**, not a completion checklist. The first P0 implementation is tracked separately in [the dispenser corner guide](DISPENSER_CORNER.md); remaining entries are planned. Quantities describe reusable source variants; scene instances may be repeated. P0 establishes the first material-and-lighting corner; P1 completes the target view; P2 adds final presentation detail.

| ID / priority | Asset and quantity | Position / purpose | Production route | Required deliverable |
| --- | --- | --- | --- | --- |
| ENV-01 / P0 | Floor kit: 4 slab variants, 2 edge pieces, 1 service medallion | Open central route and courtyard boundary | Original Blender kit | Reusable meshes, consistent scale, texture coordinates, simple collision where needed |
| ENV-02 / P0 | Ceramic structure kit: 2 wall panels, 1 pillar, 1 arch assembly | Divider, route framing, rear boundary | Original Blender kit | Refined edge profiles, selective chips, shared material set, openings matched to gameplay |
| PROP-01 / P0 | Parcel dispenser: 1 hero prop | Left-side discovery focal point | Custom model and texture work | Ceramic case, teal face, amber optic, parcel slot, controls, vessel, hose; separate indicator and focus elements |
| VEG-01 / P0 | Ferns: 2 variants; broadleaf plants: 2 variants | First planted border around the dispenser | Original kit or reviewed compatible licensed source | Leaf texture/opacity, controlled silhouettes, wind weights, restrained translucency |
| MAT-01 / P0 | 4 environment materials: ceramic, stone, enamel, brass | Establish tactile separation across the first corner | Authored texture and material library | Base color, normal, roughness, and metallic data where appropriate; reusable Godot materials |
| LIGHT-01 / P0 | Camera and lighting study: 1 setup | Same normal gameplay view used for comparisons | Godot scene work | Warm key, cool fill/bounce approach, shadow tuning, exposure and value hierarchy |
| CHAR-01 / P1 | Bloomed traveler: 1 character | Lower-left opening position; primary readable silhouette | Custom sculpt/model, texture, rig, and animation; specialist art work recommended | Connected body, hood/face, coat, scarf, boots, pack/bedroll, botanical left arm and usable hand |
| ANIM-01 / P1 | Traveler: idle, walk, inspect, push, settle | Locomotion and both existing interactions | Authored skeletal animation | Five named clips, blending, convincing weight, stable foot contact, hand reaching toward the interacted object |
| PROP-02 / P1 | Release gate: 1 assembly | Back-left route opening | Custom model with simple mechanical animation | Teal ribs, ceramic inserts, brass handle, sliding seam, separate movable panel and status light |
| CHAR-02 / P1 | Maintenance automaton: 1 model and rig | Existing right-side patrol | Original model and mechanical animation | Oval ceramic appliance body, six brass legs, optic, antennae; idle/patrol motion |
| ENV-03 / P1 | Background kit: 2 distant structure silhouettes, 2 root/rock banks | Beyond the walkable courtyard | Reuse ENV-02 shapes plus original dressing | Low-detail depth layers with distinct values; avoid implying new playable exits |
| VEG-02 / P1 | Tree kit: 1 trunk, 3 branch/foliage clusters, 2 ivy strips | Side framing and background canopy | Original kit or reviewed compatible licensed source | Layered foliage, bark material, controllable wind, camera-clear placements |
| MAT-02 / P1 | Character materials: skin/arm, woven cloth, leather | Traveler, pack, boots | Custom texture work | Coherent material response, intentional color variation, readable botanical plates |
| PROP-03 / P2 | Dressing kit: 2 parcels, 1 cabinet, 1 service bollard | Repeated service functions around borders | Reuse existing design language | Modest detail budget and shared materials; keep interaction silhouettes distinct |
| FX-01 / P2 | Ambient set: motes, subtle wind, status-light response | Sunlit pockets and discovered machines | Godot effects/shaders | Low visual noise, visible discovery change, correct pause/reset behavior |
| UI-01 / P2 | Quiet exploration HUD: 1 layout | Screen edges during play | Existing UI refinement | Compact objective state and contextual prompt; readable text without concealing the traveler or route |

## Asset handoff and integration

- Keep editable Blender sources with exports. Use GLB for geometry, material assignments, rigs, and named animation clips. Deliver image textures separately where that makes iteration clearer.
- Use a consistent scale of one Godot unit per meter. Align prop roots and collision footprints with the current scene before replacing visuals. Preserve the 2.4-unit route opening until gameplay deliberately changes it.
- Separate moving parts, indicators, collision, and focus cues. The dispenser's discovery state and the gate's open state must remain independent of general material polish.
- Preserve the player's visual interaction hook `perform_interaction(heavy)` through the new rig or an adapter. Movement, interaction eligibility, knowledge/condition separation, pause, and reset remain governed by the existing gameplay scripts.
- Start with 2K texture sets for focal assets and shared lower-resolution sets for repeated dressing, then measure actual screen coverage and memory use. These are starting budgets, not claims about what the target image requires or what Moss uses.
- If baking light, prepare persistent static scene meshes and appropriate UV2 coordinates. Runtime-generated decoration does not automatically become part of an editor light bake. Keep dynamic actors and moving gate parts separate.
- Record creator, source, license/permission, editable-source location, and modifications for every imported asset. Enable Git LFS and add `.gitattributes` before committing large binary assets, as required by `AGENTS.md`.

Godot references: [3D import workflow](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/index.html), [renderer features and hardware requirements](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html), and [baked lighting setup](https://docs.godotengine.org/en/stable/tutorials/3d/global_illumination/using_lightmap_gi.html).

## Build order and evidence

1. **Material and lighting corner.** Build ENV-01, ENV-02, PROP-01, VEG-01, MAT-01, and LIGHT-01 around the dispenser. Capture it at the normal elevated camera distance. This first proof should visibly improve material separation, depth, and shape quality.
2. **Traveler and interaction.** Add CHAR-01, ANIM-01, and MAT-02. Verify walking, pause, reset, inspection, and the arm reaching toward the gate. Review the figure both close up and at normal gameplay scale.
3. **Complete the courtyard view.** Add the gate, automaton, canopy, and distant surroundings, then restrained dressing, ambient effects, and HUD refinement. Keep the playable floor clear.
4. **Playable visual review.** Deliver actual Godot stills and a 20–30 second gameplay clip showing traversal, inspection, and route opening. Compare with the concept using the five visual criteria above. Run the existing behavior checks and update meaningful assertions for the new rig.

Record the Windows test machine's GPU, driver, resolution, renderer, and measured frame times. Compare Compatibility with Forward+ on supported hardware before choosing the scene's rendering requirements. Baked lighting is a candidate for static geometry; advanced fog is optional. A working performance goal is 1080p at 60 fps on an agreed reference PC, subject to measurement and specification. Neither the concept nor software-rendered CI establishes that result.

## Concept provenance

The companion image is generated with the built-in image-generation tool. The previous actual Godot image `Aftermarket_Diorama.png` supplies only layout and gameplay relationships. The full generation prompt is preserved in [COURTYARD_VISUAL_TARGET_PROMPT.txt](COURTYARD_VISUAL_TARGET_PROMPT.txt). The concept provides art direction; models and textures in the asset list still need to be created or sourced and integrated.

Fidelity reference: [Polyarc's Moss: Book II development showcase](https://www.unrealengine.com/spotlights/how-moss-book-ii-improves-upon-its-predecessor-in-nearly-every-way). Its imagery and assets are references only and are not included in the game.
