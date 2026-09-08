# Courtyard repair

The initial scaffold failed Godot 4.7.2 imports: all four original scenes used invalid inline resource syntax. Godot logged the parse failures while the import process returned exit code zero.

This repair uses valid scene resources and Godot 4 project settings; connects each behavior script; aims an orthographic camera at the courtyard; supplies floor, boundary, machine, and panel collision; and implements camera-relative WASD/arrow movement, inspection, one mutation-operated route, pause, and reset.

## Art and scope

The approved art target is clean stylized 3D with a fixed elevated view, cream ceramics, grouped foliage, warm light, and readable mutations. The courtyard uses original reusable primitive geometry and a small material palette. It is an early playable prototype. Character modeling, animation, the invention system, extraction, settlement progression, and persistence are future milestones.

AFTERMARKET, the dispenser interpretation, and the specific room details retain their working/prototype status. The original Universe Bible and other source documents are preserved. This repair does not finalize lore.

## Verification

`tools/check_project.py` checks both process results and error output. The engine smoke test exercises actual input events, physics, inspection state, mutation eligibility, the panel's collision before and after opening, route traversal, pause, reset, and boundary containment.

The optional render test refuses headless mode and captures the Godot viewport through a real rendering display. CI uses Xvfb with Mesa software OpenGL and preserves the screenshot as `courtyard-render`. The render check explicitly selects Godot's Dummy audio driver because CI has no physical sound device; it does not test audio. This establishes that the scene renders on that Linux setup; the Windows editor and graphics driver still need a local play check.

Use a normal Godot project launch for play. `-s` / `--script` is for the dedicated SceneTree test scripts, never for a `.tscn` scene. Headless imports and gameplay tests do not establish graphical output.
