# Security

Passwords are bcrypt hashes; JWT roles gate mutating and privileged routes. All database values are parameterized. API errors intentionally avoid returning PostgreSQL internals. The `.env` file is ignored and no secrets are committed. The payment processor is simulated only; no card numbers or third-party gateway credentials are accepted. Production deployment should add HTTPS, rate limits, refresh-token rotation, TLS database connections, CSP, structured monitoring, backup/restore tests and a dedicated least-privilege PostgreSQL application role.
