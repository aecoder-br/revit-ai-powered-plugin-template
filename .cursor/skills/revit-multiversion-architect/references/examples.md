# Revit Multiversion Architect Examples

## Version-Specific API

Prefer:

- adapter method with version-specific implementation;
- narrow `#if REVIT2027` near the Revit API call;
- shared DTO returned to Application or UI.

Avoid:

- conditional compilation in Core;
- one binary for all Revit versions;
- changing target frameworks for convenience.

## Build Report

Report each version separately:

- Revit 2024: passed, failed, or skipped.
- Revit 2025: passed, failed, or skipped.
- Revit 2026: passed, failed, or skipped.
- Revit 2027: passed, failed, or skipped.
