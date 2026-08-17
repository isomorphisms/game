extends Control

var icon_id := "dress"

func _ready() -> void:
    if custom_minimum_size.y <= 0.0:
        custom_minimum_size = Vector2(0, 82)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    queue_redraw()

func configure(new_icon_id: String) -> void:
    icon_id = new_icon_id
    queue_redraw()

func _draw() -> void:
    var base := Vector2(140.0, 90.0)
    var scale_factor := min(size.x / base.x, size.y / base.y)
    if scale_factor <= 0.0:
        scale_factor = 1.0
    var offset := Vector2((size.x - base.x * scale_factor) * 0.5, (size.y - base.y * scale_factor) * 0.5)
    draw_set_transform(offset, 0.0, Vector2(scale_factor, scale_factor))

    match icon_id:
        "dress":
            _dress_icon()
        "relax":
            _relax_icon()
        "food":
            _food_icon()
        "camera":
            _camera_icon()
        "waiting":
            _waiting_icon()
        "wings":
            _wings_icon()
        "horn":
            _horn_icon(false)
        "rainbow_horn":
            _horn_icon(true)
        "hair1":
            _hair_icon(1)
        "hair2":
            _hair_icon(2)
        "hair3":
            _hair_icon(3)
        "makeup1":
            _makeup_icon(1)
        "makeup2":
            _makeup_icon(2)
        "makeup3":
            _makeup_icon(3)
        "unicorn":
            _unicorn_icon()
        "done":
            _done_icon()
        _:
            _sparkle_icon()

    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _dress_icon() -> void:
    draw_colored_polygon(PackedVector2Array([
        Vector2(55, 12), Vector2(85, 12), Vector2(90, 32), Vector2(113, 76),
        Vector2(27, 76), Vector2(50, 32)
    ]), Color("f2a3c8"))
    draw_line(Vector2(51, 36), Vector2(89, 36), Color("fff5fa"), 5.0, true)
    draw_circle(Vector2(70, 36), 5.0, Color("ffe17a"))

func _relax_icon() -> void:
    draw_rect(Rect2(25, 43, 88, 31), Color("b7def1"), true)
    draw_circle(Vector2(40, 58), 17.0, Color("e7f7ff"))
    draw_arc(Vector2(87, 34), 19.0, 0.1, PI - 0.1, 20, Color("917bb8"), 5.0, true)
    _star(Vector2(105, 17), 9.0, Color("ffe274"))
    _star(Vector2(74, 16), 6.0, Color("f3a3c8"))

func _food_icon() -> void:
    draw_rect(Rect2(28, 27, 34, 48), Color("f4b3c9"), true)
    draw_rect(Rect2(25, 22, 40, 8), Color("ffffff"), true)
    draw_line(Vector2(54, 22), Vector2(68, 7), Color("78a8bf"), 4.0, true)
    draw_circle(Vector2(95, 49), 23.0, Color("f5ca63"))
    draw_colored_polygon(PackedVector2Array([Vector2(92, 28), Vector2(103, 13), Vector2(105, 32)]), Color("76b66e"))

func _camera_icon() -> void:
    draw_rect(Rect2(24, 28, 92, 50), Color("554963"), true)
    draw_rect(Rect2(45, 18, 35, 13), Color("75677f"), true)
    draw_circle(Vector2(70, 53), 19.0, Color("d9f3ff"))
    draw_circle(Vector2(70, 53), 10.0, Color("77b8d5"))
    draw_circle(Vector2(102, 40), 5.0, Color("ffe073"))

func _waiting_icon() -> void:
    draw_rect(Rect2(23, 44, 94, 28), Color("d8a8c8"), true)
    draw_rect(Rect2(32, 29, 76, 29), Color("edc9df"), true)
    draw_circle(Vector2(36, 69), 12.0, Color("bd86ad"))
    draw_circle(Vector2(104, 69), 12.0, Color("bd86ad"))
    draw_rect(Rect2(92, 7, 27, 32), Color("f5d7a5"), true)

func _wings_icon() -> void:
    draw_colored_polygon(PackedVector2Array([
        Vector2(65, 45), Vector2(19, 14), Vector2(11, 31), Vector2(39, 52), Vector2(18, 65), Vector2(58, 74)
    ]), Color("e7d8ff"))
    draw_colored_polygon(PackedVector2Array([
        Vector2(75, 45), Vector2(121, 14), Vector2(129, 31), Vector2(101, 52), Vector2(122, 65), Vector2(82, 74)
    ]), Color("d8f0ff"))

func _horn_icon(rainbow: bool) -> void:
    var color := Color("f1c85f") if not rainbow else Color("f08ac2")
    draw_colored_polygon(PackedVector2Array([Vector2(50, 75), Vector2(72, 7), Vector2(90, 75)]), color)
    if rainbow:
        draw_line(Vector2(58, 53), Vector2(85, 47), Color("79c8ff"), 6.0, true)
        draw_line(Vector2(62, 39), Vector2(81, 35), Color("81d987"), 6.0, true)
        draw_line(Vector2(66, 25), Vector2(77, 22), Color("ffd96e"), 6.0, true)

func _hair_icon(style: int) -> void:
    draw_circle(Vector2(70, 50), 26.0, Color("f5efe7"))
    if style == 1:
        draw_arc(Vector2(70, 48), 30.0, PI, TAU, 24, Color("6a4335"), 12.0, true)
    elif style == 2:
        draw_arc(Vector2(70, 48), 31.0, PI, TAU, 24, Color("e395cf"), 13.0, true)
        for y in [47.0, 61.0, 75.0]:
            draw_circle(Vector2(101, y), 7.0, Color("e395cf"))
    else:
        for p in [Vector2(45, 36), Vector2(58, 26), Vector2(72, 24), Vector2(86, 27), Vector2(98, 38)]:
            draw_circle(p, 10.0, Color("79cbdc"))
    draw_circle(Vector2(60, 50), 3.0, Color("352d37"))
    draw_circle(Vector2(80, 50), 3.0, Color("352d37"))

func _makeup_icon(style: int) -> void:
    draw_circle(Vector2(70, 48), 29.0, Color("f6eee6"))
    draw_circle(Vector2(59, 44), 4.0, Color("3b2d39"))
    draw_circle(Vector2(81, 44), 4.0, Color("3b2d39"))
    if style == 1:
        draw_circle(Vector2(50, 56), 7.0, Color(0.95, 0.42, 0.62, 0.55))
        draw_circle(Vector2(90, 56), 7.0, Color(0.95, 0.42, 0.62, 0.55))
    elif style == 2:
        draw_arc(Vector2(59, 43), 8.0, PI, TAU, 12, Color("9270d4"), 4.0, true)
        draw_arc(Vector2(81, 43), 8.0, PI, TAU, 12, Color("9270d4"), 4.0, true)
    else:
        _star(Vector2(92, 58), 7.0, Color("f2a0c3"))

func _unicorn_icon() -> void:
    draw_circle(Vector2(70, 50), 27.0, Color("faf5ff"))
    draw_colored_polygon(PackedVector2Array([Vector2(62, 29), Vector2(70, 3), Vector2(77, 30)]), Color("f1cc66"))
    draw_arc(Vector2(67, 38), 27.0, 3.4, 5.7, 18, Color("e392cf"), 10.0, true)
    draw_circle(Vector2(60, 48), 3.0, Color("352d37"))
    draw_circle(Vector2(79, 48), 3.0, Color("352d37"))

func _done_icon() -> void:
    draw_circle(Vector2(70, 45), 34.0, Color("86cc83"))
    draw_line(Vector2(50, 45), Vector2(64, 60), Color("ffffff"), 8.0, true)
    draw_line(Vector2(64, 60), Vector2(94, 29), Color("ffffff"), 8.0, true)

func _sparkle_icon() -> void:
    _star(Vector2(70, 45), 26.0, Color("ffe274"))
    _star(Vector2(108, 24), 9.0, Color("f1a0c3"))
    _star(Vector2(32, 68), 7.0, Color("82cee5"))

func _star(center: Vector2, radius: float, color: Color) -> void:
    var points := PackedVector2Array()
    for i in range(10):
        var r := radius if i % 2 == 0 else radius * 0.42
        var angle := -PI / 2.0 + float(i) * PI / 5.0
        points.append(center + Vector2(cos(angle), sin(angle)) * r)
    draw_colored_polygon(points, color)
