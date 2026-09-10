"""Exercise queue integrity and real subprocess lifecycle with fake AI CLIs.

No provider account, model request, paid API, engine installation, or network is
used. These tests are intended to run on both Windows and Linux.
"""
from __future__ import annotations

import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import socket
import subprocess
import sys
import tempfile
import time
import unittest
from unittest import mock


REPO = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("aftermarket_orchestrate", REPO / "tools/orchestrate.py")
assert SPEC and SPEC.loader
orch = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(orch)

FAKE_CLI = r'''
import json, os, pathlib, subprocess, sys, time
provider = sys.argv[1]
args = sys.argv[2:]
root = pathlib.Path.cwd()
if "--version" in args or args == ["version"]:
    print("fake-" + provider + " 1.0")
    sys.exit(0)
if args == ["login", "status"]:
    print("Logged in using ChatGPT")
    sys.exit(0)
if args == ["auth", "status"]:
    print(json.dumps({"loggedIn": True, "authMethod": "claude.ai", "subscriptionType": "max"}))
    sys.exit(0)
if args == ["inspect", "--json"]:
    print(json.dumps({"config": {"grok_com_config": {"disable_api_key_auth": True}}}))
    sys.exit(0)
if args == ["--help"]:
    print("--sandbox --permission-mode --deny --allow --no-subagents --no-plan --max-turns")
    sys.exit(0)
if args == ["agent", "stdio"]:
    for line in sys.stdin:
        request = json.loads(line)
        result = {"authMethods": [{"id": "cached_token"}]} if request["method"] == "initialize" else {}
        print(json.dumps({"jsonrpc": "2.0", "id": request["id"], "result": result}), flush=True)
    sys.exit(0)
(root / ".orchestration").mkdir(exist_ok=True)
(root / ".orchestration" / "mock-argv.json").write_text(json.dumps(args))
mode = (root / "mock-mode.txt").read_text().strip() if (root / "mock-mode.txt").exists() else "success"
if mode == "fail":
    print("Simulated provider failure", file=sys.stderr)
    sys.exit(7)
if mode == "timeout":
    subprocess.Popen([sys.executable, "-c",
        "import pathlib,time; time.sleep(3); pathlib.Path('orphan-marker.txt').write_text('orphan')"])
    time.sleep(20)
if mode == "invalid":
    result = {"summary": "Missing mandatory result fields"}
else:
    result = {"summary": "Mock task result; no real AI was called.",
              "evidence": [], "checks": [{"criterion": "Mock acceptance",
                  "status": "not_checked", "evidence": []}],
              "blockers": [], "next_steps": ["Controller must verify real output."]}
if provider == "codex":
    pathlib.Path(args[args.index("-o") + 1]).write_text(json.dumps(result))
    print(json.dumps({"type": "mock.finished"}))
elif provider == "claude":
    print(json.dumps({"structured_output": result, "is_error": False}))
else:
    print(json.dumps({"result": json.dumps(result)}))
'''


class OrchestrationTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="aftermarket orchestration ")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        (self.root / "orchestration").mkdir()
        (self.root / "docs/evidence").mkdir(parents=True)
        (self.root / "AGENTS.md").write_text("Preserve existing work. Use subscription access.")
        (self.root / "notes.txt").write_text("Unrelated local work must survive.\n")
        self.fake = self.root / "fake worker.py"
        self.fake.write_text(FAKE_CLI)
        self.config = json.loads((REPO / "orchestration/config.json").read_text())
        for provider in self.config["providers"]:
            self.config["providers"][provider] = {
                "executable": sys.executable,
                "args": [str(self.fake), provider],
                "enabled": True,
            }
        self.tasks = [
            self.task("T-001"),
            self.task("T-002", dependencies=["T-001"]),
        ]
        self.write_fixture()
        # Keep real account-related values out of the fake-provider tests.
        self.environment = os.environ.copy()
        for names in orch.API_ENV.values():
            for name in names:
                self.environment.pop(name, None)

    @staticmethod
    def task(task_id, dependencies=None, provider="codex", kind="setup", fallback=None):
        return {
            "id": task_id, "title": "A bounded task", "kind": kind,
            "preferred_provider": provider, "fallback_provider": fallback,
            "depends_on": dependencies or [], "instructions": "Perform the task and supply evidence.",
            "acceptance_criteria": ["A real result is checked."],
            "status": "queued", "evidence": [],
        }

    def write_fixture(self):
        (self.root / "orchestration/config.json").write_text(json.dumps(self.config))
        (self.root / "orchestration/tasks.json").write_text(json.dumps({"schema_version": 1, "tasks": self.tasks}))

    def queue(self):
        return json.loads((self.root / "orchestration/tasks.json").read_text())["tasks"]

    def cli(self, *arguments, expected=0, environment=None, timeout=20):
        process = subprocess.run(
            [sys.executable, str(REPO / "tools/orchestrate.py"), "--root", str(self.root), *arguments],
            cwd=self.root, env=environment or self.environment, text=True,
            encoding="utf-8", capture_output=True, timeout=timeout,
        )
        self.assertEqual(process.returncode, expected, process.stdout + process.stderr)
        return process

    def proof(self):
        path = self.root / "docs/evidence/proof.md"
        path.write_text("Test fixture evidence; not an actual provider result.")
        return "docs/evidence/proof.md"

    def test_ready_task_respects_dependencies(self):
        result = json.loads(self.cli("next", "--json").stdout)
        self.assertEqual(result["next"]["id"], "T-001")
        self.assertEqual(result["ready_count"], 1)
        status = json.loads(self.cli("status", "--json").stdout)["tasks"]
        self.assertTrue(status[0]["ready"])
        self.assertFalse(status[1]["ready"])

    def test_record_done_unlocks_dependent_task(self):
        self.cli("record", "T-001", "--status", "done", "--summary", "Verified", "--evidence", self.proof())
        result = json.loads(self.cli("next", "--json").stdout)
        self.assertEqual(result["next"]["id"], "T-002")

    def test_done_requires_evidence_and_does_not_mutate_on_error(self):
        before = (self.root / "orchestration/tasks.json").read_bytes()
        self.cli("record", "T-001", "--status", "done", "--summary", "Unproven", expected=2)
        self.assertEqual(before, (self.root / "orchestration/tasks.json").read_bytes())

    def test_cannot_complete_before_dependencies(self):
        self.cli("record", "T-002", "--status", "done", "--summary", "Too early", "--evidence", self.proof(), expected=2)
        self.assertEqual(self.queue()[1]["status"], "queued")

    def test_cannot_run_before_dependencies(self):
        self.cli("run", "T-002", expected=2)
        self.assertFalse((self.root / ".orchestration/mock-argv.json").exists())

    def test_missing_and_outside_evidence_are_rejected(self):
        for path in ["docs/evidence/missing.md", "../outside.txt", "C:\\outside.txt", "/outside.txt", "docs"]:
            with self.subTest(path=path):
                self.cli("record", "T-001", "--status", "done", "--summary", "No", "--evidence", path, expected=2)
        self.assertEqual(self.queue()[0]["status"], "queued")

    def test_dependency_cycles_and_unknown_ids_are_rejected(self):
        self.tasks[0]["depends_on"] = ["T-002"]
        self.write_fixture()
        self.cli("status", expected=2)
        self.tasks[0]["depends_on"] = ["UNKNOWN"]
        self.write_fixture()
        self.cli("status", expected=2)

    def test_duplicate_add_is_atomic(self):
        before = (self.root / "orchestration/tasks.json").read_bytes()
        self.cli("add", "--id", "T-001", "--title", "Duplicate", "--kind", "setup",
                 "--instructions", "Do work", "--acceptance", "Evidence exists", expected=2)
        self.assertEqual(before, (self.root / "orchestration/tasks.json").read_bytes())

    def test_add_routes_review_to_claude(self):
        added = json.loads(self.cli("add", "--id", "T-003", "--title", "Review",
                                   "--kind", "review", "--instructions", "Review the diff",
                                   "--acceptance", "Findings cite files").stdout)
        self.assertEqual(added["preferred_provider"], "claude")
        self.assertEqual(added["status"], "queued")

    def test_unknown_task_kind_and_paid_api_configuration_are_rejected(self):
        self.tasks[0]["kind"] = "invented"
        self.write_fixture()
        self.cli("status", expected=2)
        self.tasks[0]["kind"] = "setup"
        self.config["allow_paid_api"] = True
        self.write_fixture()
        self.cli("status", expected=2)

    def test_live_lock_prevents_concurrent_mutation(self):
        with orch.QueueLock(self.root):
            self.cli("record", "T-001", "--status", "blocked", "--summary", "Concurrent", expected=2)
        self.assertEqual(self.queue()[0]["status"], "queued")

    def test_dead_local_lock_recovers(self):
        lock = self.root / ".orchestration/queue.lock"
        lock.parent.mkdir()
        lock.write_text(json.dumps({"pid": -1, "host": socket.gethostname(), "token": "dead"}))
        self.cli("record", "T-001", "--status", "blocked", "--summary", "Recorded")
        self.assertEqual(self.queue()[0]["status"], "blocked")
        self.assertFalse(lock.exists())

    def test_success_is_review_not_done(self):
        run = json.loads(self.cli("run", "T-001", "--json").stdout)
        self.assertEqual(run["status"], "review")
        self.assertEqual(run["actual_provider"], "codex")
        self.assertEqual(self.queue()[0]["status"], "review")
        self.assertEqual((self.root / "notes.txt").read_text(), "Unrelated local work must survive.\n")
        self.assertFalse((self.root / ".orchestration/queue.lock").exists())

    def test_codex_forces_subscription_and_correct_sandbox(self):
        self.cli("run", "T-001")
        command = json.loads((self.root / ".orchestration/mock-argv.json").read_text())
        self.assertIn('forced_login_method="chatgpt"', command)
        self.assertEqual(command[command.index("--sandbox") + 1], "workspace-write")
        self.assertNotIn("--dangerously-bypass-approvals-and-sandbox", command)

    def test_unavailable_secondary_provider_falls_back_honestly(self):
        self.tasks[0] = self.task("T-001", provider="claude", kind="review", fallback="codex")
        self.config["providers"]["claude"]["enabled"] = False
        self.write_fixture()
        result = json.loads(self.cli("run", "T-001").stdout)
        self.assertEqual(result["requested_provider"], "claude")
        self.assertEqual(result["actual_provider"], "codex")
        self.assertEqual(result["status"], "review")
        args = json.loads((self.root / ".orchestration/mock-argv.json").read_text())
        self.assertEqual(args[args.index("--sandbox") + 1], "read-only")

    def test_missing_all_providers_records_block_without_launch(self):
        for provider in self.config["providers"].values():
            provider["enabled"] = False
        self.write_fixture()
        result = json.loads(self.cli("run", "T-001", expected=1).stdout)
        self.assertIsNone(result["actual_provider"])
        self.assertEqual(result["status"], "blocked")
        self.assertFalse((self.root / ".orchestration/mock-argv.json").exists())

    def test_api_environment_blocks_dispatch_without_leaking_value(self):
        environment = dict(self.environment, OPENAI_API_KEY="synthetic-secret-never-log-this")
        process = self.cli("run", "T-001", environment=environment, expected=1)
        self.assertIn("OPENAI_API_KEY", process.stdout)
        self.assertNotIn(environment["OPENAI_API_KEY"], process.stdout + process.stderr)
        self.assertFalse((self.root / ".orchestration/mock-argv.json").exists())

    def test_failed_and_malformed_workers_never_complete(self):
        for mode in ["fail", "invalid"]:
            with self.subTest(mode=mode):
                self.tasks[0]["status"] = "queued"
                self.write_fixture()
                (self.root / "mock-mode.txt").write_text(mode)
                result = json.loads(self.cli("run", "T-001", expected=1).stdout)
                self.assertEqual(result["status"], "failed")
                self.assertFalse((self.root / ".orchestration/queue.lock").exists())

    def test_timeout_terminates_descendants_and_records_failure(self):
        (self.root / "mock-mode.txt").write_text("timeout")
        result = json.loads(self.cli("run", "T-001", "--timeout", "1", expected=1).stdout)
        self.assertEqual(result["status"], "failed")
        time.sleep(3.2)
        self.assertFalse((self.root / "orphan-marker.txt").exists(), "A worker descendant survived timeout")
        self.assertFalse((self.root / ".orchestration/queue.lock").exists())

    def test_retry_requires_explicit_state_change(self):
        self.cli("run", "T-001")
        self.cli("run", "T-001", expected=2)
        self.cli("record", "T-001", "--status", "queued", "--summary", "Controller requested a retry")
        self.cli("run", "T-001")

    def test_completion_survives_removal_of_local_worker_cache(self):
        self.cli("run", "T-001")
        self.cli("record", "T-001", "--status", "done", "--summary", "Controller reviewed", "--evidence", self.proof())
        import shutil
        shutil.rmtree(self.root / ".orchestration")
        self.cli("status", "--json")
        self.assertEqual(self.queue()[0]["status"], "done")

    def test_claude_command_restricts_tools_without_bypass(self):
        path = self.root / ".orchestration/runs/mock"
        path.mkdir(parents=True)
        command, prompt = orch.provider_command("claude", self.config, path, "Review", False)
        self.assertEqual(command[command.index("--tools") + 1], "Read,Glob,Grep")
        self.assertIn("mcp__*", command)
        self.assertNotIn("--dangerously-skip-permissions", command)
        self.assertEqual(prompt, "Review")
        with self.assertRaises(orch.OrchestrationError):
            orch.provider_command("claude", self.config, path, "Write", True)

    def test_grok_probe_and_mock_dispatch_use_cached_auth(self):
        self.tasks[0] = self.task("T-001", provider="grok", kind="research")
        self.write_fixture()
        result = json.loads(self.cli("run", "T-001").stdout)
        self.assertEqual(result["actual_provider"], "grok")
        self.assertEqual(result["status"], "review")
        args = json.loads((self.root / ".orchestration/mock-argv.json").read_text())
        self.assertEqual(args[args.index("--sandbox") + 1], "read-only")
        self.assertIn("--no-subagents", args)

    def test_claude_subscriber_probe_and_mock_dispatch(self):
        self.tasks[0] = self.task("T-001", provider="claude", kind="review")
        self.write_fixture()
        # Isolate the logic from any developer-specific settings on the host.
        output, errors = io.StringIO(), io.StringIO()
        with mock.patch.dict(os.environ, self.environment, clear=True), \
             mock.patch.object(orch, "claude_settings_issues", return_value=[]), \
             contextlib.redirect_stdout(output), contextlib.redirect_stderr(errors):
            code = orch.main(["--root", str(self.root), "run", "T-001", "--json"])
        self.assertEqual(code, 0, output.getvalue() + errors.getvalue())
        self.assertEqual(json.loads(output.getvalue())["actual_provider"], "claude")

    def test_brief_contains_scope_acceptance_and_no_recursion(self):
        brief = self.cli("brief", "T-001").stdout
        self.assertIn("Do not launch this orchestration runner recursively", brief)
        self.assertIn("A real result is checked.", brief)
        self.assertIn("Preserve existing work", brief)

    def test_interactive_claim_prevents_second_writer_until_released(self):
        self.tasks.append(self.task("T-003"))
        self.write_fixture()
        claimed = json.loads(self.cli("claim", "T-001", "--owner", "local-codex", "--json").stdout)
        self.assertEqual(claimed["status"], "running")
        self.assertEqual(claimed["owner"], "local-codex")
        self.cli("claim", "T-003", expected=2)
        self.cli("run", "T-003", expected=2)
        self.cli("record", "T-001", "--status", "done", "--summary", "Verified", "--evidence", self.proof())
        self.cli("claim", "T-003", "--json")
        self.assertEqual(self.queue()[2]["status"], "running")

    def test_interactive_claim_requires_ready_dependencies(self):
        self.cli("claim", "T-002", expected=2)
        self.assertEqual(self.queue()[1]["status"], "queued")

    def test_independent_read_only_research_can_run_during_writer_claim(self):
        self.tasks.append(self.task("T-003", kind="research"))
        self.write_fixture()
        self.cli("claim", "T-001")
        self.cli("run", "T-003")
        self.assertEqual(self.queue()[0]["status"], "running")
        self.assertEqual(self.queue()[2]["status"], "review")

    def test_unknown_claude_auth_and_console_oauth_are_blocked(self):
        examples = [
            {},
            {"loggedIn": True, "authMethod": "api_key"},
            {"loggedIn": True, "authMethod": "oauth", "subscriptionType": "console"},
        ]
        for auth in examples:
            with self.subTest(auth=auth), \
                 mock.patch.dict(os.environ, self.environment, clear=True), \
                 mock.patch.object(orch, "claude_settings_issues", return_value=[]), \
                 mock.patch.object(orch, "capture", side_effect=[(0, "mock 1.0", ""), (0, json.dumps(auth), "")]):
                result = orch.check_provider(self.root, "claude", self.config)
                self.assertFalse(result["ready"])
                self.assertTrue(result["issues"])

    def test_grok_requires_api_key_disabled_guard_before_auth_probe(self):
        with mock.patch.dict(os.environ, self.environment, clear=True), \
             mock.patch.object(orch, "capture", side_effect=[(0, "mock 1.0", ""), (0, '{"config":{}}', "")]), \
             mock.patch.object(orch, "grok_cached_token_probe") as probe:
            result = orch.check_provider(self.root, "grok", self.config)
        self.assertFalse(result["ready"])
        probe.assert_not_called()

    def test_launcher_arguments_cannot_select_uninspected_auth_profiles(self):
        for flag in ["--profile", "--settings", "-c"]:
            with self.subTest(flag=flag):
                self.config["providers"]["codex"]["args"] = [str(self.fake), flag, "alternate"]
                self.write_fixture()
                self.cli("doctor", expected=2)


if __name__ == "__main__":
    unittest.main()
