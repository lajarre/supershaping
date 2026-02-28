# supershaping

Route feature work between [shaping-skills](https://github.com/rjs/shaping-skills) and [superpowers](https://github.com/obra/superpowers) — assess what exists, decide whether to shape first or go direct, bridge slices into specs.

## Install

```bash
pi install git:github.com/lajarre/supershaping
```

## What it does

When you start feature work, supershaping checks your feature folder for existing artifacts (frame, shaping doc, slices, specs, plans) and recommends the right path:

| Situation | Route |
|-----------|-------|
| Nothing exists, small scope | → Superpowers brainstorming directly |
| Nothing exists, large/unclear scope | → Shaping first (start with Frame) |
| Shaping done, slices defined | → Pick a slice, then brainstorm scoped to it |
| Spec exists | → Write implementation plan |
| Plan exists | → Execute |

The key integration: when shaping produces slices, supershaping tells brainstorming to **derive** the spec from shaped artifacts instead of re-brainstorming from scratch.

## Companion patches

Supershaping works best with two small patches to sibling skill systems:

**Brainstorming** (superpowers) — ~6 lines that teach brainstorming to read `shaping.md`/`slices.md` and scope to a single slice. See [the patch](https://github.com/lajarre/superpowers/commit/4491c35).

**Frame extension** (shaping-skills) — extends the Frame document with Metrics, Non-goals, and Kill criteria, making it serve as a lightweight PRD. See [the patch](https://github.com/lajarre/shaping-skills/tree/feat/supershaping).

## External UX artifacts

If external UX artifacts exist (screenshots, mockups, route maps), supershaping treats them as Source material for shaping's Frame document.

## Prerequisites

- [Pi](https://github.com/mariozechner/pi) coding agent
- [shaping-skills](https://github.com/rjs/shaping-skills) for the shaping methodology
- [superpowers](https://github.com/obra/superpowers) for brainstorming/planning/execution

## License

MIT
