# Requirements Analyst Checklist

Use this checklist to transform `brief.md` into actionable software requirements.

## Inputs

- Read `docs/features/<feature-id>/brief.md` when it exists.
- Preserve assumptions from the brief.
- Add open questions instead of inventing requirements.
- Check `AGENTS.md` for repository constraints.

## Functional Requirements

- Use stable ids: `FR-001`, `FR-002`.
- State actor, action, system response, and data involved.
- Separate read-only behavior from write behavior.
- Identify whether each requirement touches Revit API, WPF/WebView2, MCP, AI Gateway, persistence, installer, or docs.

## Acceptance Criteria

- Use Given/When/Then.
- Include normal, empty, invalid, permission, and failure paths.
- Include Revit workflow context.
- Include expected user-visible feedback inside Revit.

## Non-Functional Requirements

- Cover performance, reliability, observability, usability, maintainability, and compatibility.
- Include Revit 2024, 2025, 2026, and 2027 impacts.
- Identify whether `REVIT2024`, `REVIT2025`, `REVIT2026`, or `REVIT2027` guards may be needed.

## Security and Privacy

- Identify model data leaving the Revit process.
- Require AI Gateway for runtime LLM calls.
- Require deterministic MCP tools.
- Require confirmation, audit logging, and rollback for write tools.
- Identify secrets, credentials, and customer data handling.

## Test Requirements

- List unit, integration, manual Revit, MCP, AI Gateway, and packaging validation as applicable.
- Include `./scripts/check.ps1`.
- Include versioned `./scripts/build.ps1 -RevitVersion <year>` when Revit add-in output changes.
- Document skipped versions when Revit is not installed.

## Handoff

- Save all output files under `docs/features/<feature-id>/`.
- Recommend path ownership for implementation tasks.
- Call out ADR needs before implementation starts.
