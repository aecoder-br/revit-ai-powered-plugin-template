# Revit Version Matrix Example

This is an example format only. Do not mark a version as passed unless its command actually ran.

| Revit Version | Target Framework | Installed | Command | Status | Evidence |
| --- | --- | --- | --- | --- | --- |
| 2024 | `net48` | `<yes/no>` | `./scripts/build.ps1 -RevitVersion 2024` | `<passed/failed/skipped>` | `<log>` |
| 2025 | `net8.0-windows` | `<yes/no>` | `./scripts/build.ps1 -RevitVersion 2025` | `<passed/failed/skipped>` | `<log>` |
| 2026 | `net8.0-windows` | `<yes/no>` | `./scripts/build.ps1 -RevitVersion 2026` | `<passed/failed/skipped>` | `<log>` |
| 2027 | `net10.0-windows` | `<yes/no>` | `./scripts/build.ps1 -RevitVersion 2027` | `<passed/failed/skipped>` | `<log>` |

Public Beta sign-off should not rely on skipped Revit versions.
