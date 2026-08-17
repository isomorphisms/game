# Dress the Unicorn

A tap-driven 2D animal salon game built with Godot 4.7.

The game designer's decisions live in `GAME_IDEA.md` and `GAME_SPEC.md`. The player-facing build is now graphical rather than a text rendering of internal state. A disabled `DEBUG_UI` flag in `scripts/main.gd` keeps the old kind of state summary available for debugging.

## Current graphical prototype

- Illustrated waiting room with a zebra, horse, and two visibly different unicorns.
- The selected animal remains on screen throughout the salon, dress-up, snack, and photo flows.
- Original in-project vector drawing code for animals, rooms, action icons, clothing, food, and drinks; no PBS KIDS artwork is copied or redistributed.
- Tap controls only; no drag interactions.
- Three fitted clothing looks plus no-outfit; the dresses are layered over and cover the torso/body instead of floating beside it.
- Three visible hair treatments and three visible makeup treatments as provisional art choices.
- Zebra unicorn costume, wings, gold horn, and rainbow horn graphics.
- Unicorns visibly become messy when they relax and can be redone.
- Every currently specified snack and drink has an illustrated tappable card.
- Visual photo room with end-of-session screenshot capture to app storage.

The precise final hairstyles, makeup set, and relaxing activity remain open design questions. The current drawings make those parts testable without pretending the provisional art choices are settled rules.

## Run locally

Install Godot 4.7.x, then from the repository directory run:

```sh
godot --path .
```

Or open `project.godot` in the Godot editor and press Run.

## Android previews

The `animal-salon` branch has a preview workflow that can build and publish a signed development APK. Development builds use package `org.isomorphisms.game.dev` and the existing family/testing signing key so one preview can update another. That key is public and is not suitable for a future Play Store release.

## Project layout

- `GAME_IDEA.md` — game designer's decisions and open questions
- `GAME_SPEC.md` — settled rules, unanswered questions, and first-playable scope
- `project.godot` — Godot project configuration
- `scenes/main.tscn` — main scene
- `scripts/main.gd` — tap flow and internal state
- `scripts/animal_view.gd` — zebra, horse, unicorn, outfits, hair, makeup, wings, horns, blinking, and messy-look drawing
- `scripts/scene_art.gd` — waiting room, salon, dressing room, snack shop, and photo-room backgrounds
- `scripts/icon_view.gd` — visual action/choice icons
- `scripts/food_icon.gd` — illustrated snack and drink cards
- `export_presets.cfg` — Android export preset
