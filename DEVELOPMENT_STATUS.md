# Development status

## Engineering — AI orchestration

Status: a local task dispatcher, persistent operating agreement, provider routing, evidence records and a five-task art queue are implemented. All 31 fake-provider tests pass in the Linux authoring environment. A dedicated workflow runs the same suite on Windows and Linux; actual CI results should be checked on the published branch.

Codex owns implementation; Claude Code provides independent reviews and Grok Build supports bounded research when existing subscription access is verified. The reference brief is already complete and will be reused. Routine technical work belongs to the agents; Dan supplies creative decisions and genuinely required account/OS interaction. Local Windows enrollment and real subscriber CLI execution remain unverified until the local controller runs them.

See [the operating agreement](docs/ORCHESTRATION.md), [validation scope](docs/ORCHESTRATION_VALIDATION.md), and [the task queue](orchestration/tasks.json).

## Milestone 3 — Blender dispenser corner

Status: 14 original Blender GLB modules have been exported and integrated with reusable Godot surface and foliage shaders. Godot 4.7.2 imports the kit and passes all 33 gameplay checks locally and in [CI run 34256378074](https://github.com/MyOS1969est/Game/actions/runs/34256378074), testing runtime commit `17c1b360dbf20221e9e1e72c5a2e91db894333f2`. Four actual 1280x800 captures and a sampled inspection-motion frame were visually reviewed after correcting excess brightness, a disconnected branch and close-view occlusion. The 48-frame, 2.4-second clip is an inspection/foliage study.

The first corner adds beveled wall panels and a fluted pillar, four irregular paving variants, a three-part dispenser with recessed hardware and hose, four modeled plant variants, baked vertex occlusion, procedural material detail, sky lighting/reflections, and contact-shadow settings. The normal fixed gameplay camera and both objectives remain the baseline. Windows hardware performance and local Blender rebuild still require owner review.

See [the corner editing and verification guide](docs/DISPENSER_CORNER.md) and [Visual Target 01](docs/COURTYARD_VISUAL_TARGET.md). This is a first material-and-shape proof. The sculpted traveler, skeletal animation, full tree kit, painted texture sets, lightmap baking, and remaining courtyard assets are later work.

## Milestone 2 — Courtyard diorama art pass

Status: original model kit, character/prop animation, scenery, and field-notebook UI implemented and verified in Godot 4.7.2 on Linux. All 31 gameplay/animation checks pass locally and in [CI run 34245560506](https://github.com/MyOS1969est/Game/actions/runs/34245560506). Three actual 1280×800 game captures and sampled motion frames were visually inspected, including the corrected forward push gesture. The new art build is ready for the owner's Windows play review.

The art pass adds rounded ceramic ruins, an inlaid service seal, planted borders and trees, a detailed Bloomed traveler with walking and interaction animation, an articulated ceramic scavenger, refined interactive machines, and contextual focus cues. Models preview in the Godot editor through `@tool` scripts. The existing courtyard objectives and collision layout remain the gameplay baseline.

See [art pass details and editing guide](docs/DIORAMA_ART_PASS.md). The character is an original art study; production art, expanded gameplay, audio, and performance benchmarking remain later work.

## Milestone 1 — Service courtyard repair

Status: verified by automated checks and the owner's Windows play test on September 8, 2026.

Implemented:
- Valid Godot 4 project and scene resources.
- Fixed elevated orthographic camera aimed at the courtyard.
- Connected player, patrol, heirloom, and panel scripts.
- Camera-relative WASD and arrow movement; normalized diagonal speed.
- Floor, perimeter, divider, machine, and closed-panel collision.
- A visibly enlarged arm and one mutation-operated passage.
- Nearby E interaction, separate artifact condition/knowledge, notebook feedback.
- Side-route objective and completion feedback.
- Pause/resume and reset, including reset while paused.
- Original modular placeholder scenery using the approved cream/teal/green palette.
- Accurate terminal commands, a Windows launcher, and VS Code tasks.
- Engine behavior tests and CI import/gameplay/render checks.

Verification:
- Godot 4.7.2 official Linux editor imported the repaired project without errors.
- All 24 engine gameplay checks passed locally and in GitHub Actions.
- Godot 4.7.2 rendered a real 1280×800 frame under Xvfb/Mesa software OpenGL in [CI run 34238166864](https://github.com/MyOS1969est/Game/actions/runs/34238166864). The screenshot was downloaded, its archive checksum verified, and the image visually inspected.
- The rendered review confirmed courtyard framing, visible actors and scenery, readable HUD text, and corrected lighting/world-label sizing. The `courtyard-render` artifact is attached to the run.
- Rendering checks use Dummy audio and do not verify sound. This workspace still disallows local graphical display sockets; rendering was verified on the Linux CI runner.
- The owner's September 8, 2026 screenshot confirms the repaired courtyard renders in a local Windows Godot debug session. The elevated camera, actors, scenery, lighting, world labels, and HUD are visible.
- After the screenshot review, the owner confirmed the Windows play checklist: movement, dispenser inspection and notebook update, panel opening, side-route completion, pause/resume, and reset all work. This completes the courtyard repair's local play check; performance benchmarking and audio were outside that checklist.

Next:
- Develop a consistent original model/animation kit toward the approved clean diorama art.
- Begin the small expedition/extraction/settlement milestone after play feedback.

Prototype boundaries:
- This is an early playable scene with simple geometry, not final art.
- Patrol combat, invention composition, extraction, settlement progression, and saving are not implemented.
- World and visual source documents are preserved; proposed content is not promoted to final canon.
