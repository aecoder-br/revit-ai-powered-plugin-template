---
name: pr-summary
description: Produce a PR summary with architecture, security, validation, and residual-risk notes.
agent: agent
argument-hint: <branch, PR, or diff>
---

# PR Summary

Use `AGENTS.md` as the repository rule source.
Use `.agents/skills/pr-reviewer/SKILL.md`.
Use `.agents/workflows/handoff-contract.md` and `.agents/workflows/validation-gates.md`.

Summarize:

- what changed;
- why it changed;
- architecture impact;
- Revit API context and threading impact;
- AI/MCP/security impact;
- tests and commands run;
- skipped validation and why;
- residual risks and follow-up work.

Do not hide failed or skipped validation.
