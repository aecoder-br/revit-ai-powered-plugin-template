# ADR 0001: Build one add-in binary per Revit version

## Status

Accepted

## Context

Revit 2024, 2025/2026 and 2027 use different .NET runtimes and API binaries.

## Decision

The template builds a separate Revit add-in binary per major Revit version using the `RevitVersion` MSBuild property.

## Consequences

- More predictable compatibility.
- Cleaner runtime dependency behavior.
- Slightly more build/package complexity.
