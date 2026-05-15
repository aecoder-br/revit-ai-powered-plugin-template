# AI Gateway Backend Engineer Checklist

## Endpoint Design

- Define route, method, request DTO, response DTO, and errors.
- Include cancellation behavior.
- Include timeout behavior.
- Include retry boundaries.
- Avoid leaking provider-specific DTOs to the Revit add-in.

## Provider Abstraction

- Keep providers behind an application interface.
- Keep credentials in environment or deployment config, not source.
- Support model/provider routing in the gateway.
- Keep Revit add-in provider-agnostic.

## Data Minimization

- Send summaries instead of full model dumps.
- Redact sensitive parameter values when possible.
- Avoid customer data unless necessary and user-visible.
- Log policy decisions and metadata, not sensitive payloads.

## Validation

- Run `./scripts/check.ps1` when possible.
- Add tests for DTO serialization and failure behavior when practical.
- Review privacy impact before implementation handoff.
