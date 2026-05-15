# Revit API Senior Checklist

## Boundary Review

- Confirm only `src/RevitAiTemplate.Revit` references `Autodesk.Revit.*`.
- Confirm Core and Application receive DTOs, stable ids, or value objects.
- Do not pass `Document`, `UIDocument`, `Element`, or mutable Revit API objects across boundaries.
- Treat `ElementId` as adapter-local unless converted into a stable DTO contract.

## API Context

- Confirm calls run inside `IExternalCommand`, `IExternalApplication`, event handlers, updaters, or `ExternalEvent`.
- Confirm modeless UI, WebView2, MCP, named pipes, and background tasks use the ExternalEvent queue.
- Confirm cancellation and error feedback are visible to the user.

## Model Safety

- Prefer read-only model queries first.
- Require a named transaction for every write.
- Use `TransactionGroup` only when rollback behavior is clear.
- Review active document, linked documents, family documents, and workshared state.
- Review selection assumptions and empty selection behavior.
- Review units, parameters, shared parameters, storage types, and binding behavior.

## Validation

- Run `./scripts/check.ps1` when possible.
- Run version builds when Revit output changes.
- Document skipped Revit versions and missing SDKs.
