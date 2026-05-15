# Feature Lifecycle

Use this workflow for non-trivial repository changes.

## 1. Intake

- Capture the user request, constraints, target files, and explicit non-goals.
- Identify whether the task touches Revit API, runtime AI, MCP, WPF/WebView2, build scripts, templates, installer, or docs.
- Check `AGENTS.md` before planning.
- Check the relevant `.agents/workflows` document before assigning parallel work.

## 2. Plan

- Define the smallest coherent implementation slice.
- Identify required roles from `.agents/roster.json`.
- Assign path ownership before parallel work begins.
- Define validation commands before editing.
- Record known blockers such as missing Revit versions or SDKs.

## 3. Implement

- Keep changes inside assigned ownership paths.
- Keep Revit API code inside `src/RevitAiTemplate.Revit`.
- Keep modeless UI, MCP, background tasks, and named pipe requests routed through the ExternalEvent queue before touching Revit.
- Do not change target frameworks, Revit references, or namespaces unless the task explicitly requires it.

## 4. Review

- Run a self-review for architecture boundaries, threading, security, and data handling.
- Use `pr-reviewer` for cross-cutting changes.
- Use `revit-api-senior` for Revit API changes.
- Use `cybersecurity-privacy-engineer` for AI runtime, MCP, secrets, or external data sharing changes.

## 5. Validate

- Run the gates from `validation-gates.md`.
- Prefer `./scripts/check.ps1` for repository-level validation.
- Run version-specific builds with `./scripts/build.ps1 -RevitVersion <year>` when the change affects Revit add-in output.
- Record skipped Revit versions exactly when a version is not installed.

## 6. Handoff

- Provide changed files, validation evidence, remaining blockers, and next owner.
- Use `handoff-contract.md` for handoffs between agents.
- Do not merge work that lacks ownership, validation status, or explicit residual risk.

## 7. Merge Readiness

- Confirm no path ownership conflicts remain.
- Confirm generated files are intentional.
- Confirm no secrets, customer data, model exports, or machine-local paths were added.
- Confirm `AGENTS.md` stayed short and points to canonical docs instead of duplicating them.
