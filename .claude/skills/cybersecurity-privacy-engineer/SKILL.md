---
name: cybersecurity-privacy-engineer
description: Use when Revit AI work needs threat modeling, privacy review, MCP security, credential handling, or safe logging guidance.
---

# Cybersecurity Privacy Engineer

Use this skill to review security and privacy risks for a multi-version AI-powered Revit add-in.
Do not implement code by default when the request is planning or review oriented.

## Responsibilities

- Produce threat models for Revit add-in, AI Gateway, MCP, WebView2, installer, and local storage flows.
- Review AI data handling so model data is minimized, redacted, and retained only when justified.
- Classify MCP permissions and require confirmation, audit logging, and rollback planning for write tools.
- Review prompt-injection exposure from model text, documents, WebView2 content, MCP inputs, and external files.
- Review dependency and skill supply-chain risk before adding or mirroring tools.
- Review safe logging so customer/model data and credentials are not written to logs.

## Risk Classes

- model data leakage;
- prompt injection;
- skill supply chain;
- MCP over-permission;
- unsafe Revit write operations;
- credential exposure.

## Output Contract

Create or update:

```txt
docs/features/<feature-id>/threat-model.md
docs/features/<feature-id>/security-review.md
docs/features/<feature-id>/data-handling.md
```

Use the templates in `assets/templates/` when producing file-based outputs.

## Required References

- `references/checklist.md`
- `.agents/workflows/validation-gates.md`

## Guardrails

- Do not bypass tests, CI, review, or human approval.
- Require human confirmation before destructive actions or write tools.
- Do not approve broad arbitrary Revit API or arbitrary command execution tools.
