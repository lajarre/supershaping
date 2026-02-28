#!/usr/bin/env bash
# Supershaping skill test runner — v3
#
# KEY INSIGHT: When running inside a pi session, piped stdin (`echo X | pi -p`) gets
# consumed by the parent session before reaching child pi. Pass the prompt as a CLI
# arg instead: `pi -p "PROMPT"`.
#
# Creates fresh fixture dirs per test run — idempotent, no stale state.
#
# Usage: bash run-tests.sh [scenario-id]
#   optional: pass a scenario id (e.g. "01") to run only that scenario

set -uo pipefail

SKILL_PATH="/Users/alex/workspace/aidev/supershaping/skills/supershaping"
OUTPUT_DIR="/Users/alex/workspace/aidev/supershaping/test/output"
TIMEOUT=180  # seconds per pi invocation

# Note: task specified "anthropic/claude-opus-4-6:thinking_high" and "openai/codex-5.3:high"
# Adapted to valid pi model IDs (from `pi --list-models`):
#   :thinking_high → :high  (pi levels: off, minimal, low, medium, high, xhigh)
#   openai/codex-5.3 → openai-codex/gpt-5.3-codex
MODELS=(
  "anthropic/claude-opus-4-6:high"
  "openai-codex/gpt-5.3-codex:high"
)

ONLY_SCENARIO="${1:-}"

mkdir -p "$OUTPUT_DIR"

PASS=0
FAIL=0

RESULTS_CSV="$OUTPUT_DIR/results-v3.csv"
echo "status,scenario_id,scenario_name,model,failed_checks" > "$RESULTS_CSV"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

check() {
  local file="$1"
  local pattern="$2"
  grep -qiE "$pattern" "$file"
}

# Write a file into a directory
wf() {
  local dir="$1"
  local name="$2"
  local content="$3"
  printf '%s' "$content" > "$dir/$name"
}

run_test() {
  local scenario_id="$1"
  local scenario_name="$2"
  local model="$3"
  local fixture_dir="$4"
  local prompt="$5"
  # Remaining args: check_name check_pattern pairs
  local checks=("${@:6}")

  if [[ -n "$ONLY_SCENARIO" && "$scenario_id" != "$ONLY_SCENARIO" ]]; then
    return
  fi

  local model_slug
  model_slug=$(echo "$model" | tr '/: ' '---')
  local out_dir="$OUTPUT_DIR/$model_slug"
  mkdir -p "$out_dir"
  local out_file="$out_dir/${scenario_id}.txt"

  echo ""
  echo "════════════════════════════════════════════════"
  echo "  Scenario $scenario_id: $scenario_name"
  echo "  Model: $model"
  echo "════════════════════════════════════════════════"

  # Pass prompt as CLI arg (NOT via pipe) — piped stdin is consumed by parent pi session.
  # --no-session: ephemeral session, no context from prior runs.
  local pi_exit=0
  if ! timeout "$TIMEOUT" pi -p --no-session \
      -m "$model" \
      --skill "$SKILL_PATH" \
      "$prompt" \
      > "$out_file" 2>&1; then
    pi_exit=$?
    echo "  ⚠  pi exited with code $pi_exit"
  fi

  if [[ ! -s "$out_file" ]]; then
    echo "  ✗ FAIL — empty output"
    FAIL=$((FAIL+1))
    echo "FAIL,\"$scenario_id\",\"$scenario_name\",\"$model\",\"empty output\"" >> "$RESULTS_CSV"
    return
  fi

  # Evaluate checks
  local all_pass=true
  local failed_names=()

  local i=0
  while [[ $i -lt ${#checks[@]} ]]; do
    local check_name="${checks[$i]}"
    local check_pattern="${checks[$((i+1))]}"
    i=$((i+2))
    if ! check "$out_file" "$check_pattern"; then
      all_pass=false
      failed_names+=("[$check_name]")
    fi
  done

  if $all_pass; then
    echo "  ✓ PASS"
    PASS=$((PASS+1))
    echo "PASS,\"$scenario_id\",\"$scenario_name\",\"$model\",\"\"" >> "$RESULTS_CSV"
  else
    echo "  ✗ FAIL — missing: ${failed_names[*]}"
    FAIL=$((FAIL+1))
    local failed_str
    failed_str=$(printf '%s; ' "${failed_names[@]}")
    echo "FAIL,\"$scenario_id\",\"$scenario_name\",\"$model\",\"${failed_str}\"" >> "$RESULTS_CSV"
    echo ""
    echo "  --- First 35 lines of output ---"
    head -35 "$out_file" | sed 's/^/  | /'
  fi
}

# ---------------------------------------------------------------------------
# Shared fixture content
# ---------------------------------------------------------------------------

FRAME_CONTENT='# Feature Frame: Multi-Tenant Auth

## Source
Customer feedback: enterprise customers need to switch between accounts without re-authenticating.
Internal metric: 34% of churn correlated with session friction.

## Problem
Users with access to multiple tenant accounts must log out and log back in to switch.

## Outcome
Single authenticated session lets users switch tenant context without re-auth.

## Metrics
- Cross-tenant context switch success rate >= 99.5%
- Context switch latency < 200ms p99

## Non-goals
- Custom branding per tenant (separate initiative)
- Mobile biometrics

## Kill criteria
If cross-tenant switch adoption < 15% after 60 days, revisit the UX approach.
'

SHAPING_CONTENT='# Shaping: Multi-Tenant Auth

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
'

SLICES_CONTENT='# Slices: Multi-Tenant Auth

## Slice 1: Token Exchange Endpoint
POST /auth/exchange — accepts current session token + target tenant ID,
validates access, mints and returns a scoped JWT.
Testable in isolation: standalone HTTP endpoint, no UI required.

## Slice 2: Cross-Tenant Middleware
Validates scoped tokens and populates request context with active tenant ID.

## Slice 3: Audit Log Emission
Emit a structured audit event on every token exchange.

## Slice 4: Switch Org UI
Dropdown in nav bar to trigger the exchange flow.
'

SPEC_CONTENT='# Spec: Slice 1 — Token Exchange Endpoint

## Endpoint
POST /auth/exchange

## Request
Auth header: Authorization: Bearer <current-session-token>
Body: { "target_tenant_id": "uuid" }

## Success (200)
{ "scoped_token": "eyJ...", "expires_at": "ISO-8601" }

## Errors
- 401: session token invalid or expired
- 403: user does not have access to target tenant
- 404: target tenant does not exist
'

PLAN_CONTENT='# Implementation Plan: Token Exchange Endpoint

## Phase 1: Core service
- [ ] Create TokenExchangeService class
- [ ] Implement exchange(sessionToken, targetTenantId) method
- [ ] Mint scoped JWT with correct claims

## Phase 2: HTTP endpoint
- [ ] Add POST /auth/exchange route
- [ ] Wire request validation middleware

## Phase 3: Tests
- [ ] Unit: TokenExchangeService
- [ ] Integration: POST /auth/exchange happy path + error cases
'

# ---------------------------------------------------------------------------
# Test scenarios
# ---------------------------------------------------------------------------

for MODEL in "${MODELS[@]}"; do

  # ── Scenario 01: Empty folder + small/clear scope ──────────────────────
  # Expected route: Superpowers direct → brainstorming (NOT shaping first)
  # Size signals in prompt: "quick", "small"
  FX01=$(mktemp -d)
  # (intentionally empty — no files)
  run_test "01" "empty-small" "$MODEL" "$FX01" \
    "I want to add a quick tooltip to the user menu button showing the user's name. Small UI change, nothing complex. Feature folder: $FX01. Check what artifacts exist there and recommend the next step using the supershaping skill." \
    "routes to brainstorming" "brainstorm" \
    "acknowledges small/quick/direct scope" "small|quick|direct|superpowers"

  # ── Scenario 02: Empty folder + large/unclear scope ────────────────────
  # Expected route: Shaping first → suggest starting with Frame
  # Size signals: multiple services, complex, many components
  FX02=$(mktemp -d)
  # (intentionally empty — no files)
  run_test "02" "empty-large" "$MODEL" "$FX02" \
    "I need to design and build a full multi-tenant authentication system with SSO, RBAC, audit logging, and integrations across API gateway, auth service, and multiple frontend clients. Touches many services. Feature folder: $FX02. Check what artifacts exist there and recommend the next step using the supershaping skill." \
    "routes to shaping or frame" "shap|frame" \
    "mentions Frame document or shaping first" "frame|shaping.first|start.with.frame"

  # ── Scenario 03: frame.md only ─────────────────────────────────────────
  # Expected route: Start shaping → proceed to requirements + shapes
  FX03=$(mktemp -d)
  wf "$FX03" "frame.md" "$FRAME_CONTENT"
  run_test "03" "frame-only" "$MODEL" "$FX03" \
    "Continuing work on the multi-tenant auth feature. Feature folder: $FX03. Check what artifacts exist there and recommend the next step using the supershaping skill." \
    "routes to shaping/requirements/shapes" "shap|requirement|breadboard|shape"

  # ── Scenario 04: shaping.md, no slices ────────────────────────────────
  # Expected route: Continue shaping → slice the breadboarded shape
  FX04=$(mktemp -d)
  wf "$FX04" "shaping.md" "$SHAPING_CONTENT"
  run_test "04" "shaping-no-slices" "$MODEL" "$FX04" \
    "Continuing work on the multi-tenant auth feature. Feature folder: $FX04. Check what artifacts exist there and recommend the next step using the supershaping skill." \
    "routes to slicing" "slice"

  # ── Scenario 05: slices.md exists, no spec ────────────────────────────
  # Expected route: Pick slice → brainstorm with derive framing
  # Key: agent must use "derive"/"ground truth" framing from S5 in spec
  FX05=$(mktemp -d)
  wf "$FX05" "shaping.md" "$SHAPING_CONTENT"
  wf "$FX05" "slices.md" "$SLICES_CONTENT"
  run_test "05" "slices-no-spec" "$MODEL" "$FX05" \
    "Continuing work on the multi-tenant auth feature. Feature folder: $FX05. Check what artifacts exist there and recommend the next step using the supershaping skill." \
    "routes to slice/spec/brainstorm phase" "slice" \
    "engages with spec or brainstorm" "brainstorm|spec|derive" \
    "uses derive/ground-truth framing" "ground.truth|derive|don.t re-?negotiat|settled"

  # ── Scenario 06: spec.md exists, no plan ──────────────────────────────
  # Expected route: Write plan → invoke writing-plans
  FX06=$(mktemp -d)
  wf "$FX06" "spec.md" "$SPEC_CONTENT"
  run_test "06" "spec-no-plan" "$MODEL" "$FX06" \
    "Continuing work on the multi-tenant auth feature. Feature folder: $FX06. Check what artifacts exist there and recommend the next step using the supershaping skill." \
    "engages with plan creation" "plan"

  # ── Scenario 07: plan.md exists ───────────────────────────────────────
  # Expected route: Execute → executing-plans or subagent-driven-development
  FX07=$(mktemp -d)
  wf "$FX07" "spec.md" "$SPEC_CONTENT"
  wf "$FX07" "plan.md" "$PLAN_CONTENT"
  run_test "07" "plan-exists" "$MODEL" "$FX07" \
    "Continuing work on the multi-tenant auth feature. Feature folder: $FX07. Check what artifacts exist there and recommend the next step using the supershaping skill." \
    "routes to execution" "execut|implement|subagent|dispatch|proceed.with"

  # ── Scenario 08: External UX artifacts (mockups/screenshots) ──────────
  # Expected route: Shaping first → treat mockups as Source material for Frame
  FX08=$(mktemp -d)
  touch "$FX08/mockup.png"
  touch "$FX08/nav-wireframe.png"
  run_test "08" "external-ux-artifacts" "$MODEL" "$FX08" \
    "I have some UI mockups for a new feature. Feature folder: $FX08. Check what artifacts exist there (including any image files) and recommend the next step using the supershaping skill." \
    "routes to shaping" "shap" \
    "treats mockups as source material or mentions frame" "source.material|source material|frame|input.to.shap|material for|as.source"

done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

TOTAL=$((PASS+FAIL))
echo ""
echo "════════════════════════════════════════════════"
echo "  RESULTS: $PASS/$TOTAL passed, $FAIL failed"
echo "════════════════════════════════════════════════"
echo ""
echo "Model adaption note:"
echo "  'anthropic/claude-opus-4-6:thinking_high' → anthropic/claude-opus-4-6:high"
echo "  'openai/codex-5.3:high' → openai-codex/gpt-5.3-codex:high"
echo ""
cat "$RESULTS_CSV"
