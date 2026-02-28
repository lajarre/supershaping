# Shaping: Multi-Tenant Auth

## Requirements

- R1: User in Tenant A can request scoped token for Tenant B without re-auth.
- R2: Scoped tokens are tenant-isolated.
- R3: All token exchanges produce audit events.
- R4: Sessions expire independently per tenant context.

## Shape: Token Exchange Endpoint

```
[Client] --POST /auth/exchange {tenant_id}--> [Auth Service]
                                                    |
                                               validate session
                                               check tenant access
                                               mint scoped JWT
                                                    |
                                         <-- {scoped_token}
```
