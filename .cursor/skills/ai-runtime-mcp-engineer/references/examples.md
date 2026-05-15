# AI Runtime MCP Engineer Examples

## Read Tool

Tool: `get_active_model_summary`

Safety:

- read-only;
- no transaction;
- can run without confirmation;
- returns structured summary DTO.

## Write Tool

Tool: `set_parameter_values`

Safety:

- write tool;
- requires confirmation;
- requires audit log;
- requires named transaction;
- requires rollback plan.

## Rejected Tool

Reject a tool named `execute_revit_api` because it is broad arbitrary execution.
