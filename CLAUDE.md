# AFTERMARKET agent entry point

Read @AGENTS.md and @docs/ORCHESTRATION.md before working.

Dan has asked agents to carry out work they can automate, not return manual setup checklists. Codex is the primary implementer and local controller. Claude is the independent reviewer by default; the task brief defines the exact scope. Review the supplied diff and evidence, distinguish confirmed defects from suggestions, and return an actionable result. Do not edit shared implementation files while another provider owns them. Use the existing subscription and preserve its permission and spending settings.

Task state is in orchestration/tasks.json. Actual evidence, not a successful model invocation, determines completion. Never represent another provider's output as your own or invent tests, screenshots, account access, or completed external actions.
