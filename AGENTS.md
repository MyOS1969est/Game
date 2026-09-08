# AGENTS.md

Agent instructions and project-specific automation notes.

- This repository is maintained by the project team.
- Use the `docs/` folder for long-form documentation.
- Do not commit large binary assets without enabling Git LFS and adding `.gitattributes`.

## Godot prototype

- This is a Godot 4.7.2 GDScript project. Play with `godot --path .`; `-s` runs a script, not a scene.
- Use valid Godot 4 resource declarations and attach behavior scripts to their scene nodes.
- Run `python tools/check_project.py --godot <editor executable>` after changes to scenes or gameplay. Inspect error output as well as exit codes.
- Use `--render` when a graphical display is available and inspect the screenshot. Report graphical verification as pending when only headless checks can run.
- The approved look is clean stylized 3D with a fixed elevated camera. Keep primitive art modular and the current milestone focused on a playable courtyard.
- Keep DEVELOPMENT_STATUS.md accurate about implemented and tested behavior. Preserve original lore documents and working/proposal distinctions.
