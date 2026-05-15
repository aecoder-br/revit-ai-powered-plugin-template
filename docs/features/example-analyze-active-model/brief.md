# Analyze Active Model and Summarize Categories

## Summary

This example feature demonstrates the agent-team workflow for a safe, read-only Revit capability: collect a summary of the active model's categories and prepare it for analysis through the AI Gateway.

The example is documentation-only. It does not create branches, worktrees, implementation code, Revit API calls, or AI Gateway endpoints.

## Source Request

"Analyze active model and summarize categories using AI Gateway."

## Problem Statement

Revit users often need a fast overview of what a model contains before deciding which categories, views, schedules, parameters, or worksets require deeper review. A read-only category summary can provide context for AI-assisted review without exporting model geometry or sensitive data.

## Personas

- BIM coordinator: needs a quick model inventory before coordination checks.
- Revit add-in developer: needs a safe feature slice that proves the ExternalEvent and AI Gateway boundaries.
- QA reviewer: needs a repeatable validation target that does not mutate the model.

## User Journey

1. User opens a Revit project.
2. User runs a read-only model summary command from the add-in.
3. The Revit layer collects category counts and minimal metadata inside a valid Revit API context.
4. The Application layer receives DTOs only.
5. The AI Gateway receives a minimized request and returns a concise summary.
6. The UI displays the summary with clear limitations and no model writes.

## In Scope

- Plan a read-only active model category summary.
- Demonstrate path ownership for parallel agent tasks.
- Demonstrate handoff artifacts between product, requirements, Revit API, QA, security, and PR review skills.
- Document validation commands without creating real worktrees.

## Out of Scope

- Production implementation.
- New Revit API code.
- New AI Gateway endpoint.
- New tests.
- Branch, lock, or worktree creation.
- Model write operations.

## Architecture Constraints

- Revit API boundary: any future implementation must keep `Autodesk.Revit.*` usage inside `src/RevitAiTemplate.Revit`.
- ExternalEvent requirement: modeless UI, MCP, WebView2, background tasks, or AI workflows must reach Revit through ExternalEvent.
- DTO boundary: Core, Application, UI, AI Gateway, and MCP must not receive `Document`, `UIDocument`, `Element`, or mutable `ElementId` objects.
- Runtime AI requirement: the Revit add-in must call the AI Gateway, not provider SDKs directly.
- Multi-version requirement: the future implementation must consider Revit 2024, 2025, 2026, and 2027.

## Path Ownership Demonstration

The example task plan assigns disjoint `allowedPaths` by task type. Documentation tasks own only `docs/features/example-analyze-active-model/**`; review tasks are read-only against source paths; implementation-oriented tasks are planned but not executed.

This prevents concurrent agents from editing the same files and gives the verifier a concrete diff boundary to check.

## Risks

- Collecting too much model data for an AI request.
- Accidentally bypassing ExternalEvent for model access.
- Letting an AI summary imply authoritative model validation.
- Cross-version Revit API differences in category or parameter behavior.
- Agents editing outside their assigned paths.

## Open Questions

- Should linked model categories be included or reported separately?
- Should family documents be supported in the first implementation?
- Which category metadata is safe to send to the AI Gateway by default?
- Should the summary include worksets, phases, design options, or only category counts?
