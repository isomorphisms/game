# PBS KIDS game reference analysis

This folder is a design/programming reference for the children's games in this repository. It is not an attempt to copy PBS KIDS artwork or code.

## Method

Each game note distinguishes three kinds of claims:

- **Observed** — visible in a saved reference image/frame.
- **Documented** — stated by PBS KIDS/PBS KIDS for Parents or the credited game's designer.
- **Inferred** — a plausible implementation model that explains the observed behavior. Inferred names, callbacks and data structures are not claims about PBS source code.

I could not execute the live game canvas in this environment, so the implementation sections are reverse-engineered from observed screens, official game descriptions and official gameplay material rather than source-code inspection.

## Games sampled

1. `molly-of-denali/` — Molly's Winter Kitchen, plus one Explore with Molly reference frame. Strong example of hub → activity → focused manipulation scenes.
2. `lyla-hairdos/` — Lyla and Stu's Hairdos. Closest reference for a salon: a multi-stage visible transformation that survives from step to step.
3. `sesame-dress-up-time/` — Dress Up Time. Small target-outfit / clothing-selection loop.
4. `wild-kratts/` — Monkey Mayhem plus Creature Mobile notes. Contrasting example for real-time movement, counters and pre-game configuration.

See `patterns.md` for the reusable architecture.

## Copyright / provenance

Reference images remain the property of their respective owners and are kept here only as reduced-size design-analysis references. Every per-game note records its source. Do not ship them as game assets.
