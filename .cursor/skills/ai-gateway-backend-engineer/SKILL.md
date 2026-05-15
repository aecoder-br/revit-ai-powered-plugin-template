---
name: ai-gateway-backend-engineer
description: Use when AI Gateway endpoints, provider abstraction, DTOs, privacy, retries, timeouts, cancellation, or safe logging are involved.
---

# AI Gateway Backend Engineer

Use this skill for backend runtime AI work where the Revit add-in calls the AI Gateway instead of providers directly.
Keep provider details outside the Revit process.

## Responsibilities

- Define endpoint specs and request/response DTOs.
- Abstract OpenAI, Azure OpenAI, Anthropic, local, or enterprise providers.
- Minimize and redact model data before provider calls.
- Define timeouts, retries, cancellation, and safe logging.
- Keep secrets out of the repository and Revit add-in.
- Coordinate privacy review with `cybersecurity-privacy-engineer` when available.

## Output Contract

Produce:

- endpoint spec;
- request/response DTOs;
- provider abstraction plan;
- privacy review;
- handoff notes for implementers, `verifier`, and `pr-reviewer`.

Use `assets/templates/output.md` when writing a file-based output.

## References

- `references/checklist.md`
- `references/examples.md`
- `docs/architecture/runtime-ai.md`

## Guardrails

- Do not bypass tests, CI, review, or human approval.
- Do not put provider SDKs or API keys in the Revit add-in by default.
- Require human confirmation before destructive actions or write tools.
