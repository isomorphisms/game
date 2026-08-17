# Molly of Denali — Molly's Winter Kitchen

## Sources

- Official game: https://pbskids.org/games/play/mollys-winter-kitchen/135463
- PBS KIDS for Parents Molly page: https://www.pbs.org/parents/shows/molly
- Credited designer portfolio: https://www.nolanmanning.com/work/mollys-winter-kitchen
- PBS KIDS gameplay video listing: https://pbskids.org/videos/all-gameplay

The designer describes a game in which Molly and her mother prepare preserved foods such as blueberry jam, syrup and moose stew. PBS describes the game as learning different ways of preserving food.

## Saved reference frames

### `winter_kitchen3.jpg` — recipe hub

**Observed:** Six large recipe cards on a wooden background: Dog Salmon Eggs, Blueberry Jam, Moose Stew, Pickles, Jarred Salmon and Birch Syrup. Settings is a persistent corner control.

**Likely role:** branch/select state. A recipe card is a large hotspot whose result is not merely text; it selects a recipe data object and loads that recipe's scene sequence.

### `winter_kitchen1.jpg` — recipe establishing/prep scene

**Observed:** Molly and her mother stand behind a table. A Jarred Salmon recipe card, salmon, jars, bowl and tools are all spatially laid out. Home and Settings appear in fixed corners.

**Likely role:** recipe intro or one preparation step. The selected recipe determines which art objects exist and which of them are interactive.

### `winter_kitchen2.jpg` — focused tool interaction

**Observed:** Close-up of a pot of blueberries and a masher. Most unrelated world art has disappeared. Home and Settings remain.

**Likely role:** one-verb minigame. A pointer gesture on/with the masher can be converted into `mashProgress`; the scene advances only after a completion condition.

### `winter_kitchen4.jpg` — drag/place interaction

**Observed:** A jar already contains cucumber slices. More cucumber slices and dill sit on a cutting board, and one cucumber slice is visibly between board and jar.

**Likely role:** drag an ingredient from source area to jar target. The jar itself visually contains accumulated state, so the child can see progress without reading a counter.

### `explore-backpack.jpg` — quest/inventory reference from another Molly game

**Observed:** Molly stands in the world while a speech bubble says “Deliver the blueberries to Dad.” A large bottom tray contains a map, blueberry jar, drum-like object and forward/back controls.

**Pattern worth borrowing:** dialogue/instruction can temporarily overlay the world while the durable task inventory remains visible. The quest objective and inventory are separate pieces of state.

## Inferred state machine

```text
recipe_select
    | card(recipeId)
    v
recipe_intro(recipeId)
    |
    v
step(recipeId, 0)
    | complete
    v
step(recipeId, 1)
    | ...
    v
recipe_complete
    |
    +----> recipe_select
```

A plausible model:

```lua
GameState = {
  screen = "recipe_select",
  recipeId = nil,
  stepIndex = 0,
  stepState = {},
  settings = {music=true, sfx=true, narration=true}
}

Recipe = {
  id = "pickles",
  title = "Pickles",
  steps = { ... }
}

Step = {
  scene = "fill_jar",
  instructionAudio = "...",
  objects = { ... },
  isComplete = function(state) ... end
}
```

## Input → response logic

For the cucumber/jar scene, a likely controller is:

```text
touch down over cucumber -> capture cucumber instance
touch move               -> move sprite with pointer
touch release over jar   -> increment jar fill state; animate ingredient into jar
touch release elsewhere  -> return ingredient to board
mutation                  -> test completion predicate
complete                  -> positive audio/animation; lock current input; transition
```

For the masher scene:

```text
touch down on masher       -> capture tool
drag through berry area    -> accumulate valid motion/work
valid work                 -> change berry art / particles / sound
progress threshold reached -> complete step
```

The exact PBS implementation may differ; these functions are an implementation model that reproduces the visible behavior.

## What this says about our games

Do not make “prepare food” one screen full of buttons. Make each meaningful action its own visually specific scene, keep global controls stable, and store the result in a persistent model that later scenes can render.
