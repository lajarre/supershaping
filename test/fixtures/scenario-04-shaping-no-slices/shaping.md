# Shaping: Multi-Tenant Auth

## Requirements

- R1: A user authenticated in Tenant A can request a scoped token for Tenant B
  without re-entering credentials, provided they have access.
- R2: Scoped tokens are tenant-isolated — a Tenant B token cannot access Tenant A resources.
- R3: All cross-tenant token exchanges produce a structured audit event.
- R4: Sessions expire independently per tenant context.

## Breadboarded Shapes

### Shape A: Token Exchange Endpoint (server-side proxy)

```
[Client] --POST /auth/exchange {tenant_id}--> [Auth Service]
                                                    |
                                               validate session
                                               check tenant access
                                               mint scoped JWT
                                                    |
                                         <-- {scoped_token}
```

Affordances:
- UI: "Switch org" button → triggers POST /auth/exchange
- Code: TokenExchangeService.exchange(sessionToken, targetTenantId) → ScopedToken

### Shape B: Client-side Token Federation (alternative)

Store multiple tenant tokens in client, refresh on demand.

Affordances:
- UI: Same "Switch org" button
- Code: TokenStore.getOrRefresh(tenantId) → Token

### Recommendation

Shape A preferred: simpler client, audit log is server-authoritative.
