# CI Validation

This repository uses CI checks that validate AI configuration, templates, and build scripts without requiring Revit on the default runner.

## Standard CI Scope

Default workflows should validate:

- repository scripts that do not require Revit;
- `.agents/skills` and tool mirrors;
- AI adapter parity against `.agents/roster.json`;
- `.codex/config.toml`;
- GitHub Copilot prompt files;
- dotnet and Visual Studio template manifests where possible.

Default CI must not require Autodesk Revit to be installed. Full Revit builds belong on a specialized Windows runner with the required Revit versions and SDKs.

## AI Config Workflow

`.github/workflows/ai-config-validation.yml` validates:

- `.agents/skills` plus Claude/Cursor mirrors with `scripts/validate-skills.ps1`;
- adapter parity with `scripts/validate-ai-adapters.ps1`;
- `.agents/roster.json` JSON shape and role naming;
- `.codex/config.toml` with `scripts/validate-toml.ps1`;
- `.github/prompts/*.prompt.md` frontmatter and canonical references.

## Workflow Linting

The workflow includes an optional non-blocking `actionlint` job.

Dependency:

- `rhysd/actionlint@v1`

This dependency is intentionally isolated in a `continue-on-error: true` job so workflow linting provides signal without making core validation fragile if the action cannot be downloaded.

Run actionlint locally when it is available:

```powershell
actionlint
```

If actionlint is not installed, review YAML manually for:

- valid triggers;
- valid job and step indentation;
- correct shell syntax for multiline PowerShell;
- no secrets printed in logs;
- no Revit installation assumptions in default jobs.

## TOML Validation

PowerShell does not include a native, fully compliant TOML parser. `scripts/validate-toml.ps1` therefore implements a repository-focused smoke parser for the `.codex/config.toml` subset used here.

It validates:

- section syntax;
- key/value syntax;
- balanced quoted strings;
- scalar values used by this repository;
- duplicate sections;
- duplicate keys inside a section;
- required Codex root keys;
- recognized conservative `approval_policy` and `sandbox_mode` values;
- obvious secret-related terms.

It does not claim full TOML 1.0 compliance. If `.codex/config.toml` grows to require arrays of tables, multiline strings, dates, or inline tables, add a pinned lightweight TOML parser or keep those constructs out of the config.

Run locally:

```powershell
./scripts/validate-toml.ps1
./scripts/check.ps1
```
