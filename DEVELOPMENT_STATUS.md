# Development status

Milestone 1 — Playable Courtyard (in progress)

- Implemented: minimal 3D playable scaffold, `Player` with movement and facing, elevated `Camera3D`, HUD label.
- Implemented: `Scavenger` patrol placeholder (scripted back-and-forth)
- Implemented: `Heirloom` inspectable placeholder (Area3D already present)
- Implemented: soft lighting and fog via `WorldEnvironment`
- Implemented: `README` quick-start and VS Code tasks for running Godot

Next (recommended):

- Add simple scavenger mutation visuals and inspect interaction feedback (UI prompt + sound)
- Polish camera framing and animation for readability
- Replace placeholder geometry with authored art from the Codex package
- Add CI or launcher tasks to build/export prototypes

Notes:

- Run the project in Godot 4.7.2. From the project root:

```
godot --path . -e
```

Or use the VS Code tasks: `Run Task` → `Play main scene`.
