---
name: supershaping
description: Route feature work between shaping and superpowers. Assess existing artifacts, recommend shaping-first vs superpowers-direct, bridge slice output into brainstorming.
---

# Supershaping

Route feature work to the right methodology based on what exists and
what's needed.

---

## When to invoke

Use as the **entry point** for any feature work that might involve
shaping, brainstorming, or both. Invoke when:

- Starting a new feature (to decide the approach)
- Resuming feature work (to assess where things stand)
- A cofounder hands off prototype artifacts

Do NOT invoke when:
- You're already mid-shaping or mid-brainstorming (use those skills directly)
- The task is a bugfix, refactor, or chore (no routing needed)

---

## Step 1: Determine feature folder

Ask for the feature slug if not obvious from context. The feature folder is:

```
doc/feature/YYYY-MM-DD-<slug>/
```

Use today's date if creating a new folder.

## Step 2: Assess existing artifacts

Check the feature folder for:

| Artifact | Path | Meaning |
|----------|------|---------|
| PRD | `prd.md` | Full PRD exists (brainstorming already reads this) |
| Frame | `frame.md` | Lightweight PRD (extended Frame from shaping) |
| Shaping doc | `shaping.md` | R, shapes, fit checks, breadboard |
| Slices | `slices.md` | Slice definitions from shaping |
| Prototype | `prototype/` | External UX artifacts (screenshots, routes, components) |
| Spec | `spec.md` or `V1-spec.md, V2-spec.md` | Superpowers spec (already produced) |
| Plan | `plan.md` or `V1-plan.md, V2-plan.md` | Implementation plan (already produced) |

Present a short inventory: "Found: frame.md, shaping.md, slices.md. Missing: spec, plan."

## Step 3: Route

Based on what exists and the user's description:

| Situation | Recommendation | Action |
|-----------|---------------|--------|
| Nothing exists, small/local/clear scope | **Superpowers direct** | Invoke brainstorming skill |
| Nothing exists, large/multi-surface/unclear | **Shaping first** | Invoke shaping skill; suggest starting with Frame |
| `frame.md` exists, no `shaping.md` | **Start shaping** | Frame is done, proceed to R and shapes |
| `shaping.md` exists, no slices yet | **Continue shaping** | Invoke shaping skill to slice the breadboarded shape |
| `slices.md` exists, no spec yet | **Pick slice → brainstorm** | Ask which slice, then invoke brainstorming scoped to that slice |
| `spec.md` (or `V*-spec.md`) exists, no plan | **Write plan** | Invoke writing-plans skill |
| `plan.md` (or `V*-plan.md`) exists | **Execute** | Invoke executing-plans or subagent-driven-development |
| `prototype/` exists, no shaping | **Shape from prototype** | Invoke shaping; prototype feeds the Source section of the Frame |

**In interactive mode:** present the recommendation and let the user decide.
**In autonomous mode:** follow the recommendation.

### Size heuristic

The router doesn't score formally. It uses signals:

- User says "small", "quick", "just add X" → small
- User describes work touching multiple components/pages/services → large
- Feature folder already has shaping artifacts → already shaped
- Prototype folder exists → medium+ (someone invested in UX)
- Uncertainty about solution approach → shaping territory

---

## Prototype intake

When `prototype/` is detected or the user mentions a cofounder handoff:

### Expected structure

```
prototype/
├── screenshots/          — Numbered screen captures
│   ├── 01-landing.png
│   ├── 02-form.png
│   └── 03-confirmation.png
├── routes.md             — Screen list + transitions
├── components.md         — Key components + states
└── copy.md               — UI text (so agents don't reinvent wording)
```

All files are optional. Even just `screenshots/` is useful.

### How it feeds the pipeline

- **Into shaping:** Screenshots and routes become Source material in the
  Frame. Components inform the breadboard. The prototype is input, not spec.
- **Into brainstorming:** When shaping is done, the prototype is reference
  material. Brainstorming can cite specific screens when producing the spec.
- **Screenshots in context:** If the runtime supports image attachments
  (Pi does), reference screenshots directly. Otherwise, describe them.

### Helping the cofounder

If the cofounder's artifacts don't match this structure, help reorganize:
1. Put screenshots in `screenshots/` with numbered filenames
2. Extract a quick route map into `routes.md` (list of screens + transitions)
3. Note key components in `components.md`

This is a 5-minute task, not a ceremony.

---

## Integration with superpowers brainstorming

**Note:** Brainstorming requires superpowers mode to be active (or explicit user request). If routing to brainstorming, either activate superpowers first or invoke brainstorming explicitly.

When routing to brainstorming with shaping artifacts present, the router
**does not** re-invoke shaping. Instead, it invokes brainstorming with
context:

> "Shaping is complete for this feature. The shaping doc at `shaping.md`
> is ground truth for requirements and design decisions. Slices are defined
> in `slices.md`. We're speccing slice [substitute the slice the user selected]. Derive the spec from
> the shaping output — don't re-negotiate settled requirements."

This framing tells brainstorming to **derive** rather than **discover**.

---

## Integration with shaping

When routing to shaping, the router suggests starting with Frame if none
exists:

> "No frame or PRD found. Consider starting with a Frame document
> (`frame.md`) to capture: Source, Problem, Outcome, Metrics, Non-goals,
> Kill criteria. Then proceed to requirements and shapes."

If `prototype/` exists:

> "Prototype artifacts found. Use these as Source material in the Frame.
> Screenshots and routes can inform the breadboard."
