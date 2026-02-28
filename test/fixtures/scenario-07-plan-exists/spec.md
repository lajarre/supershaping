# Spec: Slice 1 — Token Exchange Endpoint

## Endpoint
`POST /auth/exchange`

Auth header: `Authorization: Bearer <current-session-token>`
Body: `{ "target_tenant_id": "uuid" }`

Success (200): `{ "scoped_token": "eyJ...", "expires_at": "ISO-8601" }`
