# Security Policy

## Supported versions

This template is intended to support Revit 2024, 2025, 2026, and 2027 through separate builds.

## Data handling

- Do not send model data to LLM providers by default.
- Runtime AI calls must go through the AI Gateway.
- The AI Gateway must implement provider policy, logging, redaction, rate limits, and tenant/user authorization before production use.
- Never store secrets in `.addin`, `appsettings.json`, repository files, logs, or Revit journal output.

## MCP security

- Begin with read-only tools.
- Write tools require confirmation, audit logging, and transactions.
- Do not expose arbitrary code execution tools.
- Do not expose full model exports unless explicitly approved.

## Reporting

Report issues to the repository owner or security contact defined by your organization.
