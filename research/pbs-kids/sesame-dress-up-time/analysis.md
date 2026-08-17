# Sesame Street — Dress Up Time

## Sources

- Game: https://pbskids.org/games/play/dress-up-time/8573
- PBS KIDS for Parents Halloween listing: https://www.pbs.org/parents/halloween
- PBS dramatic-play collection: https://www.pbs.org/parents/act-it-out

PBS says Elmo and Abby want to play dress up and the child chooses pieces of clothing to complete the outfits they want to wear.

`feature.jpg` is official feature art, not a captured gameplay frame.

## Functional model

The wording suggests a small goal-oriented dress-up loop rather than arbitrary state text:

```text
character / desired look
  -> clothing choices
  -> equip item(s)
  -> outfit complete
  -> celebration / next look
```

Whether the original uses drag, tap-to-equip, strict wrong-answer rejection, or a softer hint system is not established by the saved reference material.

## Data structure worth copying

```lua
Outfit = {
  head = nil,
  body = nil,
  feet = nil,
  extra = nil
}

WardrobeItem = {
  id = "astronaut_suit",
  slot = "body",
  tags = {"astronaut"},
  sprite = "astronaut_suit.png",
  anchors = {
    zebra = {x=..., y=..., scale=...},
    unicorn = {x=..., y=..., scale=...}
  }
}
```

Equip is a model operation:

```lua
function equip(customer, item)
  customer.outfit[item.slot] = item.id
end
```

Rendering composites the item over the character at the species-specific anchor. The model never needs to know pixels; the renderer never needs to invent outfit state.

## Completion logic

If the scene is a requested theme, completion can be tag-based:

```lua
function matchesTheme(outfit, theme)
  return everyRequiredSlotHasTag(outfit, theme)
end
```

If the salon is free-form, remove the correctness predicate and make Done an explicit large control. The same rendering/inventory system works in either case.
