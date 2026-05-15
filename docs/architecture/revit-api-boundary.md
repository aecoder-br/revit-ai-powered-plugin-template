# Revit API boundary

## Hard rule

Only `src/RevitAiTemplate.Revit` may reference `Autodesk.Revit.API.dll` or `Autodesk.Revit.APIUI.dll`.

## Forbidden outside the Revit project

- `Autodesk.Revit.DB.Document`
- `Autodesk.Revit.DB.Element`
- `Autodesk.Revit.UI.UIDocument`
- `FilteredElementCollector`
- `Transaction`
- `ExternalEvent`

## Allowed across boundaries

- DTOs from Core.
- Strings.
- Numbers.
- `Guid`.
- Stable Revit identifiers represented as strings or integers.
- Domain-specific value objects.

## Modeless UI and background work

Modeless WPF, WebView2 callbacks, MCP tools, named pipe requests and background tasks are outside Revit API context. They must enqueue work into `RevitRequestQueue`, which raises `ExternalEvent` and executes the work inside Revit.

## Transactions

- Read operations should not open transactions.
- Write operations must use a named transaction.
- Long batches should use `TransactionGroup` with clear rollback behavior.
- Do not hide transaction failures behind broad catch blocks.
