# Game

A small game project built with [LÖVE](https://love2d.org/).

## Run locally

From the repository directory:

```sh
love .
```

## Put it on an Android phone or tablet

No computer is needed.

1. Open this repository on GitHub.
2. Open **Releases** and choose **Draft a new release**.
3. Choose **Create new tag**, such as `v0.1.0`, targeting `main`.
4. Press **Publish release**.
5. The release will automatically get:
   - `game-v0.1.0.love` — opens in the LÖVE Android app.
   - `game-v0.1.0.apk` — a standalone Android app you can install directly.

The `.love` file is attached first; the APK appears after the Android build finishes.

APK releases use the same development signing key, so a newer release can be installed over an older one. The package id is `org.isomorphisms.game.dev`. This public development key is only for sideloaded family/testing builds, not a future Play Store release.

## Project layout

- `main.lua` — game callbacks and game code
- `conf.lua` — window and application configuration
- `assets/` — images, sounds, fonts, maps, and other game data

LÖVE calls `love.load` once at startup, `love.update(dt)` every frame for game logic, and `love.draw()` every frame for rendering.
