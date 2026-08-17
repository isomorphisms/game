extends Control

var item := "Lemonade"

func _ready() -> void:
    if custom_minimum_size.y <= 0.0:
        custom_minimum_size = Vector2(0, 72)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    queue_redraw()

func configure(new_item: String) -> void:
    item = new_item
    queue_redraw()

func _draw() -> void:
    var base := Vector2(120.0, 80.0)
    var scale_factor := min(size.x / base.x, size.y / base.y)
    if scale_factor <= 0.0:
        scale_factor = 1.0
    var offset := Vector2((size.x - base.x * scale_factor) * 0.5, (size.y - base.y * scale_factor) * 0.5)
    draw_set_transform(offset, 0.0, Vector2(scale_factor, scale_factor))

    var lower := item.to_lower()
    if "lemonade" in lower or "milk" in lower or "water" in lower or "juice" in lower or "smoothie" in lower:
        _draw_drink(lower)
    else:
        _draw_snack(lower)

    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_drink(lower: String) -> void:
    var fill := Color("f6df6a")
    if "pink" in lower or "strawberry" in lower:
        fill = Color("ef93b6")
    elif "blueberry" in lower:
        fill = Color("8f84c9")
    elif "banana" in lower:
        fill = Color("f4d978")
    elif "pineapple" in lower:
        fill = Color("f0c85c")
    elif "coconut" in lower:
        fill = Color("e7f5f1")
    elif lower == "milk" or lower == "milkshake":
        fill = Color("f7f3e9")

    draw_rect(Rect2(33, 20, 54, 48), Color("ffffff"), true)
    draw_rect(Rect2(38, 25, 44, 38), fill, true)
    draw_rect(Rect2(29, 15, 62, 9), Color("e9dce7"), true)
    draw_line(Vector2(75, 18), Vector2(91, 4), Color("6fa8c5"), 4.0, true)
    if "smoothie" in lower or "milkshake" in lower:
        draw_circle(Vector2(60, 18), 17.0, fill.lightened(0.16))
        draw_circle(Vector2(60, 10), 5.0, Color("f6a0ba"))
    if "lemon" in lower:
        draw_circle(Vector2(85, 28), 8.0, Color("ffe468"))
    elif "pineapple" in lower:
        draw_colored_polygon(PackedVector2Array([Vector2(86, 25), Vector2(92, 12), Vector2(96, 26)]), Color("78b66b"))

func _draw_snack(lower: String) -> void:
    if "croissant" in lower:
        draw_arc(Vector2(60, 43), 28.0, 0.2, PI - 0.2, 24, Color("d99b4e"), 18.0, true)
        draw_arc(Vector2(60, 43), 15.0, 0.2, PI - 0.2, 24, Color("fff3d1"), 7.0, true)
    elif lower == "buns":
        _ellipse(Vector2(60, 49), Vector2(32, 20), Color("d79b5b"))
        draw_line(Vector2(39, 43), Vector2(81, 43), Color("f0c98d"), 4.0, true)
    elif "tomato" in lower:
        draw_circle(Vector2(60, 45), 26.0, Color("e85f58"))
        _leaf_top(Vector2(60, 19))
    elif "cookie" in lower:
        draw_circle(Vector2(60, 43), 28.0, Color("c99058"))
        for p in [Vector2(48, 31), Vector2(69, 29), Vector2(74, 50), Vector2(50, 56), Vector2(59, 44)]:
            draw_circle(p, 4.0, Color("6a4638"))
    elif "cucumber" in lower:
        draw_circle(Vector2(60, 43), 29.0, Color("78bf73"))
        draw_circle(Vector2(60, 43), 21.0, Color("c9e5a6"))
        for angle in [0.0, 1.57, 3.14, 4.71]:
            draw_circle(Vector2(60, 43) + Vector2(cos(angle), sin(angle)) * 12.0, 2.5, Color("f3efc4"))
    elif "ground cherries" in lower:
        draw_circle(Vector2(48, 46), 17.0, Color("f0a94b"))
        draw_circle(Vector2(72, 46), 17.0, Color("f0a94b"))
        _leaf_top(Vector2(60, 26))
    elif "carrot" in lower:
        draw_colored_polygon(PackedVector2Array([Vector2(48, 25), Vector2(74, 27), Vector2(61, 69)]), Color("ee9447"))
        _leaf_top(Vector2(61, 23))
    elif "mango" in lower:
        _ellipse(Vector2(60, 45), Vector2(24, 31), Color("f2b84d"))
        draw_line(Vector2(63, 17), Vector2(76, 10), Color("6fae62"), 5.0, true)
    elif lower == "chips":
        _bag(Color("f2c45e"), Color("e68c53"))
    elif "chickpeas" in lower:
        _bowl(Color("e7c887"))
        for p in [Vector2(47, 44), Vector2(58, 38), Vector2(70, 45), Vector2(59, 51), Vector2(78, 38)]:
            draw_circle(p, 5.0, Color("d4b16e"))
    elif lower == "soup":
        _bowl(Color("e98c66"))
        draw_line(Vector2(50, 28), Vector2(47, 14), Color("d6c6bf"), 3.0, true)
        draw_line(Vector2(68, 28), Vector2(71, 12), Color("d6c6bf"), 3.0, true)
    elif "guacamole" in lower:
        _bowl(Color("84bf6a"))
        draw_colored_polygon(PackedVector2Array([Vector2(88, 28), Vector2(110, 33), Vector2(94, 55)]), Color("e8c75f"))
        draw_colored_polygon(PackedVector2Array([Vector2(29, 28), Vector2(10, 36), Vector2(28, 57)]), Color("e8c75f"))
    elif "gummy eyeballs" in lower:
        for x in [45.0, 75.0]:
            draw_circle(Vector2(x, 44), 17.0, Color("f4f1ec"))
            draw_circle(Vector2(x, 44), 8.0, Color("79bde2"))
            draw_circle(Vector2(x, 44), 4.0, Color("352e38"))
    elif lower == "gummies":
        for gummy in [[Vector2(42, 45), Color("ef7189")], [Vector2(62, 35), Color("f3c55c")], [Vector2(79, 51), Color("7acb87")], [Vector2(56, 56), Color("8f85d0")]]:
            draw_circle(gummy[0], 11.0, gummy[1])
    elif lower == "candy":
        draw_circle(Vector2(60, 43), 18.0, Color("f09ac1"))
        draw_colored_polygon(PackedVector2Array([Vector2(42, 43), Vector2(24, 30), Vector2(27, 56)]), Color("7ec9e4"))
        draw_colored_polygon(PackedVector2Array([Vector2(78, 43), Vector2(96, 30), Vector2(93, 56)]), Color("7ec9e4"))
    elif "lollipop" in lower:
        draw_circle(Vector2(60, 31), 23.0, Color("f087b4"))
        draw_arc(Vector2(60, 31), 14.0, 0.0, TAU * 0.8, 24, Color("fff0f7"), 4.0, true)
        draw_line(Vector2(60, 54), Vector2(60, 76), Color("d8c7aa"), 5.0, true)
    elif "gushers" in lower:
        _bag(Color("8c82ce"), Color("ef789e"))
    elif "jolly ranchers" in lower:
        draw_rect(Rect2(41, 30, 38, 28), Color("7bc4e2"), true)
        draw_colored_polygon(PackedVector2Array([Vector2(41, 44), Vector2(24, 31), Vector2(26, 57)]), Color("e98db8"))
        draw_colored_polygon(PackedVector2Array([Vector2(79, 44), Vector2(96, 31), Vector2(94, 57)]), Color("e98db8"))
    else:
        _bag(Color("f0bd62"), Color("e88496"))

func _bag(main_color: Color, accent: Color) -> void:
    draw_colored_polygon(PackedVector2Array([Vector2(35, 15), Vector2(85, 15), Vector2(91, 69), Vector2(29, 69)]), main_color)
    draw_circle(Vector2(60, 43), 15.0, accent)
    draw_line(Vector2(34, 22), Vector2(86, 22), Color("fff0c9"), 4.0, true)

func _bowl(fill: Color) -> void:
    draw_rect(Rect2(34, 32, 52, 11), fill, true)
    draw_colored_polygon(PackedVector2Array([Vector2(31, 40), Vector2(89, 40), Vector2(78, 67), Vector2(42, 67)]), Color("e9d7ee"))
    draw_line(Vector2(39, 57), Vector2(81, 57), Color("b69fc0"), 4.0, true)

func _leaf_top(center: Vector2) -> void:
    draw_colored_polygon(PackedVector2Array([center, center + Vector2(-14, -11), center + Vector2(-5, 5)]), Color("6fae62"))
    draw_colored_polygon(PackedVector2Array([center, center + Vector2(14, -11), center + Vector2(5, 5)]), Color("6fae62"))

func _ellipse(center: Vector2, radii: Vector2, color: Color, steps: int = 32) -> void:
    var points := PackedVector2Array()
    for i in range(steps):
        var angle := TAU * float(i) / float(steps)
        points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
    draw_colored_polygon(points, color)
