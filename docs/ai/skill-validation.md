# Agent Skill Validation

This repository validates local AI-agent skill definitions with:

```powershell
./scripts/validate-skills.ps1
```

The validator scans `.agents/skills` by default. If `.claude/skills` or `.cursor/skills` exist, they are also scanned. Use `-IncludeMirrors` to include mirror roots explicitly even when they are missing, which prints skip messages for absent roots.

## Parameters

| Parameter | Purpose |
|---|---|
| `-RootPath` | Repository root to validate. Defaults to the parent of the `scripts` directory. |
| `-FailOnWarnings` | Returns exit code `1` when warnings are present. By default, warnings do not fail validation. |
| `-IncludeMirrors` | Includes `.claude/skills` and `.cursor/skills` in the scan set. |

## Critical Rules

Each skill must live in its own folder with a `SKILL.md` file.

`SKILL.md` must start with YAML frontmatter delimited by `---` and must include:

- `name`;
- `description`.

For production skills, `name` must:

- use lowercase kebab-case;
- be no longer than 64 characters;
- match the skill folder name.

The reserved `.agents/skills/_template` folder is validated as a scaffold. Its placeholder `name: skill-name` is allowed so new skills can copy and replace it.

`description` must:

- be non-empty;
- be no longer than 1024 characters;
- mention when to use the skill.

`SKILL.md` must not contain:

- API keys or secret-looking assignments;
- tokens or known token formats;
- passwords or `senha` assignments;
- instructions to exfiltrate data;
- destructive commands without confirmation language.

Script files inside a skill are allowed only under that skill's `scripts/` directory.

## Warnings

Warnings are reported but do not fail validation unless `-FailOnWarnings` is used.

The validator warns on:

- long Markdown lines over 160 characters;
- `Invoke-WebRequest` or `curl` calls to domains outside the built-in allowlist;
- recursive removal patterns in skill scripts;
- script access to `AppData`, `ProgramData`, `USERPROFILE`, `HOME`, `C:\Users`, `Documents`, `Desktop`, or `Downloads`.

## Check Integration

`./scripts/check.ps1` calls this validator when `.agents/skills` exists. The check script fails if the validator returns a critical error.

The validator does not require external dependencies and is designed to run on Windows PowerShell-compatible environments.
