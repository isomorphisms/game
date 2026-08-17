extends Control

var outfit_index := 0
var unicorn_costume := false
var wearing_wings := false
var horn_style := "none"
var messy := false

var _eyes_open := true
var _blink_timer: Timer
var _open_timer: Timer

func _ready() -> void:
    custom_minimum_size = Vector2(0, 310)
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
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

func configure(new_outfit: int, as_unicorn: bool, wings: bool, new_horn_style: String, is_messy: bool) -> void:
    outfit_index = new_outfit
    unicorn_costume = as_unicorn
    wearing_wings = wings
    horn_style = new_horn_style
    messy = is_messy
    queue_redraw()

func _schedule_blink() -> void:
    if is_inside_tree():
        _blink_timer.start(randf_range(1.5, 3.3))

func _begin_blink() -> void:
    _eyes_open = false
    queue_redraw()
    _open_timer.start(0.13)

func _finish_blink() -> void:
    _eyes_open = true
    queue_redraw()
    _schedule_blink()

func _draw() -> void:
    var base_size := Vector2(640.0, 300.0)
    var width_scale: float = size.x / base_size.x
    var height_scale: float = size.y / base_size.y
    var scale_factor: float = width_scale
    if height_scale < scale_factor:
        scale_factor = height_scale
    if scale_factor <= 0.0:
        scale_factor = 1.0
    var offset := Vector2((size.x - base_size.x * scale_factor) * 0.5, (size.y - base_size.y * scale_factor) * 0.5)
    draw_set_transform(offset, 0.0, Vector2(scale_factor, scale_factor))

    _ellipse(Vector2(325, 268), Vector2(215, 18), Color("e7cddd"))

    if wearing_wings:
        _ellipse(Vector2(255, 120), Vector2(92, 48), Color("e8dcff"))
        _ellipse(Vector2(360, 112), Vector2(96, 52), Color("d8ecff"))
        draw_line(Vector2(210, 120), Vector2(292, 92), Color("9c86bf"), 4.0, true)
        draw_line(Vector2(332, 104), Vector2(410, 80), Color("8aa6c0"), 4.0, true)

    draw_line(Vector2(162, 174), Vector2(102, 134), Color("161616"), 9.0, true)
    draw_line(Vector2(103, 134), Vector2(83, 126), Color("161616"), 15.0, true)

    for x in [215.0, 285.0, 365.0, 425.0]:
        draw_rect(Rect2(x, 198, 25, 69), Color("f7f5f2"), true)
        draw_rect(Rect2(x, 246, 25, 21), Color("1d1d1d"), true)

    _ellipse(Vector2(320, 166), Vector2(165, 76), Color("f7f5f2"))
    _ellipse(Vector2(445, 138), Vector2(56, 83), Color("f7f5f2"))

    for stripe in [
        [Vector2(195, 124), Vector2(236, 195)],
        [Vector2(232, 101), Vector2(267, 212)],
        [Vector2(276, 92), Vector2(302, 224)],
        [Vector2(326, 91), Vector2(338, 226)],
        [Vector2(375, 100), Vector2(370, 218)],
        [Vector2(418, 112), Vector2(405, 204)],
    ]:
        draw_line(stripe[0], stripe[1], Color("1b1b1b"), 13.0, true)

    draw_line(Vector2(421, 88), Vector2(469, 165), Color("1b1b1b"), 11.0, true)
    draw_line(Vector2(438, 74), Vector2(483, 137), Color("1b1b1b"), 10.0, true)

    _ellipse(Vector2(500, 91), Vector2(69, 53), Color("f7f5f2"))
    _ellipse(Vector2(549, 112), Vector2(46, 29), Color("d9d1cd"))

    draw_colored_polygon(PackedVector2Array([Vector2(467, 51), Vector2(454, 10), Vector2(491, 42)]), Color("1b1b1b"))
    draw_colored_polygon(PackedVector2Array([Vector2(520, 47), Vector2(542, 12), Vector2(545, 55)]), Color("1b1b1b"))
    draw_line(Vector2(447, 62), Vector2(430, 129), Color("1b1b1b"), 17.0, true)

    draw_line(Vector2(474, 51), Vector2(493, 81), Color("1b1b1b"), 8.0, true)
    draw_line(Vector2(510, 43), Vector2(519, 76), Color("1b1b1b"), 8.0, true)
    draw_line(Vector2(541, 73), Vector2(557, 93), Color("1b1b1b"), 7.0, true)

    if _eyes_open:
        draw_circle(Vector2(493, 82), 7.5, Color("111111"))
        draw_circle(Vector2(495, 79), 2.0, Color("ffffff"))
        draw_circle(Vector2(526, 81), 7.5, Color("111111"))
        draw_circle(Vector2(528, 78), 2.0, Color("ffffff"))
    else:
        draw_line(Vector2(485, 83), Vector2(501, 83), Color("111111"), 4.0, true)
        draw_line(Vector2(518, 82), Vector2(534, 82), Color("111111"), 4.0, true)

    draw_circle(Vector2(557, 108), 3.5, Color("55504e"))
    draw_circle(Vector2(575, 111), 3.5, Color("55504e"))
    draw_arc(Vector2(557, 119), 14.0, 0.15, 1.45, 16, Color("6b5757"), 2.5, true)

    if outfit_index == 1:
        draw_colored_polygon(PackedVector2Array([
            Vector2(215, 120), Vector2(388, 110), Vector2(430, 190), Vector2(235, 210)
        ]), Color("e9a5d1"))
        draw_line(Vector2(231, 138), Vector2(407, 130), Color("ffffff"), 5.0, true)
        draw_circle(Vector2(407, 142), 9.0, Color("fff3a8"))
    elif outfit_index == 2:
        draw_rect(Rect2(245, 172, 150, 26), Color("9edbf0"), true)
        for x in [255.0, 285.0, 315.0, 345.0, 375.0]:
            draw_colored_polygon(PackedVector2Array([
                Vector2(x, 198), Vector2(x + 16, 224), Vector2(x + 32, 198)
            ]), Color("c4ecf8"))
        draw_colored_polygon(PackedVector2Array([
            Vector2(451, 137), Vector2(427, 122), Vector2(429, 151), Vector2(451, 141)
        ]), Color("75bdd7"))
        draw_colored_polygon(PackedVector2Array([
            Vector2(451, 137), Vector2(475, 121), Vector2(473, 151), Vector2(451, 141)
        ]), Color("75bdd7"))
        draw_circle(Vector2(451, 138), 7.0, Color("fff3a8"))

    if unicorn_costume and horn_style != "none":
        var horn_color: Color = Color("f4d36b") if horn_style == "horn" else Color("f18ac5")
        draw_colored_polygon(PackedVector2Array([
            Vector2(510, 44), Vector2(525, -2), Vector2(532, 48)
        ]), horn_color)
        if horn_style == "rainbow horn":
            draw_line(Vector2(516, 30), Vector2(529, 26), Color("7bc7ff"), 5.0, true)
            draw_line(Vector2(519, 18), Vector2(528, 15), Color("8ee08e"), 5.0, true)
            draw_line(Vector2(522, 8), Vector2(527, 6), Color("ffd66b"), 5.0, true)

    if messy:
        draw_line(Vector2(463, 47), Vector2(444, 24), Color("1b1b1b"), 5.0, true)
        draw_line(Vector2(478, 43), Vector2(473, 18), Color("1b1b1b"), 5.0, true)
        draw_line(Vector2(493, 42), Vector2(506, 17), Color("1b1b1b"), 5.0, true)

    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _ellipse(center: Vector2, radii: Vector2, color: Color, steps: int = 48) -> void:
    var points := PackedVector2Array()
    for i in range(steps):
        var angle := TAU * float(i) / float(steps)
        points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
    draw_colored_polygon(points, color)
