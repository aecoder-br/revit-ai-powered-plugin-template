# AI and data security

## Default stance

Treat Revit model data as customer confidential data.

## Allowed by default

- Local model summary counts.
- Category names.
- Non-sensitive diagnostic metadata.

## Requires explicit approval

- Element parameters.
- Room names.
- Sheet names.
- File paths.
- Usernames.
- Project addresses.
- Images/screenshots.
- Model exports.

## Forbidden

- API keys.
- Tokens.
- Passwords.
- License secrets.
- Proprietary full model dumps sent to public LLMs without written approval.

## Gateway checklist

- [ ] Authentication.
- [ ] Authorization.
- [ ] Provider allowlist.
- [ ] Redaction.
- [ ] Audit logging.
- [ ] Rate limiting.
- [ ] Cost limits.
- [ ] Data retention policy.
