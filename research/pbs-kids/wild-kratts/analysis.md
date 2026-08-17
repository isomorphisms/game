# Wild Kratts — action/configuration reference

## Sources

- PBS KIDS for Parents Wild Kratts page: https://www.pbs.org/parents/shows/wild-kratts
- PBS article on Wild Kratts games: https://www.pbs.org/parents/thrive/go-wild-8-wild-kratts-science-games

PBS describes Monkey Mayhem as a 2D platformer in which the player collects fruit, and Creature Mobile as choosing a race terrain, adding animal abilities suited to that environment, then racing.

`monkey-mayhem.jpg` is a reduced reference frame from a third-party gameplay-video thumbnail, not an official PBS asset. It is included only to study HUD/layout and should never ship in our game.

## Observed action-game layout in the saved frame

- gameplay occupies almost the entire screen;
- player character is centered in the world rather than in a menu panel;
- progress (`20/30`) is graphical HUD in a corner;
- character/status portrait is another HUD element;
- Home/help/fullscreen controls sit at edges, away from the movement area;
- platforms and collectible goals are represented directly in the scene.

This contrasts usefully with the salon: during a running minigame, hide salon menus and let the action own the screen.

## Creature Mobile state pattern (documented high-level behavior)

```text
terrain_select
  -> ability/loadout_select
  -> race
  -> result
  -> terrain_select / next race
```

The interesting architectural point is that **configuration state changes a later real-time scene**:

```lua
RaceConfig = {
  terrain = "water",
  abilities = {"otter"}
}
```

The race controller reads that configuration to decide handling/advantages. This is the same general pattern as choosing a salon outfit and later rendering it in the photo scene.

## Cheetah-game relevance

For the separate cheetah runner, use a similarly sparse action HUD:

```text
world + cheetah + food + bombs
HUD: foods collected / foods required + level + stars
```

Food collision mutates the collection count; bomb collision triggers its penalty; a level-completion predicate decides when to award the star and move to the next of three levels. The player should never need a text dump of those variables.
