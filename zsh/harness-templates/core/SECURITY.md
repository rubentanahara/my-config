# Security

## Secrets
- Never commit secrets, tokens, or `.env` files. `.husky/pre-commit` runs gitleaks.
- Secrets come from:

## Trust Boundaries
- Untrusted input enters at:
- Validation happens at:

## Agent Permissions
- Allowed without asking: see `permissions.allow` in `.claude/settings.json`
- Requires human approval: new dependencies, schema or public API changes, destructive commands
- Forbidden: push to `main`, force-push, reading `.env`

## Dependencies
- Check current docs and maintenance status before adding one.

## Reporting
- Report a vulnerability to:
