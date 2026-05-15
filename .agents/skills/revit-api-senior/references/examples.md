# Revit API Senior Examples

## Read-Only Tool

Use a read-only MCP tool for active model summary before creating a write workflow.

Output should state:

- no transaction required;
- valid Revit context required;
- DTO returned to MCP or UI;
- no Revit API object leaves the adapter.

## Write Workflow

For a parameter update workflow, define:

- user confirmation step;
- audit entry;
- named transaction;
- rollback behavior;
- failure feedback;
- validation command.

## Boundary Failure

Fail review when a ViewModel directly imports `Autodesk.Revit.DB` or receives `Document`.
