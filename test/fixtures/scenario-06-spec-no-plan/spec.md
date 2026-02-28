# Spec: Slice 1 — Token Exchange Endpoint

## Endpoint
`POST /auth/exchange`

## Request body
```json
{
  "target_tenant_id": "uuid"
}
```
Auth header: `Authorization: Bearer <current-session-token>`

## Success response (200)
```json
{
  "scoped_token": "eyJ...",
  "expires_at": "ISO-8601"
}
```

## Error responses
- 401: session token invalid or expired
- 403: user does not have access to target tenant
- 404: target tenant does not exist

## Validation rules
1. Session token must be a valid, non-expired JWT signed by this service.
2. `target_tenant_id` must be a valid UUID.
3. A TenantMembership record must exist for (user_id, target_tenant_id).

## Scoped token claims
```json
{
  "sub": "<user_id>",
  "tenant_id": "<target_tenant_id>",
  "exp": "<now + 1h>",
  "scope": "tenant"
}
```

## Audit event
On success, emit:
```json
{
  "event": "token_exchange",
  "user_id": "...",
  "source_tenant_id": "...",
  "target_tenant_id": "...",
  "timestamp": "ISO-8601"
}
```
