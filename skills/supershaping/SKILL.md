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
| Prototype | `prototype/` |
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
| `prototype/`, no shaping | **Shape from prototype** | Prototype feeds Frame's Source section |

Interactive: present recommendation, let user decide.
Autonomous: follow recommendation.

### Size signals

- "small", "quick", "just add X" → small
- Multiple components/pages/services → large
- Shaping artifacts exist → already shaped
- `prototype/` exists → medium+
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

If `prototype/` exists, add: "Use prototype as Source material in the Frame."

---

## Prototype intake

Expected structure (all files optional):

```
prototype/
├── screenshots/     — Numbered screen captures
├── routes.md        — Screen list + transitions
├── components.md    — Key components + states
└── copy.md          — UI text
```

- Into shaping: screenshots/routes become Frame Source material
- Into brainstorming: reference material for spec writing
- If artifacts don't match this structure, help reorganize (5 min task)

---

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Re-brainstorming requirements shaping already settled | Derive from shaping doc, don't re-negotiate |
| Shaping a small/obvious change | Go direct to superpowers — shaping is overhead here |
| Skipping Frame for large features | Frame captures why/metrics/kill criteria — prevents scope drift |
| Treating prototype as spec | Prototype is input to shaping, not the solution |
