# AGENTS.md

Agent instructions and project-specific automation notes.

## Execute and orchestrate for Dan

- Dan sets the outcome; agents carry out the technical work. If Codex can do a task, execute it or route it to local Codex instead of giving Dan a manual checklist.
- Read `docs/ORCHESTRATION.md` and `orchestration/tasks.json` at the start of a project session. Inspect actual current state and reuse completed work before creating tasks or installing tools.
- Codex is the primary implementer and local controller. Route independent reviews to Claude Code and research/creative alternatives to Grok Build when their existing subscription access is available. Record the actual provider; never label a Codex sub-agent as Claude or Grok.
- Maintain owned tasks, dependencies, acceptance criteria and evidence. A successful AI invocation or a written plan does not mean the task is done. Verify output and route fixes before reporting success.
- Within existing authorization, perform routine downloads, setup, file organization, scripts, builds and fixes autonomously. Ask Dan only for a genuine access barrier, new spending, or a consequential creative/product decision, with the concrete result already prepared.
- Use existing subscriptions and free approved assets. Do not switch to paid APIs, buy credits, enable overages or weaken permissions as an automatic fallback.
- One agent owns writes in a working directory. Preserve unrelated changes, isolate work when needed, and give reviewers a saved diff and context. Local Codex should execute its own tasks directly rather than recursively launching another Codex.

- This repository is maintained by the project team.
- Use the `docs/` folder for long-form documentation.
- Do not commit large binary assets without enabling Git LFS and adding `.gitattributes`.

## Godot prototype

- This is a Godot 4.7.2 GDScript project. Play with `godot --path .`; `-s` runs a script, not a scene.
- Use valid Godot 4 resource declarations and attach behavior scripts to their scene nodes.
- Run `python tools/check_project.py --godot <editor executable>` after changes to scenes or gameplay. Inspect error output as well as exit codes.
- Use `--render` when a graphical display is available and inspect the screenshot. Report graphical verification as pending when only headless checks can run.
- The approved look is clean stylized 3D with a fixed elevated camera. The next art pass uses authored assets, with Death's Door, DREDGE and For the King as selected references; see `docs/ART_DIRECTION_NEXT.md`. Keep the milestone focused on one playable courtyard corner.
- Keep DEVELOPMENT_STATUS.md accurate about implemented and tested behavior. Preserve original lore documents and working/proposal distinctions.
