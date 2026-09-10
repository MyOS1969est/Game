# Orchestration validation

Date: September 10, 2026.

## Verified in the authoring environment

`python -m unittest discover -s tests -p 'test_orchestration.py' -v` passed **31 tests** on Linux with Python 3.12.14. The suite uses fake local CLI processes and performs no provider inference or network calls.

Covered behavior includes:

- Ready-task selection, dependency ordering, cycle rejection, duplicate IDs and atomic updates.
- Explicit local-controller claims, prevention of overlapping writers, and independent read-only work.
- Actual-provider reporting, a disabled-provider fallback, and a blocked result when no provider is available.
- Codex subscription restriction, API environment rejection, unknown Claude/Console auth rejection, Grok API-key guard and cached-session protocol.
- Rejection of alternate CLI profile/settings arguments that could select an uninspected authentication route.
- Schema validation, failed workers, timeout cleanup including a child process, explicit retries and lock recovery.
- Evidence existence/confinement and completion records that still load after local worker caches are removed.
- Expected read-only review command flags and preservation of an unrelated local file.

The tracked queue validates successfully. It contains five scoped tasks: the reference brief is already satisfied by `ART_DIRECTION_NEXT.md`; toolchain discovery and asset acquisition are ready; corner implementation and review depend on the required prior work. The CLI help and capability report also run successfully.

## What these results do not establish

The Codex, Claude and Grok CLI executables are not available to this dispatcher in the cloud authoring environment. No live subscriber session, model execution, Windows installation, local GPU performance or asset download was claimed. The normal local Codex controller can carry out implementation itself even if a standalone Codex CLI is absent.

Provider commands and authentication behavior were checked against the official sources listed in `ORCHESTRATION.md`. Unsupported installed versions or authentication layouts are blockers with explicit fallback behavior, not assumed successes.

## CI and local activation

`.github/workflows/orchestration-checks.yml` runs the same suite and validates the queue on Windows and Linux with Python 3.11. Consult the actual GitHub run for platform results. Existing Godot CI continues separately; this change does not modify scenes or gameplay.

On Dan's PC, local Codex should integrate this layer while preserving current work, run the capability check, claim ready tasks, verify real Blender/Godot and subscriber behavior, and record that evidence. The layer is a finite dispatcher and project operating agreement; it is not a deployed unattended Windows service or a remote-control connection from this chat.
