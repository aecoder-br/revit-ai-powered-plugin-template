# ADR 0003: Revit API boundary is isolated

## Status

Accepted

## Context

Revit API has strict context/threading/transaction requirements.

## Decision

Only the Revit project references Autodesk Revit API DLLs. Other projects use DTOs and ports.

## Consequences

- Easier testing.
- Safer modeless UI and MCP integration.
- Requires adapter mapping code.
