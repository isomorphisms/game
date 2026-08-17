extends Control

var animal_kind := "zebra"
var animal_variant := 0
var outfit_index := 0
var hair_index := 0
var makeup_index := 0
var unicorn_costume := false
var wearing_wings := false
var horn_style := "none"
var messy := false

var _eyes_open := true
var _blink_timer: Timer
var _open_timer: Timer

func _ready() -> void:
    if custom_minimum_size.y <= 0.0:
        custom_minimum_size = Vector2(0, 440)
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
    size_flags_vertical = Control.SIZE_EXPAND_FILL
    mouse_filter = Control.MOUSE_FILTER_IGNORE

    _blink_timer = Timer.new()
    _blink_timer.one_shot = true
    _blink_timer.timeout.connect(_begin_blink)
    add_child(_blink_timer)

    _open_timer = Timer.new()
    _open_timer.one_shot = true
    _open_timer.timeout.connect(_finish_blink)
    add_child(_open_timer)

    _schedule_blink()
    queue_redraw()

func configure(
    kind: String,
    variant: int,
    outfit: int,
    hair: int,
    makeup: int,
    as_unicorn: bool,
    wings: bool,
    new_horn_style: String,
    is_messy: bool
) -> void:
    animal_kind = kind
    animal_variant = variant
    outfit_index = outfit
    hair_index = hair
    makeup_index = makeup
    unicorn_costume = as_unicorn
    wearing_wings = wings
    horn_style = new_horn_style
    messy = is_messy
    queue_redraw()

func _schedule_blink() -> void:
    if is_inside_tree() and _blink_timer != null:
        _blink_timer.start(randf_range(1.7, 3.8))

func _begin_blink() -> void:
    _eyes_open = false
    queue_redraw()
    _open_timer.start(0.12)

func _finish_blink() -> void:
    _eyes_open = true
    queue_redraw()
    _schedule_blink()

func _draw() -> void:
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

    _ellipse(Vector2(250, 470), Vector2(125, 18), Color(0.35, 0.20, 0.31, 0.13))

    if wearing_wings:
        _draw_wings()

    _draw_tail(coat_shadow, mane, ink)
    _draw_legs(coat, coat_shadow, ink)
    _draw_arms(coat, coat_shadow, ink)

    _ellipse(Vector2(250, 275), Vector2(92, 120), coat)
    _ellipse(Vector2(250, 300), Vector2(72, 90), coat_shadow)

    if animal_kind == "zebra":
        _draw_zebra_body_stripes(ink)

    _draw_outfit(ink)

    _ellipse(Vector2(250, 115), Vector2(91, 82), coat)
    _draw_ears(coat, coat_shadow, ink)
    _ellipse(Vector2(250, 150), Vector2(62, 42), coat_shadow.lightened(0.18))

    if animal_kind == "zebra":
        _draw_zebra_face_stripes(ink)

    _draw_hair(mane, ink)
    _draw_horn(ink)
    _draw_face(ink)

    if messy:
        _draw_messy_hair(ink)

    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _coat_color() -> Color:
    match animal_kind:
        "horse":
            return Color("c98f5a")
        "unicorn":
            return Color("f3edff") if animal_variant == 0 else Color("e7fff4")
        _:
            return Color("fbfaf7")

func _mane_color() -> Color:
    if animal_kind == "unicorn":
        return Color("e69bdb") if animal_variant == 0 else Color("78cde0")
    if animal_kind == "horse":
        return Color("6a4335")
    if unicorn_costume:
        return Color("e79bdc")
    return Color("2d2730")

func _draw_wings() -> void:
    var left := PackedVector2Array([
        Vector2(177, 240), Vector2(95, 190), Vector2(68, 210), Vector2(126, 270),
        Vector2(76, 286), Vector2(154, 322), Vector2(205, 290)
    ])
    var right := PackedVector2Array([
        Vector2(323, 240), Vector2(405, 190), Vector2(432, 210), Vector2(374, 270),
        Vector2(424, 286), Vector2(346, 322), Vector2(295, 290)
    ])
    draw_colored_polygon(left, Color("e6d9ff"))
    draw_colored_polygon(right, Color("d8f1ff"))
    draw_polyline(left, Color("9778b8"), 4.0, true)
    draw_polyline(right, Color("789fb8"), 4.0, true)
    draw_line(Vector2(112, 225), Vector2(175, 273), Color("b7a0d3"), 3.0, true)
    draw_line(Vector2(388, 225), Vector2(325, 273), Color("9fc5d7"), 3.0, true)

func _draw_tail(coat_shadow: Color, mane: Color, ink: Color) -> void:
    draw_line(Vector2(176, 284), Vector2(112, 332), coat_shadow, 22.0, true)
    draw_line(Vector2(113, 332), Vector2(86, 370), mane, 18.0, true)
    draw_line(Vector2(95, 355), Vector2(72, 380), mane, 9.0, true)
    draw_line(Vector2(101, 360), Vector2(92, 389), mane, 9.0, true)
    draw_line(Vector2(106, 355), Vector2(115, 383), mane, 9.0, true)
    draw_circle(Vector2(177, 284), 9.0, ink)

func _draw_legs(coat: Color, coat_shadow: Color, ink: Color) -> void:
    draw_line(Vector2(218, 360), Vector2(200, 438), coat, 34.0, true)
    draw_line(Vector2(282, 360), Vector2(300, 438), coat, 34.0, true)
    draw_line(Vector2(200, 435), Vector2(188, 461), coat_shadow, 31.0, true)
    draw_line(Vector2(300, 435), Vector2(312, 461), coat_shadow, 31.0, true)
    draw_line(Vector2(180, 463), Vector2(211, 463), ink, 9.0, true)
    draw_line(Vector2(289, 463), Vector2(320, 463), ink, 9.0, true)
    if animal_kind == "zebra":
        draw_line(Vector2(202, 392), Vector2(211, 417), ink, 12.0, true)
        draw_line(Vector2(289, 392), Vector2(297, 417), ink, 12.0, true)

func _draw_arms(coat: Color, coat_shadow: Color, ink: Color) -> void:
    draw_line(Vector2(173, 231), Vector2(116, 314), coat, 27.0, true)
    draw_line(Vector2(327, 231), Vector2(384, 314), coat, 27.0, true)
    _ellipse(Vector2(108, 325), Vector2(18, 22), coat_shadow)
    _ellipse(Vector2(392, 325), Vector2(18, 22), coat_shadow)
    if animal_kind == "zebra":
        draw_line(Vector2(143, 278), Vector2(125, 300), ink, 10.0, true)
        draw_line(Vector2(357, 278), Vector2(375, 300), ink, 10.0, true)

func _draw_ears(coat: Color, coat_shadow: Color, ink: Color) -> void:
    var left := PackedVector2Array([Vector2(186, 77), Vector2(169, 22), Vector2(215, 58)])
    var right := PackedVector2Array([Vector2(314, 77), Vector2(331, 22), Vector2(285, 58)])
    draw_colored_polygon(left, coat)
    draw_colored_polygon(right, coat)
    draw_polyline(left, ink, 4.0, true)
    draw_polyline(right, ink, 4.0, true)
    draw_colored_polygon(PackedVector2Array([Vector2(187, 65), Vector2(178, 37), Vector2(204, 58)]), coat_shadow)
    draw_colored_polygon(PackedVector2Array([Vector2(313, 65), Vector2(322, 37), Vector2(296, 58)]), coat_shadow)

func _draw_zebra_body_stripes(ink: Color) -> void:
    draw_line(Vector2(191, 212), Vector2(224, 286), ink, 13.0, true)
    draw_line(Vector2(220, 178), Vector2(241, 292), ink, 13.0, true)
    draw_line(Vector2(252, 164), Vector2(255, 294), ink, 13.0, true)
    draw_line(Vector2(286, 178), Vector2(270, 292), ink, 13.0, true)
    draw_line(Vector2(313, 211), Vector2(286, 286), ink, 13.0, true)
    draw_line(Vector2(186, 321), Vector2(224, 342), ink, 12.0, true)
    draw_line(Vector2(314, 321), Vector2(276, 342), ink, 12.0, true)

func _draw_zebra_face_stripes(ink: Color) -> void:
    draw_line(Vector2(198, 70), Vector2(220, 116), ink, 11.0, true)
    draw_line(Vector2(222, 43), Vector2(238, 110), ink, 10.0, true)
    draw_line(Vector2(278, 43), Vector2(262, 110), ink, 10.0, true)
    draw_line(Vector2(302, 70), Vector2(280, 116), ink, 11.0, true)
    draw_line(Vector2(210, 137), Vector2(230, 160), ink, 9.0, true)
    draw_line(Vector2(290, 137), Vector2(270, 160), ink, 9.0, true)

func _draw_outfit(ink: Color) -> void:
    if outfit_index == 0:
        return

    if outfit_index == 1:
        draw_colored_polygon(PackedVector2Array([
            Vector2(185, 190), Vector2(315, 190), Vector2(326, 292), Vector2(174, 292)
        ]), Color("f19ac7"))
        draw_colored_polygon(PackedVector2Array([
            Vector2(174, 280), Vector2(326, 280), Vector2(372, 405), Vector2(128, 405)
        ]), Color("f5b4d8"))
        draw_line(Vector2(188, 214), Vector2(312, 214), Color("fff7fb"), 7.0, true)
        draw_circle(Vector2(250, 214), 9.0, Color("ffe27a"))
        draw_arc(Vector2(250, 280), 73.0, 0.0, PI, 24, ink, 3.0, true)
    elif outfit_index == 2:
        draw_colored_polygon(PackedVector2Array([
            Vector2(181, 190), Vector2(319, 190), Vector2(330, 300), Vector2(170, 300)
        ]), Color("7ec8e8"))
        draw_colored_polygon(PackedVector2Array([
            Vector2(170, 285), Vector2(330, 285), Vector2(350, 398), Vector2(150, 398)
        ]), Color("a9e3f4"))
        for x in [170.0, 205.0, 240.0, 275.0, 310.0]:
            draw_colored_polygon(PackedVector2Array([
                Vector2(x, 398), Vector2(x + 17, 420), Vector2(x + 35, 398)
            ]), Color("d4f4fb"))
        draw_line(Vector2(188, 222), Vector2(312, 222), Color("ffffff"), 6.0, true)
        draw_circle(Vector2(250, 222), 8.0, Color("fff2a6"))
    else:
        draw_colored_polygon(PackedVector2Array([
            Vector2(185, 190), Vector2(315, 190), Vector2(324, 323), Vector2(176, 323)
        ]), Color("8ac77b"))
        draw_rect(Rect2(202, 275, 96, 110), Color("6bad64"), true)
        draw_line(Vector2(210, 194), Vector2(230, 286), Color("f4e6a8"), 12.0, true)
        draw_line(Vector2(290, 194), Vector2(270, 286), Color("f4e6a8"), 12.0, true)
        draw_rect(Rect2(220, 302, 60, 40), Color("9ed58f"), true)
        draw_circle(Vector2(225, 285), 5.0, Color("fff0a0"))
        draw_circle(Vector2(275, 285), 5.0, Color("fff0a0"))

func _draw_hair(mane: Color, ink: Color) -> void:
    if hair_index == 0:
        draw_line(Vector2(194, 70), Vector2(177, 146), mane, 22.0, true)
        draw_line(Vector2(184, 95), Vector2(169, 176), mane, 18.0, true)
        draw_line(Vector2(205, 46), Vector2(248, 31), mane, 17.0, true)
        draw_line(Vector2(246, 31), Vector2(294, 46), mane, 17.0, true)
    elif hair_index == 1:
        draw_line(Vector2(196, 56), Vector2(252, 32), mane, 21.0, true)
        draw_line(Vector2(250, 32), Vector2(307, 62), mane, 21.0, true)
        for y in [103.0, 127.0, 151.0, 175.0, 199.0]:
            draw_circle(Vector2(328, y), 13.0, mane)
            draw_arc(Vector2(328, y), 13.0, 0.0, TAU, 20, ink, 2.0, true)
        draw_circle(Vector2(328, 217), 8.0, Color("f3d56e"))
    else:
        for p in [
            Vector2(188, 56), Vector2(217, 35), Vector2(250, 28), Vector2(283, 35),
            Vector2(312, 56), Vector2(178, 87), Vector2(322, 87)
        ]:
            draw_circle(p, 22.0, mane)
        draw_circle(Vector2(250, 47), 8.0, Color("fff2a1"))

func _draw_horn(ink: Color) -> void:
    var show_horn := animal_kind == "unicorn" or (animal_kind == "zebra" and unicorn_costume and horn_style != "none")
    if not show_horn:
        return

    var rainbow := horn_style == "rainbow horn"
    var horn_color := Color("f4d469") if not rainbow else Color("f08ec8")
    var horn := PackedVector2Array([Vector2(240, 46), Vector2(250, -16), Vector2(264, 46)])
    draw_colored_polygon(horn, horn_color)
    draw_polyline(horn, ink, 3.0, true)
    if rainbow:
        draw_line(Vector2(244, 29), Vector2(260, 25), Color("78c9ff"), 5.0, true)
        draw_line(Vector2(246, 17), Vector2(258, 14), Color("7fd785"), 5.0, true)
        draw_line(Vector2(248, 6), Vector2(256, 4), Color("ffd66b"), 5.0, true)

func _draw_face(ink: Color) -> void:
    if _eyes_open:
        draw_circle(Vector2(220, 108), 10.0, Color("ffffff"))
        draw_circle(Vector2(280, 108), 10.0, Color("ffffff"))
        draw_circle(Vector2(221, 110), 6.5, ink)
        draw_circle(Vector2(279, 110), 6.5, ink)
        draw_circle(Vector2(223, 107), 2.0, Color("ffffff"))
        draw_circle(Vector2(281, 107), 2.0, Color("ffffff"))
    else:
        draw_line(Vector2(210, 110), Vector2(230, 110), ink, 4.0, true)
        draw_line(Vector2(270, 110), Vector2(290, 110), ink, 4.0, true)

    draw_circle(Vector2(232, 151), 3.5, ink)
    draw_circle(Vector2(268, 151), 3.5, ink)
    draw_arc(Vector2(250, 160), 23.0, 0.18, PI - 0.18, 18, Color("8f586d"), 3.5, true)

    if makeup_index == 1:
        draw_circle(Vector2(199, 139), 11.0, Color(0.96, 0.45, 0.65, 0.42))
        draw_circle(Vector2(301, 139), 11.0, Color(0.96, 0.45, 0.65, 0.42))
        draw_line(Vector2(210, 99), Vector2(231, 94), Color("d46fa8"), 4.0, true)
        draw_line(Vector2(269, 94), Vector2(290, 99), Color("d46fa8"), 4.0, true)
    elif makeup_index == 2:
        draw_arc(Vector2(220, 107), 13.0, PI, TAU, 12, Color("8a70d6"), 4.0, true)
        draw_arc(Vector2(280, 107), 13.0, PI, TAU, 12, Color("8a70d6"), 4.0, true)
        var heart := PackedVector2Array([
            Vector2(303, 139), Vector2(295, 131), Vector2(286, 139),
            Vector2(303, 157), Vector2(320, 139), Vector2(311, 131)
        ])
        draw_colored_polygon(heart, Color("f184b9"))

func _draw_messy_hair(ink: Color) -> void:
    for line in [
        [Vector2(178, 77), Vector2(144, 46)],
        [Vector2(195, 47), Vector2(178, 10)],
        [Vector2(221, 35), Vector2(214, 0)],
        [Vector2(279, 35), Vector2(289, 3)],
        [Vector2(307, 49), Vector2(334, 15)],
        [Vector2(320, 84), Vector2(356, 58)]
    ]:
        draw_line(line[0], line[1], ink, 6.0, true)

func _ellipse(center: Vector2, radii: Vector2, color: Color, steps: int = 48) -> void:
    var points := PackedVector2Array()
    for i in range(steps):
        var angle := TAU * float(i) / float(steps)
        points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
    draw_colored_polygon(points, color)
