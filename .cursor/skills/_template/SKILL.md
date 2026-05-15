---
name: skill-name
description: Short, specific description of when this repository skill should be used.
metadata:
  short-description: Short display label for agent UIs.
---

# Skill Name

Use this template to create repository-local skills under `.agents/skills/<lowercase-kebab-case-name>`.

## Rules

- Use a lowercase kebab-case folder name and `name`.
- Keep the description short, specific, and trigger-oriented.
- Keep this file concise.
- Put detailed checklists in `references/checklist.md`.
- Put transfer notes in `references/handoff.md`.
- Put reusable output shapes in `assets/templates`.
- Do not duplicate `AGENTS.md`; reference it when repository-wide rules matter.
- Do not store secrets, customer data, model exports, or local credentials in skill files.

## Workflow

1. Read `AGENTS.md`.
2. Read only the workflow files relevant to the task in `.agents/workflows`.
3. Confirm path ownership before editing.
4. Apply the skill-specific checklist.
5. Run the required validation gates.
6. Produce a handoff if another agent or role continues the work.

## References

- `references/checklist.md`: skill-specific execution checklist.
- `references/handoff.md`: skill-specific handoff notes.
- `assets/templates/output-template.md`: expected output shape.
