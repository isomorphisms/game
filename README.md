# Dress the Unicorn

A tap-driven 2D animal salon game built with Godot 4.7.

The game designer's decisions live in `GAME_IDEA.md`. The Godot project is now a small playable structure around those decisions; placeholder controls are used until the final animal, salon, clothing, hairstyle, makeup, food, animation, and sound art is made.

## Current prototype

- Waiting room with a zebra, horse, and two unicorns.
- Only one animal enters the salon at a time.
- Tap controls only; no drag interactions.
- Zebra can dress as a unicorn.
- Unicorn wings, regular horn, and rainbow horn placeholders.
- Unicorns can get messed up by an intentionally unspecified relaxing activity and be redone.
- Full current snack and drink list from `GAME_IDEA.md`.
- End-of-session photo capture to the app's storage.

Hairstyles, makeup, and the exact relaxing activity remain undecided, so the prototype does not invent them.

## Run locally

Install Godot 4.7.x, then from the repository directory run:

```sh
godot --path .
```

Or open `project.godot` in the Godot editor and press Run.

## Android releases

Publishing a GitHub release triggers the Android build workflow. It uses Godot 4.7.1 and attaches `dress-the-unicorn-<tag>.apk` to the release.

The Android package remains `org.isomorphisms.game.dev` and uses the existing family/testing signing key so development builds can update one another. That key is public and is not for a future Play Store release.

## Project layout

- `GAME_IDEA.md` — game designer's decisions and open questions
- `project.godot` — Godot project configuration
- `scenes/main.tscn` — main scene
- `scripts/main.gd` — current tap-driven prototype
- `export_presets.cfg` — Android export preset
- `assets/` — future art, sounds, fonts, and other game data
