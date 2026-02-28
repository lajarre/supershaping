# Feature Frame: Multi-Tenant Auth

## Source
Customer feedback: enterprise customers need to switch between accounts without re-authenticating.
Internal metric: 34% of churn correlated with session friction.

## Problem
Users with access to multiple tenant accounts must log out and log back in to switch.
This creates friction, especially for power users managing several organizations.

## Outcome
Single authenticated session lets users switch tenant context without re-auth.

## Metrics
- Cross-tenant context switch success rate ≥ 99.5%
- Context switch latency < 200ms p99
- Session complaint tickets reduced by 80%

## Non-goals
- Custom branding per tenant (separate initiative)
- Mobile biometrics (roadmap item, not this cycle)
- Full federation/SSO with external IdPs (follow-on)

## Kill criteria
If cross-tenant switch adoption < 15% after 60 days, revisit the UX approach
before investing in SSO.
