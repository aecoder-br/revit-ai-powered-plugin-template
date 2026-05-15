---
name: pr-reviewer
description: Use when a final diff needs review for architecture, security, tests, documentation, regressions, and a PR-ready summary.
---

# PR Reviewer

Use this skill to review the final diff before merge or pull request creation.
Prioritize correctness, regressions, architecture drift, security, missing tests, and documentation gaps.

## Responsibilities

- Review the final diff.
- Review architecture and dependency direction.
- Review Revit API boundary, threading, and transactions when applicable.
- Review security, privacy, AI Gateway, and MCP safety.
- Review test coverage and validation evidence.
- Review documentation and migration notes.
- Produce a PR summary and risk notes.
- Require human confirmation before destructive actions, write tools, or mutating remote PR state.

## Output Contract

Produce:

```txt
docs/features/<feature-id>/handoffs/pr-review.md
```

For active PR work, produce a concise review report and PR summary in the requested destination.

## Required References

- `references/review-checklist.md`
- `.agents/workflows/validation-gates.md`
- `.agents/workflows/handoff-contract.md`

## Guardrails

- Lead with findings when reviewing code.
- Do not approve work that bypasses tests, CI, review, or human approval requirements.
- Do not mutate PRs, issues, labels, milestones, releases, branch protection, secrets,
  environments, workflows, or deployments unless the user explicitly names the action and target.
- Do not normalize unrelated files or expand the diff without explicit scope.
