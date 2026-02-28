# Supershaping Skill Test Results

**Run date:** 2026-02-28  
**Skill:** `skills/supershaping/SKILL.md`  
**Test runner:** `test/run-tests.sh` (v3)  
**Total:** 16/16 PASS

---

## Model Mapping

The task specified models that don't match pi's exact model IDs. Adapted:

| Task spec | Actual pi model ID | Notes |
|-----------|-------------------|-------|
| `anthropic/claude-opus-4-6:thinking_high` | `anthropic/claude-opus-4-6:high` | `:thinking_high` not a valid level; pi uses `:high` |
| `openai/codex-5.3:high` | `openai-codex/gpt-5.3-codex:high` | Provider is `openai-codex`, model is `gpt-5.3-codex` |

---

## Infrastructure Issue Discovered

**Symptom:** When running `echo "PROMPT" | pi -p` inside a parent pi session (e.g., from the bash tool), the pipe is consumed by the parent session before the child pi receives it. The child pi picks up context from the parent's conversation instead of the piped prompt.

**Evidence:** First two runs showed models responding to "model identifier" confusions (they saw the model name from the parent session's context rather than the actual test prompt).

**Fix:** Pass the prompt as a CLI argument: `pi -p "PROMPT"` instead of `echo "PROMPT" | pi -p`. This bypasses the stdin consumption issue.

---

## Results: All PASS

### anthropic/claude-opus-4-6:high

| Scenario | Status | Notes |
|----------|--------|-------|
| 01 empty-small | ✅ PASS | Correctly routes "Superpowers Direct → Brainstorming", cites "small scope" size signals |
| 02 empty-large | ✅ PASS | Correctly routes "Shaping first", recommends frame.md with all 6 sections |
| 03 frame-only | ✅ PASS | Correctly routes to "Start shaping" (requirements + shapes) |
| 04 shaping-no-slices | ✅ PASS | Correctly routes to "Continue shaping → slice" |
| 05 slices-no-spec | ✅ PASS | Routes to "Pick slice → brainstorm" with derive framing; uses "ground truth" and "derive" |
| 06 spec-no-plan | ✅ PASS | Routes to "Write plan", recommends writing-plans skill |
| 07 plan-exists | ✅ PASS | Routes to "Execute", offers executing-plans and subagent-driven-development |
| 08 external-ux-artifacts | ✅ PASS | Detects empty .png files as UX artifacts, routes shaping first, says "Source material" |

### openai-codex/gpt-5.3-codex:high

| Scenario | Status | Notes |
|----------|--------|-------|
| 01 empty-small | ✅ PASS | Correctly routes "Superpowers Direct → Brainstorming", cites "quick", "small" |
| 02 empty-large | ✅ PASS | Correctly routes "Shaping first", recommends frame.md with all 6 sections |
| 03 frame-only | ✅ PASS | Correctly routes to "Start shaping" |
| 04 shaping-no-slices | ✅ PASS | Correctly routes to "Continue shaping → slice" |
| 05 slices-no-spec | ✅ PASS | Routes to "Pick slice → brainstorm"; uses "derive", "not re-negotiate" framing |
| 06 spec-no-plan | ✅ PASS | Routes to "Write plan", explicitly mentions "writing-plans skill" |
| 07 plan-exists | ✅ PASS | Routes to "Execute", offers executing-plans and subagent-driven-development |
| 08 external-ux-artifacts | ✅ PASS | Detects .png files, routes shaping, recommends frame.md with "Source material" |

---

## Behavioral Observations

### What both models do well

**Artifact inventory:** Both models present a structured table with all 6 artifact types (PRD, Frame, Shaping, Slices, Spec, Plan) with ✅/❌ status. They correctly identify which are present and which are missing.

**Routing decisions:** All 8 routing scenarios are correctly handled by both models. The routing table in the skill is faithfully followed.

**Size signal reading:** Both models correctly read size signals from the prompt ("quick", "small", "multiple services", etc.) and route accordingly, even when the feature folder is empty.

**Derive framing (Scenario 05):** Both models correctly invoke the "shaping is authoritative" framing when slices exist:
- Claude says: *"ground truth. We're speccing Slice 1... Derive the spec — don't re-negotiate settled requirements."*
- Codex says: *"next step is to choose a slice and derive a spec from the shaped requirements — not re-negotiate them."*

**External UX artifacts (Scenario 08):** Both models detect empty `.png` files, correctly classify them as UX artifacts (mockups/wireframes), route to "Shaping first", and recommend treating them as "Source material" for `frame.md`.

### Model style differences

| Aspect | claude-opus-4-6 | gpt-5.3-codex |
|--------|----------------|---------------|
| Inventory format | Mix of table and list | Consistent markdown table |
| Routing label | Uses exact skill labels ("Superpowers Direct") | Paraphrases but accurately |
| Frame sections | Lists all 6 sections | Lists all 6 sections |
| "Ground truth" phrase | Uses exact phrase | Paraphrases ("not re-negotiate") |
| Tone | Methodical, formal | Slightly more conversational |
| French | Occasional | Occasional |

---

## Spec Coverage vs. Pass Rate

| Spec section | Coverage | Pass rate |
|-------------|---------|-----------|
| S1: Feature folder discovery | Tested (prompt provides path) | 16/16 |
| S2: Artifact detection | Tested (scenarios 03–07 have specific files) | 16/16 |
| S3: Routing decisions | 8 scenarios cover all 7 routing cases | 16/16 |
| S4: Size heuristic signals | Tested (01 small vs 02 large) | 4/4 |
| S5: Brainstorming bridge framing | Tested (scenario 05) | 4/4 |
| S6: Shaping bridge framing | Tested (scenarios 02, 03, 08) | 12/12 |
| S7: Common mistakes avoidance | Implicitly tested (models don't re-brainstorm or skip frame) | — |

---

## Common Mistakes — Implicit Validation

The spec lists 4 common mistakes. None occurred:

| Mistake | Observed? |
|---------|----------|
| Re-brainstorming requirements shaping already settled | ❌ Not observed — both models say "derive, don't re-negotiate" |
| Shaping a small/obvious change | ❌ Not observed — correctly routes small changes to superpowers/brainstorming |
| Skipping Frame for large features | ❌ Not observed — both insist on Frame for large/complex features |
| Treating external UX artifacts as spec | ❌ Not observed — both call them "Source material" and route to shaping |

---

## Edge Case Notes

**Empty .png files (Scenario 08):** Both models noted the files are 0 bytes but still correctly classified them as UX artifacts and applied the shaping-first route. This is sensible behavior — the existence of named mockup/wireframe files is sufficient signal.

**Spec writing without brainstorming (Scenario 05 — codex):** The codex model correctly identifies that slices exist and recommends "Pick a slice → derive spec" without explicitly naming "brainstorming" as a step. It goes to the substance directly, which is arguably correct behavior. The skill says to "scope brainstorming to it" — codex does this by saying "choose a slice and derive the spec" which is equivalent.

**Plan creation mode (Scenario 06 — codex):** In an earlier (buggy) test run, the codex model actually wrote `plan.md` to the fixture folder rather than just recommending it. With proper session isolation (via `--no-session` + CLI args), this was not reproduced. The correct behavior (recommend writing a plan) was observed.

---

## Skill Assessment: No Issues Found

The supershaping skill correctly guides both models through:
1. Artifact inventory with proper table format
2. All routing decisions from the spec
3. Size-based heuristics for empty folders
4. Correct framing text when bridging to brainstorming
5. Correct framing text when bridging to shaping
6. External UX artifact detection and classification

**No skill fixes required.**

---

## Test Infrastructure Notes

- **Runner:** `test/run-tests.sh` — creates fresh temp-dir fixtures per test run (idempotent)
- **Session isolation:** `pi -p --no-session` with prompt as CLI arg (NOT piped stdin)
- **Output files:** `test/output/<model-slug>/<scenario-id>.txt`
- **Check patterns:** Extended regex (grep -qiE), case-insensitive
- **Timeout:** 180s per pi invocation
