extends Control

var room := "waiting"

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    queue_redraw()

func configure(new_room: String) -> void:
    room = new_room
    queue_redraw()

func _draw() -> void:
    var base_size := Vector2(1280.0, 720.0)
    var sx: float = size.x / base_size.x
    var sy: float = size.y / base_size.y
    draw_set_transform(Vector2.ZERO, 0.0, Vector2(sx, sy))

    draw_rect(Rect2(0, 0, 1280, 720), Color("fff5fb"), true)
    draw_rect(Rect2(0, 500, 1280, 220), Color("ead7c5"), true)
    for x in range(0, 1280, 80):
        draw_line(Vector2(x, 500), Vector2(x + 130, 720), Color(0.63, 0.49, 0.39, 0.18), 2.0)

    match room:
        "waiting":
            _draw_waiting_room()
        "dress":
            _draw_dressing_room()
        "food":
            _draw_food_shop()
        "photo":
            _draw_photo_room()
        _:
            _draw_salon()

    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_waiting_room() -> void:
    draw_rect(Rect2(65, 110, 300, 170), Color("dbf1ff"), true)
    draw_rect(Rect2(80, 125, 270, 140), Color("bfe5fa"), true)
    draw_line(Vector2(215, 125), Vector2(215, 265), Color("ffffff"), 8.0)
    draw_line(Vector2(80, 195), Vector2(350, 195), Color("ffffff"), 8.0)

    draw_rect(Rect2(860, 325, 315, 120), Color("d7a8c7"), true)
    draw_circle(Vector2(905, 445), 44, Color("c68eb5"))
    draw_circle(Vector2(1130, 445), 44, Color("c68eb5"))
    draw_rect(Rect2(885, 300, 255, 80), Color("ecc9df"), true)
    draw_rect(Rect2(910, 315, 75, 45), Color("fff0ac"), true)
    draw_rect(Rect2(1005, 315, 75, 45), Color("d9f4ff"), true)

    draw_rect(Rect2(1010, 90, 145, 185), Color("f5d8a8"), true)
    draw_rect(Rect2(1030, 110, 105, 145), Color("fff8e8"), true)
    draw_circle(Vector2(1082, 160), 31, Color("f2a7c5"))
    draw_circle(Vector2(1082, 205), 24, Color("9cd7eb"))

    _plant(Vector2(700, 365), 1.0)
    draw_rect(Rect2(500, 125, 250, 60), Color("f4c8db"), true)
    draw_circle(Vector2(530, 155), 17, Color("fff09e"))
    draw_circle(Vector2(720, 155), 17, Color("fff09e"))

func _draw_salon() -> void:
    draw_rect(Rect2(70, 80, 330, 310), Color("f8e8f2"), true)
    draw_rect(Rect2(92, 104, 286, 244), Color("d9f4ff"), true)
    draw_circle(Vector2(235, 226), 90, Color(1.0, 1.0, 1.0, 0.32))
    for i in range(9):
        var angle := TAU * float(i) / 9.0
        var p := Vector2(235, 226) + Vector2(cos(angle), sin(angle)) * 140.0
        draw_circle(p, 10, Color("ffe68a"))
    draw_rect(Rect2(130, 365, 210, 42), Color("bb8c68"), true)
    draw_rect(Rect2(158, 407, 25, 92), Color("9e7458"), true)
    draw_rect(Rect2(288, 407, 25, 92), Color("9e7458"), true)

    draw_rect(Rect2(940, 105, 245, 330), Color("e9d7f4"), true)
    for shelf_y in [180.0, 275.0, 370.0]:
        draw_rect(Rect2(960, shelf_y, 205, 12), Color("aa82b8"), true)
    for x in [980.0, 1030.0, 1080.0, 1130.0]:
        draw_rect(Rect2(x, 130, 30, 42), Color("f3a6c9" if int(x) % 100 == 80 else "8ed5e8"), true)
    draw_circle(Vector2(995, 248), 23, Color("ffd979"))
    draw_circle(Vector2(1055, 248), 23, Color("f1a4c4"))
    draw_circle(Vector2(1115, 248), 23, Color("8ed5e8"))
    _plant(Vector2(835, 375), 0.9)

func _draw_dressing_room() -> void:
    draw_rect(Rect2(70, 95, 250, 355), Color("f1d8e9"), true)
    draw_line(Vector2(100, 140), Vector2(290, 140), Color("a9759c"), 12.0)
    for x in [125.0, 175.0, 225.0, 275.0]:
        draw_line(Vector2(x, 140), Vector2(x, 180), Color("7b5c73"), 4.0)
        _tiny_dress(Vector2(x, 220), int(x / 50.0) % 3)
    draw_rect(Rect2(940, 85, 245, 345), Color("ddf3ff"), true)
    draw_rect(Rect2(970, 115, 185, 260), Color("f9fdff"), true)
    draw_circle(Vector2(1062, 244), 80, Color(0.78, 0.92, 1.0, 0.35))
    for y in [470.0, 525.0]:
        draw_rect(Rect2(805, y, 350, 28), Color("d6b08e"), true)

func _draw_food_shop() -> void:
    draw_rect(Rect2(55, 85, 1170, 120), Color("f4c37c"), true)
    draw_rect(Rect2(80, 105, 1120, 80), Color("fff2c9"), true)
    for x in range(110, 1190, 105):
        draw_circle(Vector2(x, 145), 21, Color("f4a2be" if int(x / 105.0) % 2 == 0 else "8ed5e8"))
    draw_rect(Rect2(70, 430, 1140, 70), Color("b88966"), true)
    draw_rect(Rect2(95, 500, 1090, 90), Color("d4aa86"), true)
    draw_circle(Vector2(1135, 395), 31, Color("7ecf79"))
    draw_circle(Vector2(1095, 408), 25, Color("f4a2be"))
    draw_circle(Vector2(1055, 400), 28, Color("f6ca64"))

func _draw_photo_room() -> void:
    draw_rect(Rect2(120, 55, 760, 565), Color("ead5ef"), true)
    draw_rect(Rect2(155, 90, 690, 495), Color("fffdf9"), true)
    draw_circle(Vector2(185, 120), 14, Color("ffe27a"))
    draw_circle(Vector2(815, 120), 14, Color("ffe27a"))
    draw_circle(Vector2(185, 555), 14, Color("ffe27a"))
    draw_circle(Vector2(815, 555), 14, Color("ffe27a"))
    draw_rect(Rect2(970, 200, 155, 110), Color("3f3553"), true)
    draw_rect(Rect2(994, 220, 108, 65), Color("a8ddf2"), true)
    draw_circle(Vector2(1048, 252), 25, Color("eefaff"))
    draw_rect(Rect2(1015, 178, 65, 28), Color("635774"), true)
    draw_circle(Vector2(1103, 215), 10, Color("ffd96c"))
    _plant(Vector2(1005, 410), 1.1)

func _plant(origin: Vector2, scale_factor: float) -> void:
    draw_rect(Rect2(origin.x - 28 * scale_factor, origin.y + 55 * scale_factor, 56 * scale_factor, 48 * scale_factor), Color("d19a73"), true)
    draw_line(origin + Vector2(0, 55) * scale_factor, origin, Color("5b9a68"), 8.0 * scale_factor, true)
    for d in [Vector2(-32, -10), Vector2(30, -15), Vector2(-22, 20), Vector2(26, 18), Vector2(0, -38)]:
        draw_circle(origin + d * scale_factor, 18 * scale_factor, Color("83c98b"))

func _tiny_dress(center: Vector2, style: int) -> void:
    var color := Color("f3a5c8")
    if style == 1:
        color = Color("8ed5e8")
    elif style == 2:
        color = Color("8ac77b")
    draw_colored_polygon(PackedVector2Array([
        center + Vector2(-18, -28), center + Vector2(18, -28), center + Vector2(13, -5),
        center + Vector2(35, 38), center + Vector2(-35, 38), center + Vector2(-13, -5)
    ]), color)
