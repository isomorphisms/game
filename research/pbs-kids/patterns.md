# Cross-game patterns

## 1. State exists in the picture

The player usually does not read internal state. State appears as an object visibly moved into place; food changing as it is prepared; hair changing from one stage/style to another; clothes appearing on a character; a collected-item counter changing; or a selected creature ability changing the next race.

For our games, debug text can exist, but normal play should render the state graphically.

## 2. Scene graph is shallow

```text
TITLE / HOME
  -> CHOICE HUB
  -> ACTIVITY INTRO
  -> FOCUSED INTERACTION STEP
  -> FOCUSED INTERACTION STEP ...
  -> REVEAL / CELEBRATION
  -> HUB or NEXT CUSTOMER/LEVEL
```

Not every game uses every state. The important feature is that a child sees one clear task at a time.

## 3. One scene, one main verb

Good scenes tend to center on one input verb: choose, tap, drag/place, scrub/brush/mash continuously, or steer/jump. This keeps touch handling simple and makes visual feedback immediate.

## 4. Persistent creation state

A transformation game should maintain model state independently of the current scene. Example for the salon:

```lua
customer = {
  species = "zebra",
  hair = {clean = true, style = "braids"},
  outfit = {body = "purple_dress", head = nil, feet = "boots"},
  accessories = {"star_clip"},
  snack = nil,
  drink = nil
}
```

A scene edits only its portion of the model; every later scene renders the accumulated result. This is why a dress must actually remain over the animal's body rather than being represented by the word `dress = purple`.

## 5. Separate model, interaction controller, and renderer

```text
model         = durable game/customer/recipe/level state
controller    = maps touch/mouse events into model changes
renderer      = draws current scene from model state
scene manager = owns transitions and lifecycle
```

A salon `dress_up` scene should write `customer.outfit.body`; the photo scene later reads the same field.

## 6. Hit testing and pointer capture

```text
pointer down on draggable -> capture object
pointer move              -> object follows pointer
pointer up over valid zone -> snap / apply state change
pointer up elsewhere       -> return to source or last legal location
state change               -> redraw + audio/animation feedback
```

Use generous hit regions larger than the visible art. On a tablet, input should not require pixel precision.

## 7. Completion predicates, not prose

```lua
function step:isComplete(model)
  return model.jar.cucumberSlices >= self.requiredSlices
end
```

or

```lua
function outfit:isComplete(model)
  return model.outfit.body ~= nil and model.outfit.feet ~= nil
end
```

Then the scene can trigger celebration/advance without exposing the predicate to the player.

## 8. Global controls are visually stable

Molly's Winter Kitchen reference frames keep Home and Settings in fixed corners while the activity changes. Global UI should live in an overlay layer outside scene-specific objects.

## 9. Layered character rendering is essential for the salon

```text
background
shadow
animal base body
body outfit
shoes / lower-body items
hair / mane style
horn / ears / headwear
wings (behind or in front according to item metadata)
small accessories
face / blink overlay if needed
foreground props
UI
```

Every wearable needs an anchor and scale for each species/body pose. This is the technical difference between a graphical dress-up game and a state screen with labels.

## 10. A useful reusable module split

```text
scenes/
  waiting_room
  station
  dress_up
  snack_shop
  photo
systems/
  scene_manager
  input
  drag
  hotspot
  sequence
  audio_cue
  transition
models/
  customer
  outfit
  salon_progress
render/
  character_layers
  ui
```

The same event loop can then support zebra/unicorn variants without duplicating the whole game.
