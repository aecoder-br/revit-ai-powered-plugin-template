# AI Gateway Backend Engineer Examples

## Endpoint Spec

Route: `POST /assistant/analyze-model`

Request:

- model summary DTO;
- user prompt;
- policy context;
- cancellation token.

Response:

- assistant message;
- citations or tool references;
- policy outcome;
- safe error details.

## Provider Boundary

Revit add-in should call the gateway HTTP endpoint.
The gateway decides which provider handles the request.

## Logging

Log request id, tenant id if present, policy result, duration, and provider route.
Do not log raw model data by default.
