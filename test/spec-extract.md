# Supershaping Skill — Testable Spec

Extracted from `skills/supershaping/SKILL.md`.

---

## S1: Step 1 — Feature folder discovery

- Agent MUST ask for the feature slug (or infer it).
- MUST suggest current branch name as default.
- Folder path pattern: `doc/feature/YYYY-MM-DD-<slug>/`
- MUST confirm with user before proceeding.

> **Testability note:** In non-interactive mode the agent cannot confirm; tests
> supply the path directly in the prompt so the agent can skip confirmation.

---

## S2: Step 2 — Artifact detection

Agent checks for these specific files in the feature folder:

| Artifact | Filename(s) |
|----------|-------------|
| PRD      | `prd.md` |
| Frame    | `frame.md` |
| Shaping  | `shaping.md` |
| Slices   | `slices.md` |
| Spec     | `spec.md` OR `V1-spec.md`, `V2-spec.md` |
| Plan     | `plan.md` OR `V1-plan.md`, `V2-plan.md` |

Agent MUST present an inventory: **"Found: X, Y. Missing: Z."**

---

## S3: Step 3 — Routing decisions

| Situation | Expected route | Expected action |
|-----------|---------------|-----------------|
| Empty folder, small/clear prompt | **Superpowers direct** | Invoke brainstorming |
| Empty folder, large/unclear prompt | **Shaping first** | Suggest starting with Frame |
| `frame.md` only | **Start shaping** | Proceed to requirements + shapes |
| `shaping.md`, no `slices.md` | **Continue shaping** | Slice the breadboarded shape |
| `slices.md` exists, no spec | **Pick slice → brainstorm** | Ask which slice; scope brainstorming to it |
| `spec.md` exists, no `plan.md` | **Write plan** | Invoke writing-plans skill |
| `plan.md` exists | **Execute** | Invoke executing-plans or subagent-driven-development |
| External UX artifacts (screenshots/mockups) + no shaping | **Shaping first** | Treat artifacts as Source material for Frame |

---

## S4: Size heuristic signals

Agent MUST infer scope from prompt language:

| Signal words / patterns | Inferred size |
|------------------------|---------------|
| "small", "quick", "just add X" | small → superpowers direct |
| Multiple components, pages, services | large → shaping first |
| Shaping artifacts already exist | already shaped |
| External UX artifacts (mockups, screenshots, route maps) | medium+ |
| Uncertain solution space | shaping territory |

---

## S5: Bridging to brainstorming (slices exist)

When `slices.md` exists and routing to brainstorming, agent MUST frame it as:

> "Shaping is complete. `shaping.md` is ground truth for requirements.
> Slices in `slices.md`. We're speccing slice [user's choice]. Derive
> the spec — don't re-negotiate settled requirements."

**Key testable phrases:**
- "ground truth" (or equivalent: shaping doc is authoritative)
- "derive" (spec derives FROM shaping, not re-discovered)
- "don't re-negotiate" OR "settled requirements" (no reopening settled decisions)

---

## S6: Bridging to shaping (no frame/PRD)

When no frame or PRD exists and routing to shaping, agent MUST suggest:

> "Start with `frame.md`: Source, Problem, Outcome, Metrics, Non-goals, Kill criteria."

**Key testable phrases:**
- "frame.md" (or "Frame")
- "Source, Problem, Outcome" OR at least two of those sections
- If external UX artifacts present: "Source material" reference

---

## S7: Common mistakes to avoid

| Mistake | Expected behavior instead |
|---------|--------------------------|
| Re-brainstorm requirements shaping already settled | Derive from shaping doc, do NOT re-negotiate |
| Shape a small/obvious change | Go direct to superpowers — skip shaping |
| Skip Frame for large features | Insist on Frame first |
| Treat external UX artifacts as final spec | Treat them as input to shaping / Source material |

---

## Summary of testable assertions per scenario

| Scenario | Key assertion |
|----------|---------------|
| Empty + small | Routes superpowers/brainstorming, NOT shaping |
| Empty + large | Routes shaping/frame, NOT direct brainstorming |
| frame.md only | Routes to start shaping (requirements + shapes) |
| shaping.md, no slices | Routes to slicing the breadboarded shape |
| slices.md, no spec | Routes to pick slice + brainstorm; uses derive framing |
| spec.md, no plan | Routes to writing a plan |
| plan.md exists | Routes to execution |
| External UX artifacts | Routes shaping, treats artifacts as Source material |
