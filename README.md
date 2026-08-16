# Game

A small game project built with [LÖVE](https://love2d.org/).

## Run

From the repository directory:

```sh
love .
```

## Project layout

- `main.lua` — game callbacks and game code
- `conf.lua` — window and application configuration
- `assets/` — images, sounds, fonts, maps, and other game data

LÖVE calls `love.load` once at startup, `love.update(dt)` every frame for game logic, and `love.draw()` every frame for rendering.
