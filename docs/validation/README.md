# Validation Evidence

This folder contains templates for recording validation evidence for this Revit AI-powered plugin template.

Do not store fabricated validation results here. Evidence files should describe commands actually executed, the machine used, the exact commit tested, and any known limitations.

## Public Beta

Use `public-beta/` for Public Beta readiness runs:

- `public-beta/VALIDATION_TEMPLATE.md`: copy this file for each real validation run.
- `public-beta/*.example.md`: examples for individual evidence sections.

Recommended evidence folder for a real run:

```txt
docs/validation/public-beta/runs/<yyyy-mm-dd>-<short-sha>/
```

Keep generated logs concise. If large raw logs are needed, store them under ignored `artifacts/` and summarize the results in the validation record.
