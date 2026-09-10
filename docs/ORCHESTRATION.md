# AFTERMARKET orchestration

## Operating agreement

Dan sets outcomes, priorities, budget and creative direction. The agents own the technical work. When an agent can inspect, download, organize, install an approved free tool, write, build, test or fix something within the available access, it should do that work. A manual checklist is not the default deliverable.

This is the project operating policy requested on September 10, 2026. Read it at the start of every project session alongside AGENTS.md and orchestration/tasks.json. The user can change assignments and authorization in conversation; do not turn this document into a new permission barrier.

## Ownership

| Participant | Default responsibility | Expected output |
| --- | --- | --- |
| ChatGPT/Codex orchestrator | Interpret requests, inspect current state, prioritize, route tasks, reconcile evidence and report outcomes | Owned queue, acceptance criteria, decisions and concise progress |
| Local Codex | Environment setup, downloads, asset preparation, Blender scripting, Godot implementation, tests and fixes | Reviewable project changes and actual execution evidence |
| Claude Code with existing Claude subscription | Independent code/art-pipeline review, edge cases and consistency checks | Findings tied to files and evidence; default read-only |
| Grok Build with existing Grok subscription | Research, reference comparisons, creative alternatives and critical questions | Sourced brief and actionable alternatives; default read-only |
| Dan | Creative choices, play feel, priorities and access that only the account/PC owner can supply | Decisions on prepared, concrete results |

These assignments are workflow choices, not claims that a vendor is universally superior at a task. A Codex sub-agent is still Codex, not Claude or Grok. Record the provider actually invoked. Additional AI steps must resolve a concrete uncertainty or improve the result; do not send every trivial task through three services.

## Per-request workflow

1. Inspect current files, active branch, local modifications, task evidence and installed capabilities. Reuse completed work. A cloud checkout cannot establish the state of Dan's Windows PC.
2. Convert the request into the smallest useful tasks, with an owner, dependencies, acceptance criteria and expected evidence. The orchestrator updates the queue; Dan does not fill out task forms.
3. Execute using available tools. If already operating as local Codex, claim and perform implementation tasks directly rather than spawning another Codex recursively. Use the dispatcher for a separate provider when helpful.
4. One agent owns writes to a working directory. Inspect and preserve unrelated local edits. Use isolated worktrees for independent implementation when necessary; do not reset, stash, switch or overwrite Dan's work to make setup easier. Reviewers receive a saved diff and context.
5. Verify actual artifacts and relevant checks. A provider returning exit code zero means its invocation ended successfully; it does not prove the task was completed.
6. Record evidence and outcome. Generate bounded fix tasks for verified defects. Continue ready independent work when an account or external download is blocked.
7. Report what changed, what was verified, actual provider usage, and the single next decision or access action if one is genuinely needed. Update development status and prepare a reviewable branch/PR when appropriate.

## Task queue and local dispatcher

The tracked source of task intent and state is **orchestration/tasks.json**. Provider routing and executable names are in **orchestration/config.json**. The Python dispatcher uses only the standard library and the locally installed official CLIs. It is not an always-running service and does not create a remote connection to the PC.

Run from the repository root:

```text
python tools/orchestrate.py status
python tools/orchestrate.py doctor
python tools/orchestrate.py next
python tools/orchestrate.py brief AF-001
```

An interactive local Codex session should claim its ready task with `python tools/orchestrate.py claim AF-001 --owner codex-local`, do its owned work with its existing tools, and record the outcome. A claim records ownership and blocks another writable task until the controller records completion, a blocker, or an explicit retry. It should not require its own CLI adapter just to carry out tasks itself.

The run command is for a separate CLI worker. For example, once AF-004 is verified, `python tools/orchestrate.py run AF-005` dispatches its independent review. Automatic routing identifies the actual worker and records any preflight fallback. Runtime failures remain failed/blocked for the controller to investigate and reroute; the runner does not blindly repeat an inference or partial implementation. AF-002's initial brief is already complete and should be reused.

Use **python tools/orchestrate.py --help** and the subcommand help for exact options. To add new work, use the add command or have the orchestrator edit the queue under its normal single-writer workflow. Completion requires real evidence files:

```text
python tools/orchestrate.py record AF-001 --status done --summary "Detected tools and verified a sample export/import." --evidence docs/evidence/AF-001.md
```

Only run this after the stated work has actually been checked. The controller is responsible for inspecting the evidence against every acceptance criterion. Pending checks or a prepared prompt do not constitute completion. Provider results need review before task acceptance.

States:

| State | Meaning |
| --- | --- |
| queued | Waiting for its completed dependencies and an available executor |
| running | A worker currently owns execution |
| review | Worker invocation succeeded; controller must inspect its output |
| done | Controller verified the acceptance criteria and recorded evidence |
| blocked | A specific dependency, access, quota or capability blocks progress |
| failed | Execution failed and needs investigation or a bounded fix |

Raw prompts and provider transcripts are local in **.orchestration/** and excluded from Git and Godot imports. Validated, redacted provider results are saved in **orchestration/evidence/**. Keep the controller's concise verification summaries in **docs/evidence/**. Completion requires explicitly selected durable evidence, so a task does not depend on an ignored local transcript after another computer checks out the repository. Commit task/evidence changes with the related work. Do not put credentials, personal account details, raw tool transcripts or downloaded archives in a PR.

## Subscription access and fallbacks

Use existing subscription sign-ins. Do not configure API keys, select API billing, enable overages/topups, buy credits or add subscriptions as an automatic fallback. Preserve provider, organization and operating-system permissions. The dispatcher must not use flags that bypass them. Local account eligibility and remaining allowance need actual checks; a documented CLI feature is not proof that it works on this machine.

- **Codex:** use ChatGPT sign-in and a subscription authentication restriction. Use the writable sandbox for assigned implementation and read-only sandbox for reviews.
- **Claude:** verify subscription authentication, reject API/cloud-provider credential overrides, and restrict review tools. Configured hooks can have side effects even with a narrow tool list; account for them before calling a review read-only.
- **Grok:** use the official Grok Build CLI with browser/cached subscription authentication. Verify the active credential route; Grok's consumer subscription and xAI API billing are distinct. Unsupported CLI/auth layouts are a recorded blocker, not an invitation to guess credentials or use browser cookies.
- **Unavailable secondary provider:** perform a bounded fallback with available Codex tools when appropriate and explicitly record that Claude/Grok was not used. Do not claim an independent vendor review occurred. If independence is essential, leave that review pending while continuing other tasks.
- **Quota exhausted:** save a checkpoint and attempt a permitted different provider for an appropriate task. Do not silently increase spending or loop indefinitely.

The three CLIs were not available to this dispatcher in the cloud authoring environment when this layer was built. Mocked dispatcher tests establish routing and error behavior; successful Windows authentication and real provider execution must be established by the local controller.

## Access and escalation

Existing authorization covers routine reversible work necessary for the requested project outcome, including free downloads, approved free tools, scripts, builds, tests, fixes and preparation of branches/draft PRs. Do not ask for confirmation again merely because a task has several steps.

Escalate only when needed for an account sign-in, an actual OS/permission rejection, new spending, a consequential product choice, or an action outside the authorized scope. First complete everything useful and prepare the concrete action/result. State the exact failed action or missing access and why only Dan can resolve it. An automatic approval rejection must be reported honestly with its stated reason.

## First activation on Dan's PC

The local Codex session, not Dan, should fetch the orchestration branch/commit, inspect its changes, and integrate those additions with the current game checkout while preserving local work. Then read this agreement, inspect the queue, run doctor, and execute ready tasks using existing tools. Install missing official CLIs only if their assigned tasks need them. Present a provider's supported sign-in flow only when credentials are missing; do not request or store secrets in chat.

This requires one local-session handoff because the cloud conversation does not currently have a command channel to Dan's PC. Once the local session is active, the orchestrator should manage subsequent work from the persistent queue. There is no claim of an unattended Windows agent or background polling service being deployed.

## Official execution references

Verified September 10, 2026:

- Codex execution: https://learn.chatgpt.com/docs/non-interactive-mode
- Codex authentication: https://learn.chatgpt.com/docs/auth
- Codex authentication restriction: https://learn.chatgpt.com/docs/config-file/config-reference
- Claude CLI: https://code.claude.com/docs/en/cli-reference
- Claude structured/headless execution: https://code.claude.com/docs/en/headless
- Claude authentication precedence: https://code.claude.com/docs/en/authentication
- Claude Max usage: https://support.claude.com/en/articles/11145838-use-claude-code-with-your-pro-or-max-plan
- Grok headless/ACP authentication: https://docs.x.ai/build/cli/headless-scripting
- Grok CLI: https://docs.x.ai/build/cli/reference
- Grok credentials/configuration: https://docs.x.ai/build/enterprise
- Grok subscriber usage: https://docs.x.ai/grok/faq

Recheck installed CLI help when a documented option is unsupported. Do not silently weaken permissions or substitute API billing to make the command work.
