# Implementation Plan: Token Exchange Endpoint

## Phase 1: Core service (Day 1)
- [ ] Create `TokenExchangeService` class in `src/auth/`
- [ ] Implement `exchange(sessionToken, targetTenantId)` method
- [ ] Add tenant membership lookup via `TenantMembershipRepository`
- [ ] Mint scoped JWT with correct claims

## Phase 2: HTTP endpoint (Day 1)
- [ ] Add `POST /auth/exchange` route in `src/routes/auth.ts`
- [ ] Wire request validation middleware
- [ ] Map service errors to HTTP status codes (401, 403, 404)

## Phase 3: Audit log (Day 2)
- [ ] Emit `token_exchange` audit event on successful exchange
- [ ] Wire to `AuditEventService`

## Phase 4: Tests (Day 2)
- [ ] Unit: `TokenExchangeService` — valid exchange, invalid session, no access
- [ ] Integration: `POST /auth/exchange` happy path + error cases
- [ ] Integration: audit event emitted on success

## Done definition
All tests green. Endpoint documented in OpenAPI spec. Reviewed.
