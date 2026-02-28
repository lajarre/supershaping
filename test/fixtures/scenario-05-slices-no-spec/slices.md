# Slices: Multi-Tenant Auth

## Slice 1: Token Exchange Endpoint
`POST /auth/exchange` — accepts current session token + target tenant ID,
validates access, mints and returns a scoped JWT.

Testable in isolation: standalone HTTP endpoint, no UI required.

## Slice 2: Cross-Tenant Middleware
Request middleware that validates scoped tokens and populates the request
context with the active tenant ID.

Depends on: Slice 1 (needs scoped token format defined).

## Slice 3: Audit Log Emission
Emit a structured audit event on every token exchange.

Depends on: Slice 1 (event triggered at exchange time).

## Slice 4: "Switch Org" UI
Dropdown in the nav bar to select a tenant context, triggers the exchange
flow and refreshes the page with new scoped token.

Depends on: Slices 1 + 2.
