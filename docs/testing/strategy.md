# Testing strategy

## Unit tests

Test Core and Application logic without Revit.

## Adapter tests

Revit adapter tests require Revit or RevitTestFramework/RvtUnit-style infrastructure. Keep those tests separate from fast unit tests.

## Manual smoke test

For each supported version:

1. Build with `./scripts/build.ps1 -RevitVersion <year>`.
2. Install with `./scripts/dev-install.ps1 -RevitVersion <year>`.
3. Open Revit.
4. Confirm the ribbon appears.
5. Open Assistant.
6. Run model summary.
7. Confirm no journal errors.

## MCP smoke test

1. Start Revit with the add-in loaded.
2. Configure the MCP server in Claude/Cursor.
3. Ask: "List available tools."
4. Run active model summary.
5. Confirm output matches Revit model.
