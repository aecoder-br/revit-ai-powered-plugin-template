# Skill Checklist

Use this checklist as the starting point for a concrete skill.

## Before Work

- Read `AGENTS.md`.
- Identify the task type and validation gate.
- Confirm owned paths.
- Confirm whether Revit API, MCP, AI Gateway, WPF/WebView2, build scripts, templates, or installer files are in scope.
- Confirm explicit non-goals.

## During Work

- Keep edits inside owned paths.
- Keep Revit API code inside `src/RevitAiTemplate.Revit`.
- Use DTOs and stable identifiers across project boundaries.
- Keep modeless UI and background access routed through ExternalEvent before touching Revit.
- Keep changes small and reviewable.

## Before Handoff

- Run the relevant validation gates.
- Capture exact command results.
- Document skipped validation and environment blockers.
- Review security and data handling.
- Prepare a handoff if another role continues the work.
