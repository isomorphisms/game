extends "res://scripts/animal_view_base.gd"

# Keep the shared horse/unicorn renderer unchanged. The zebra gets the
# rounder, fuller proportions used by the newer movie artwork.
func _draw() -> void:
    if animal_kind != "zebra":
        super()
        return

    var base_size := Vector2(500.0, 500.0)
    var sx: float = size.x / base_size.x
    var sy: float = size.y / base_size.y
    var scale_factor: float = min(sx, sy)
    if scale_factor <= 0.0:
        scale_factor = 1.0
    var offset := Vector2(
        (size.x - base_size.x * scale_factor) * 0.5,
        (size.y - base_size.y * scale_factor) * 0.5
    )
    draw_set_transform(offset, 0.0, Vector2(scale_factor, scale_factor))

    var coat := _coat_color()
    var coat_shadow := coat.darkened(0.12)
    var mane := _mane_color()
    var ink := Color("3a2a38")

    _ellipse(Vector2(250, 470), Vector2(138, 19), Color(0.35, 0.20, 0.31, 0.13))

    if wearing_wings:
        _draw_wings()

    _draw_tail(coat_shadow, mane, ink)
    _draw_fuller_zebra_legs(coat, coat_shadow, ink)
    _draw_fuller_zebra_arms(coat, coat_shadow, ink)

    # A wider torso and belly make the zebra read less angular and more plush.
    _ellipse(Vector2(250, 278), Vector2(104, 126), coat)
    _ellipse(Vector2(250, 305), Vector2(82, 94), coat_shadow)
    _draw_zebra_body_stripes(ink)
    _draw_outfit(ink)

    # Larger head and muzzle, while keeping all accessory anchor points stable.
    _ellipse(Vector2(250, 116), Vector2(104, 92), coat)
    _draw_ears(coat, coat_shadow, ink)
    _ellipse(Vector2(250, 153), Vector2(68, 46), coat_shadow.lightened(0.18))
    _draw_zebra_face_stripes(ink)

    _draw_hair(mane, ink)
    _draw_horn(ink)

    # Enlarge the eye whites underneath the existing pupils/expressions.
    if _eyes_open:
        draw_circle(Vector2(220, 108), 14.0, Color("ffffff"))
        draw_circle(Vector2(280, 108), 14.0, Color("ffffff"))
    _draw_face(ink)

    if messy:
        _draw_messy_hair(ink)

    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_fuller_zebra_legs(coat: Color, coat_shadow: Color, ink: Color) -> void:
    draw_line(Vector2(215, 354), Vector2(199, 433), coat, 40.0, true)
    draw_line(Vector2(285, 354), Vector2(301, 433), coat, 40.0, true)
    draw_line(Vector2(199, 430), Vector2(188, 457), coat_shadow, 34.0, true)
    draw_line(Vector2(301, 430), Vector2(312, 457), coat_shadow, 34.0, true)
    draw_line(Vector2(178, 460), Vector2(212, 460), ink, 10.0, true)
    draw_line(Vector2(288, 460), Vector2(322, 460), ink, 10.0, true)
    draw_line(Vector2(200, 390), Vector2(210, 416), ink, 14.0, true)
    draw_line(Vector2(290, 390), Vector2(300, 416), ink, 14.0, true)

func _draw_fuller_zebra_arms(coat: Color, coat_shadow: Color, ink: Color) -> void:
    draw_line(Vector2(166, 230), Vector2(115, 311), coat, 32.0, true)
    draw_line(Vector2(334, 230), Vector2(385, 311), coat, 32.0, true)
    _ellipse(Vector2(108, 323), Vector2(20, 24), coat_shadow)
    _ellipse(Vector2(392, 323), Vector2(20, 24), coat_shadow)
    draw_line(Vector2(142, 276), Vector2(124, 300), ink, 12.0, true)
    draw_line(Vector2(358, 276), Vector2(376, 300), ink, 12.0, true)
