# Command Evidence Example

This is an example format only. Record commands that actually ran.

| Command | Exit Code | Status | Notes |
| --- | ---: | --- | --- |
| `git status --short` | `<0/1>` | `<passed/failed>` | `<notes>` |
| `git rev-parse HEAD` | `<0/1>` | `<passed/failed>` | `<commit>` |
| `dotnet --list-sdks` | `<0/1>` | `<passed/failed>` | `<sdk summary>` |
| `./scripts/validate-environment.ps1 -RequireFull` | `<0/1>` | `<passed/failed>` | `<summary>` |
| `./scripts/check.ps1` | `<0/1>` | `<passed/failed>` | `<summary>` |

For failures, paste the exact error block or link to the captured log.
