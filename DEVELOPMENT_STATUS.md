# Development status

## Milestone 2 — Courtyard diorama art pass

Status: original model kit, character/prop animation, scenery, and field-notebook UI implemented. Thirty gameplay/animation checks pass locally; graphical art review is pending CI.

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
