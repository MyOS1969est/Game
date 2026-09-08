# Development status

## Milestone 1 — Service courtyard repair

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
- All 24 engine gameplay checks passed locally.
- Rendered-frame verification is pending: this workspace disallows graphical display sockets. The GitHub workflow is ready to run after the repair branch is published with owner authorization.
- Windows hardware and the owner's local editor session require a local play check.

Next:
- Review the playable camera, controls, and route with the owner.
- Develop a consistent original model/animation kit toward the approved clean diorama art.
- Begin the small expedition/extraction/settlement milestone after play feedback.

Prototype boundaries:
- This is an early playable scene with simple geometry, not final art.
- Patrol combat, invention composition, extraction, settlement progression, and saving are not implemented.
- World and visual source documents are preserved; proposed content is not promoted to final canon.
