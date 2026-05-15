# Technical Writer Checklist

Use this checklist when creating or updating documentation.

## Before Writing

- Read `AGENTS.md`.
- Identify the doc audience: user, developer, reviewer, operator, or maintainer.
- Identify source files, feature brief, requirements, or ADR context.
- List assumptions when the source request is ambiguous.
- Do not create new architectural decisions without an ADR draft.

## Content Rules

- Keep docs short, operational, and versioned.
- Prefer commands, paths, constraints, and examples over broad prose.
- Match the repository's English technical style.
- Keep `AGENTS.md` concise and move long guidance to docs or `.agents`.
- Do not duplicate large sections across README, docs, and skill references.

## Revit-Specific Review

- State Revit version impact when relevant.
- State whether Revit API context or ExternalEvent behavior matters.
- State whether the workflow happens in project, family, view, selection, schedule, parameters, export, ACC/APS, or documentation.
- State validation commands and skipped Revit versions.

## AI/MCP Review

- State when runtime LLM calls go through AI Gateway.
- State MCP read/write behavior and confirmation requirements.
- State data minimization and privacy constraints.

## Handoff

- Include changed docs and intended audience.
- Include validation or review status.
- Mark ADR drafts as drafts until accepted.
- Hand off to `verifier` or `pr-reviewer` before merge readiness.
