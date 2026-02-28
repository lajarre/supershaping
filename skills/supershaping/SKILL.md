---
name: supershaping
description: Use when starting or resuming feature work that may involve shaping, brainstorming, or both — determines the right methodology based on existing artifacts in the feature folder.
---

# Supershaping

Entry point for feature work. Checks what artifacts exist, recommends
shaping-first vs superpowers-direct vs pick-a-slice.

---

## Step 1: Determine feature folder

Ask for the feature slug (suggest current branch name as default).

```
doc/feature/YYYY-MM-DD-<slug>/
```

**Confirm with user before proceeding:** "Feature folder: `doc/feature/2026-02-27-<slug>/` — correct?"

## Step 2: Assess artifacts

Check the feature folder:

| Artifact | Path |
|----------|------|
| PRD | `prd.md` |
| Frame | `frame.md` |
| Shaping doc | `shaping.md` |
| Slices | `slices.md` |
| Spec | `spec.md` or `V1-spec.md, V2-spec.md` |
| Plan | `plan.md` or `V1-plan.md, V2-plan.md` |

Present inventory: "Found: X, Y. Missing: Z."

## Step 3: Route

| Situation | Route | Action |
|-----------|-------|--------|
| Nothing, small/clear scope | **Superpowers direct** | Invoke brainstorming |
| Nothing, large/unclear | **Shaping first** | Start with Frame |
| `frame.md` only | **Start shaping** | Proceed to R and shapes |
| `shaping.md`, no slices | **Continue shaping** | Slice the breadboarded shape |
| `slices.md`, no spec | **Pick slice → brainstorm** | Ask which slice, scope brainstorming to it |
| Spec exists, no plan | **Write plan** | Invoke writing-plans |
| Plan exists | **Execute** | Invoke executing-plans or subagent-driven-development |
| External UX artifacts exist (screenshots, mockups, route maps), no shaping | **Shaping first** | Treat as Source material for the Frame |

**Present the recommendation and wait.** Do NOT invoke the downstream skill
yourself — the user decides when to proceed. Your job is routing, not execution.

Exception: in autonomous mode, follow the recommendation directly.

### Size signals

- "small", "quick", "just add X" → small
- Multiple components/pages/services → large
- Shaping artifacts exist → already shaped
- External UX artifacts exist (mockups, screenshots) → medium+
- Uncertain solution → shaping territory

---

## Bridging to brainstorming

**Note:** Brainstorming requires superpowers mode active or explicit request.

When slices exist, invoke brainstorming with this framing:

> "Shaping is complete. `shaping.md` is ground truth for requirements.
> Slices in `slices.md`. We're speccing slice [user's choice]. Derive
> the spec — don't re-negotiate settled requirements."

This tells brainstorming to **derive** not **discover**.

## Bridging to shaping

When no frame or PRD exists, suggest:

> "Start with `frame.md`: Source, Problem, Outcome, Metrics, Non-goals,
> Kill criteria. Then proceed to requirements and shapes."

If external UX artifacts exist (screenshots, mockups, route maps), add:
"Use these as Source material in the Frame."

---

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Re-brainstorming requirements shaping already settled | Derive from shaping doc, don't re-negotiate |
| Shaping a small/obvious change | Go direct to superpowers — shaping is overhead here |
| Skipping Frame for large features | Frame captures why/metrics/kill criteria — prevents scope drift |
| Treating external UX artifacts as spec | External artifacts are input to shaping, not the solution |
