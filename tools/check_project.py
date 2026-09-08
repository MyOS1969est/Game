"""Run Godot checks and fail on engine errors, even when Godot exits with code 0."""
import argparse
import os
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
ANSI = re.compile(r"\x1b\[[0-9;]*m")
ERROR = re.compile(r"^(?:SCRIPT ERROR|ERROR):", re.MULTILINE)


def run(engine, args, expected=None, timeout=90):
    command = [engine, "--path", str(ROOT), *args]
    print("RUN:", subprocess.list2cmdline(command), flush=True)
    try:
        result = subprocess.run(command, cwd=ROOT, text=True, encoding="utf-8",
                                errors="replace", stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, timeout=timeout)
    except subprocess.TimeoutExpired as error:
        captured = error.stdout or b""
        if isinstance(captured, bytes):
            captured = captured.decode("utf-8", errors="replace")
        print(ANSI.sub("", captured), flush=True)
        raise SystemExit(f"Godot check exceeded its {timeout}-second limit; inspect captured output above.") from error
    except OSError as error:
        raise SystemExit(f"Could not complete Godot check: {error}") from error
    output = ANSI.sub("", result.stdout)
    print(output, flush=True)
    if result.returncode or ERROR.search(output):
        raise SystemExit(f"Godot check failed (exit {result.returncode}; inspect output above).")
    if expected and expected not in output:
        raise SystemExit(f"Godot did not report the expected result: {expected}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default=os.environ.get("GODOT_BIN", "godot"))
    parser.add_argument("--render", action="store_true", help="Also capture a real rendered frame; requires a display.")
    parser.add_argument("--showcase", action="store_true", help="With --render, capture detail, completion, and motion frames for art review.")
    parser.add_argument("--corner-study", action="store_true", help="With --render, capture the Blender corner, inspection, and foliage motion.")
    parser.add_argument("--screenshot", type=Path, default=ROOT / "build" / "courtyard.png")
    args = parser.parse_args()
    if args.showcase and not args.render:
        parser.error("--showcase requires --render")
    if args.corner_study and (not args.render or args.showcase):
        parser.error("--corner-study requires --render and cannot be combined with --showcase")
    run(args.godot, ["--headless", "--import"])
    run(args.godot, ["--headless", "--fixed-fps", "60", "--script", "res://tests/smoke_test.gd"], "SMOKE RESULT: PASS")
    if args.render:
        screenshot = args.screenshot.resolve()
        screenshot.parent.mkdir(parents=True, exist_ok=True)
        if screenshot.exists():
            screenshot.unlink()
        # Rendering checks run on CI machines without physical audio devices.
        run(args.godot, ["--audio-driver", "Dummy", "--rendering-method", "gl_compatibility", "--fixed-fps", "60",
                        "--script", "res://tests/render_test.gd", "--", f"--screenshot={screenshot}",
                        *(["--showcase"] if args.showcase else []),
                        *(["--corner-study"] if args.corner_study else [])],
            "RENDER RESULT: PASS", timeout=300 if (args.showcase or args.corner_study) else 90)
        if not screenshot.is_file() or screenshot.stat().st_size < 100:
            raise SystemExit("Godot reported rendering but did not create a screenshot.")
    print("ALL REQUESTED CHECKS PASSED")


if __name__ == "__main__":
    main()
