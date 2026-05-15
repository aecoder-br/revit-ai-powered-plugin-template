---
name: security-review
description: Review MCP, AI Gateway, prompt injection, secrets, PII, and Revit model data leakage risk.
agent: agent
argument-hint: <diff, files, branch, or PR>
---

# Security Review

Use `AGENTS.md` as the repository rule source.
Use `.agents/skills/cybersecurity-privacy-engineer/SKILL.md`.
Use `.agents/workflows/validation-gates.md` and `docs/security/mcp-security-policy.md`.

Review for:

- model data leakage;
- prompt injection;
- MCP over-permission;
- unsafe Revit write operations;
- credential exposure;
- unsafe logging;
- dependency or skill supply-chain risk.

Output pass/fail, findings ordered by severity, and mitigation steps. Do not approve arbitrary Revit API tools or automatic destructive actions.
