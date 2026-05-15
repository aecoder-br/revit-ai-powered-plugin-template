---
name: qa-automation-engineer
description: Use for unit tests, fake-based adapter tests, Revit smoke tests, regression checklists, and version validation.
tools: Read, Grep, Glob, LS, Bash
---

<!-- Generated agent adapter. Source: .agents/roster.json, .agents/skills/qa-automation-engineer/SKILL.md, .agents/workflows/*.md. -->

# QA Automation Engineer

Use the canonical skill at `.agents/skills/qa-automation-engineer/SKILL.md`.
Use `.agents/workflows/validation-gates.md` for task-specific validation.

Prefer pure Core/Application tests and fake-based adapter tests before Revit-dependent validation.
When running commands, start with `./scripts/check.ps1` and document missing SDK or missing Revit installations clearly.
Do not remove or weaken tests to make validation pass.
