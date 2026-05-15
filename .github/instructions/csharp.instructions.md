---
applyTo: "**/*.cs"
---

# C# instructions

- Prefer constructor injection or explicit composition over service locator, except for the Revit entrypoint boundary.
- Keep methods small and side effects explicit.
- Use DTOs across project boundaries.
- Avoid static mutable state except at Revit host composition boundaries.
- Avoid reflection unless necessary for plugin discovery or MCP tooling.
