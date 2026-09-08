# Courtyard repair

The initial scaffold failed Godot 4.7.2 imports: all four original scenes used invalid inline resource syntax. Godot logged the parse failures while the import process returned exit code zero.

This repair uses valid scene resources and Godot 4 project settings; connects each behavior script; aims an orthographic camera at the courtyard; supplies floor, boundary, machine, and panel collision; and implements camera-relative WASD/arrow movement, inspection, one mutation-operated route, pause, and reset.

## Art and scope

The approved art target is clean stylized 3D with a fixed elevated view, cream ceramics, grouped foliage, warm light, and readable mutations. The courtyard uses original reusable primitive geometry and a small material palette. It is an early playable prototype. Character modeling, animation, the invention system, extraction, settlement progression, and persistence are future milestones.

AFTERMARKET, the dispenser interpretation, and the specific room details retain their working/prototype status. The original Universe Bible and other source documents are preserved. This repair does not finalize lore.

## Verification

`tools/check_project.py` checks both process results and error output. The engine smoke test exercises actual input events, physics, inspection state, mutation eligibility, the panel's collision before and after opening, route traversal, pause, reset, and boundary containment.

The optional render test refuses headless mode and captures the Godot viewport through a real rendering display. CI uses Xvfb with Mesa software OpenGL and preserves the screenshot as `courtyard-render`. The render check explicitly selects Godot's Dummy audio driver because CI has no physical sound device; it does not test audio. This establishes that the scene renders on that Linux setup.

On September 8, 2026, [CI run 34238166864](https://github.com/MyOS1969est/Game/actions/runs/34238166864) passed import, all 24 gameplay assertions, and a real 1280×800 render at commit `7333316b04deec173bb19be057b14515a37e3e6c`. The downloaded artifact's SHA-256 matched GitHub's digest. Visual inspection confirmed that the courtyard and HUD fit the frame, world labels are readable, and the adjusted lighting preserves the cream/teal palette. This is graphical proof of the prototype, not a claim of finished production art or a native Windows play test.

Use a normal Godot project launch for play. `-s` / `--script` is for the dedicated SceneTree test scripts, never for a `.tscn` scene. Headless imports and gameplay tests do not establish graphical output.

The owner subsequently supplied a screenshot on September 8, 2026 showing the repaired scene running in a Windows Godot debug window. Visual review confirmed the courtyard, elevated camera, actors, scenery, lighting, world labels, and HUD render locally. This closes the Windows rendering check.

After completing the requested local play checklist, the owner confirmed that movement, dispenser inspection and notebook update, panel opening, side-route completion, pause/resume, and reset all work on Windows. This completes the courtyard repair's local interaction verification. The checklist did not include performance benchmarking or audio testing.
