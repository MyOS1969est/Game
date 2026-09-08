# AFTERMARKET — Service Courtyard

A small Godot 4.7.2 prototype with a fixed elevated 3D camera, a mutated scavenger, an inspectable heirloom, a moving patrol, and a mutation-operated side route.

## Play in Godot

1. Install the **standard Godot 4.7.2 editor** (the project uses GDScript).
2. Import this folder's `project.godot` in Godot.
3. Press **F5 / Run Project**. The courtyard's decorative props and HUD are created when the scene runs.
4. Walk to the machine marked **STILL USEFUL** and press **E**. Then approach the teal panel, press **E**, and walk through to **SIDE ROUTE**.

Export templates are not required to play in the editor. The project uses Compatibility rendering to keep this prototype usable on a broad range of desktop hardware.

| Input | Action |
| --- | --- |
| WASD or arrow keys | Move relative to the camera |
| E | Inspect a nearby heirloom or use the altered arm on the panel |
| Escape | Pause / resume |
| R | Reset the courtyard, including from pause |

The patrol is a moving, non-hostile placeholder. Discovery and route state reset with the scene; saving, extraction, crafting, and settlement progression are later milestones.

## Run from a terminal

From the project folder, with Godot on PATH:

```shell
godot --path .
```

On Windows, when Godot is not on PATH, pass your actual executable path:

```powershell
.\tools\run_godot.ps1 -GodotPath "C:\Tools\Godot\Godot_v4.7.2-stable_win64.exe"
```

The example path is a placeholder for your installation. Add `-Editor` to open the editor. The VS Code tasks **Play courtyard** and **Open Godot editor** use the `godot` command on PATH.

A `.tscn` scene is not a script: do not launch it with `-s`. To test a specific scene, use `godot --path . main.tscn`.

## Verify changes

With Python 3 and Godot installed:

```shell
python tools/check_project.py --godot godot
python tools/check_project.py --godot godot --render
```

The first command imports resources and runs the engine gameplay tests. It fails on Godot error output even if the process returns zero. The second also captures a rendered frame at `build/courtyard.png` and requires a graphical display.

GitHub Actions runs both checks with software OpenGL and uploads `courtyard-render`. Headless checks establish loading and gameplay behavior; they cannot establish graphical output.

See [development status](DEVELOPMENT_STATUS.md) and [repair details](docs/COURTYARD_REPAIR.md).
