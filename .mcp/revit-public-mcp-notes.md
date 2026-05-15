# Revit Public MCP Notes

## Status

Use Revit Public MCP Server / Revit MCP only when a reviewed server is available in the target development environment.

Do not assume availability in CI, user machines, or public runners.

## Review Checklist

Before enabling a public Revit MCP server:

- identify the server provider, version, endpoint, and transport;
- list all tools and classify each as read-only or write;
- confirm whether tools can alter an active Revit model;
- reject arbitrary Revit API execution tools;
- reject arbitrary shell or script execution tools;
- confirm input validation and output sanitization behavior;
- confirm logging does not store secrets or full model data;
- document how the server reaches Revit API context.

## Required Revit Boundary

Any action that touches a model must enter the Revit add-in through a bridge and `ExternalEvent`.

An external MCP server should not reference `Autodesk.Revit.*`. It should send explicit DTO requests to the add-in, and the add-in should perform model reads or writes inside a valid Revit API context.

## Production Gate

Do not enable public Revit MCP write tools for production until there is:

- threat model;
- command-specific confirmation UX;
- named `Transaction` plan;
- rollback or compensation plan;
- audit logging;
- Revit version validation.
