# Lyla in the Loop — Lyla and Stu's Hairdos

## Sources

- Official PBS KIDS for Parents show/game listing: https://www.pbs.org/parents/shows/lyla
- PBS article on the game and textured hair care: https://www.pbs.org/parents/thrive/caring-for-textured-hair
- Official gameplay video: https://pbskids.org/videos/watch/lyla-stus-hairdos-gameplay/2731494
- Game: https://pbskids.org/games/play/lyla-and-stus-hairdos/1769066

PBS describes the verbs directly: wash, brush, braid and accessorize. Its article says the experience breaks the process down step-by-step from pre-wash through accessorizing, offers many choices, and has Lyla and Stu choose hairstyles/accessories for special occasions.

`feature.jpg` is the official feature art, not a gameplay frame. `textured-hair-article.jpg` is an article image; neither should be treated as evidence for precise in-game control placement.

## Documented functional flow

The safest high-level model is:

```text
special occasion / style choice
  -> pre-wash preparation
  -> wash
  -> brush / hair preparation
  -> braid / style
  -> accessorize
  -> finished look
```

The exact number/order of internal substages should not be asserted without a frame-by-frame playthrough, but the overall staged transformation is documented.

## Why this is the closest salon reference

The crucial technical feature is **persistent visual transformation**. Hair is not a string field shown on screen. Each station changes a model that subsequent stations must render.

A model suitable for reproducing that design pattern:

```lua
HairState = {
  clean = false,
  wetness = 0,
  detangleProgress = 0,
  style = nil,
  accessories = {}
}

Customer = {
  character = "lyla",
  occasion = nil,
  hair = HairState
}
```

Then each scene has a narrow controller:

```text
wash scene       -> edits clean/wetness
brush scene      -> edits detangleProgress
style scene      -> edits style and possibly sections
accessory scene  -> edits accessory list/anchors
reveal scene     -> reads everything; edits nothing
```

## Interaction design inferred from the task verbs

### Washing

A continuous gesture can be accepted while a wash tool/hand intersects the hair mask. Progress can depend on distance moved rather than elapsed time, preventing a child from having to hold perfectly still.

### Brushing

Capture the brush on pointer down. Valid strokes intersect one or more generous hair zones. Each valid stroke increases a section's progress and immediately changes art/animation.

### Braiding/styling

Keep the interaction discrete enough for a young child: choose a style and then perform a short sequence of obvious taps/drags, or directly manipulate large hair sections. The specific PBS gesture is not established by the saved material.

### Accessories

Accessories are naturally modeled as items with allowed anchor slots:

```lua
Accessory = {
  id = "star_clip",
  sprite = "star_clip.png",
  allowedSlots = {"left_hair", "right_hair"}
}
```

Tap or drag → hit-test an anchor → snap → persist in `hair.accessories`.

## Direct implication for the animal salon

The salon should use the same pattern:

```text
waiting room -> choose one animal -> care station(s) -> dress -> snack/drink -> photo -> waiting room
```

Each station edits the same `customer` object. A unicorn that becomes messy during a relaxing activity should literally have the relevant hairstyle/accessory state altered so the redo station visibly restores it. A zebra dressed as a unicorn should get horn/wing/costume layers, not a textual status label.
