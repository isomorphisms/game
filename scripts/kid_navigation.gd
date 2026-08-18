extends Node

const TAPPABLE_PICTURE_SCRIPTS := [
    "res://scripts/animal_view.gd",
    "res://scripts/icon_view.gd",
    "res://scripts/food_icon.gd",
]
const TAP_SLOP := 28.0
const SCROLL_STEP := 320

var nav_layer: CanvasLayer
var back_button: Button
var exit_button: Button
var scroll_up_button: Button
var scroll_down_button: Button
var current_room := "waiting"
var picture_press_button: Button
var picture_press_point := Vector2.ZERO
var picture_press_cancelled := false

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    call_deferred("_build_navigation")

func _process(_delta: float) -> void:
    _sync_navigation()

func _input(event: InputEvent) -> void:
    if event.device == InputEvent.DEVICE_ID_EMULATION:
        return

    if event is InputEventScreenTouch:
        _handle_picture_pointer(event.pressed, event.position)
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        _handle_picture_pointer(event.pressed, event.position)
    elif event is InputEventScreenDrag:
        _track_picture_pointer(event.position)
    elif event is InputEventMouseMotion and picture_press_button != null:
        _track_picture_pointer(event.position)

func _handle_picture_pointer(pressed: bool, point: Vector2) -> void:
    if pressed:
        picture_press_button = _find_picture_button(get_tree().root, point)
        picture_press_point = point
        picture_press_cancelled = false
        return

    var pressed_button := picture_press_button
    var should_activate := (
        pressed_button != null
        and not picture_press_cancelled
        and is_instance_valid(pressed_button)
        and _find_picture_button(get_tree().root, point) == pressed_button
    )
    _reset_picture_pointer()

    if should_activate:
        pressed_button.call_deferred("emit_signal", "pressed")

func _track_picture_pointer(point: Vector2) -> void:
    if picture_press_button == null:
        return
    if point.distance_to(picture_press_point) > TAP_SLOP:
        picture_press_cancelled = true

func _reset_picture_pointer() -> void:
    picture_press_button = null
    picture_press_point = Vector2.ZERO
    picture_press_cancelled = false

func _build_navigation() -> void:
    nav_layer = CanvasLayer.new()
    nav_layer.layer = 100
    add_child(nav_layer)

    back_button = Button.new()
    back_button.text = "★"
    back_button.position = Vector2(18, 18)
    back_button.size = Vector2(104, 104)
    back_button.add_theme_font_size_override("font_size", 54)
    back_button.tooltip_text = "Back"
    back_button.pressed.connect(_go_back)
    nav_layer.add_child(back_button)

    exit_button = Button.new()
    exit_button.text = "✕ EXIT"
    exit_button.anchor_left = 1.0
    exit_button.anchor_right = 1.0
    exit_button.offset_left = -156.0
    exit_button.offset_right = -18.0
    exit_button.offset_top = 18.0
    exit_button.offset_bottom = 88.0
    exit_button.add_theme_font_size_override("font_size", 24)
    exit_button.tooltip_text = "Exit game"
    exit_button.pressed.connect(_exit_game)
    nav_layer.add_child(exit_button)

    scroll_up_button = Button.new()
    scroll_up_button.text = "▲"
    scroll_up_button.anchor_left = 1.0
    scroll_up_button.anchor_right = 1.0
    scroll_up_button.offset_left = -118.0
    scroll_up_button.offset_right = -18.0
    scroll_up_button.offset_top = 220.0
    scroll_up_button.offset_bottom = 308.0
    scroll_up_button.add_theme_font_size_override("font_size", 42)
    scroll_up_button.tooltip_text = "Scroll up"
    scroll_up_button.pressed.connect(_scroll_by.bind(-SCROLL_STEP))
    nav_layer.add_child(scroll_up_button)

    scroll_down_button = Button.new()
    scroll_down_button.text = "▼"
    scroll_down_button.anchor_left = 1.0
    scroll_down_button.anchor_right = 1.0
    scroll_down_button.offset_left = -118.0
    scroll_down_button.offset_right = -18.0
    scroll_down_button.offset_top = 322.0
    scroll_down_button.offset_bottom = 410.0
    scroll_down_button.add_theme_font_size_override("font_size", 42)
    scroll_down_button.tooltip_text = "Scroll down"
    scroll_down_button.pressed.connect(_scroll_by.bind(SCROLL_STEP))
    nav_layer.add_child(scroll_down_button)

    _sync_navigation()

func _sync_navigation() -> void:
    if back_button == null:
        return

    var art := _find_node_with_script(get_tree().root, "res://scripts/scene_art.gd")
    if art != null:
        current_room = str(art.get("room"))

    back_button.visible = current_room != "waiting"

    var scroll := _find_scroll_container(get_tree().root)
    var can_scroll := false
    var max_scroll := 0.0
    if scroll != null:
        var bar := scroll.get_v_scroll_bar()
        max_scroll = max(0.0, bar.max_value - bar.page)
        can_scroll = max_scroll > 1.0

    scroll_up_button.visible = can_scroll
    scroll_down_button.visible = can_scroll
    if can_scroll:
        scroll_up_button.disabled = scroll.scroll_vertical <= 0
        scroll_down_button.disabled = float(scroll.scroll_vertical) >= max_scroll - 1.0

func _go_back() -> void:
    var main := _find_node_with_script(get_tree().root, "res://scripts/main.gd")
    if main == null:
        return

    match current_room:
        "salon":
            main.call("_show_waiting_room")
        "dress", "food", "photo":
            main.call("_show_salon")
        _:
            main.call("_show_waiting_room")

func _exit_game() -> void:
    get_tree().quit()

func _scroll_by(amount: int) -> void:
    var scroll := _find_scroll_container(get_tree().root)
    if scroll == null:
        return
    var bar := scroll.get_v_scroll_bar()
    var max_scroll := int(max(0.0, bar.max_value - bar.page))
    scroll.scroll_vertical = clampi(scroll.scroll_vertical + amount, 0, max_scroll)

func _find_picture_button(node: Node, point: Vector2) -> Button:
    var children := node.get_children()
    for i in range(children.size() - 1, -1, -1):
        var found := _find_picture_button(children[i], point)
        if found != null:
            return found

    if not (node is Control):
        return null

    var control := node as Control
    if not control.is_visible_in_tree() or not control.get_global_rect().has_point(point):
        return null

    var script: Script = control.get_script() as Script
    if script == null or not (script.resource_path in TAPPABLE_PICTURE_SCRIPTS):
        return null

    var parent := control.get_parent()
    if parent == null:
        return null

    var next_index := control.get_index() + 1
    if next_index >= parent.get_child_count():
        return null

    var next := parent.get_child(next_index)
    if next is Button and next.visible and not next.disabled:
        return next as Button

    return null

func _find_scroll_container(node: Node) -> ScrollContainer:
    if node is ScrollContainer and node.is_visible_in_tree():
        return node as ScrollContainer

    for child in node.get_children():
        var found := _find_scroll_container(child)
        if found != null:
            return found

    return null

func _find_node_with_script(node: Node, script_path: String) -> Node:
    var script: Script = node.get_script() as Script
    if script != null and script.resource_path == script_path:
        return node

    for child in node.get_children():
        var found := _find_node_with_script(child, script_path)
        if found != null:
            return found

    return null
