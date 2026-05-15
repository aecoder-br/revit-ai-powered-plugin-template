# Cybersecurity Privacy Checklist

## Scope

- Identify Revit entry points, modeless UI, WebView2, MCP, AI Gateway, installer, and background task boundaries.
- Confirm which Revit versions are in scope: 2024, 2025, 2026, 2027.
- Identify whether the workflow reads, writes, exports, stores, or sends model data.

## Threat Model

- Document assets: model metadata, parameters, element identifiers, user prompts, local settings, audit logs, and credentials.
- Document trust boundaries between Revit, UI, AI Gateway, provider adapters, MCP tools, filesystem, and network.
- Classify read-only and write paths separately.
- Confirm write paths use `ExternalEvent` and named Revit `Transaction` boundaries.

## AI And Data Privacy

- Minimize model data before sending it to any AI runtime.
- Redact project names, customer names, element metadata, and free text when not required.
- Define retention and deletion expectations for prompts, responses, cache, and audit logs.
- Confirm user-visible disclosure for external AI calls when applicable.

## MCP Security

- Prefer deterministic, narrow tools with structured schemas.
- Keep read tools separate from write tools.
- Require confirmation, audit log, and rollback plan for write tools.
- Reject generic tools that execute arbitrary Revit API or shell commands.

## Prompt Injection

- Treat model text, linked files, documentation, WebView2 content, and provider responses as untrusted input.
- Keep system and tool instructions separate from retrieved or user-provided content.
- Require output validation before executing model changes.

## Dependency And Skill Supply Chain

- Justify new dependencies and external tools before adding them.
- Validate mirrored skills against the canonical `.agents/skills` source.
- Review generated scripts for network access, destructive actions, and user-profile access.

## Logging

- Log decisions and correlation identifiers, not sensitive payloads.
- Avoid storing prompts, responses, model exports, credentials, or customer data unless explicitly justified.
- Define log retention and user support collection boundaries.
