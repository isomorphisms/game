extends Node

const TAPPABLE_PICTURE_SCRIPTS := [
    "res://scripts/animal_view.gd",
    "res://scripts/icon_view.gd",
    "res://scripts/food_icon.gd",
]

var nav_layer: CanvasLayer
var back_button: Button
var exit_button: Button
var current_room := "waiting"

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    call_deferred("_build_navigation")

func _process(_delta: float) -> void:
    _sync_navigation()

func _input(event: InputEvent) -> void:
    var pressed := false
    var point := Vector2.ZERO

    if event is InputEventScreenTouch:
        pressed = event.pressed
        point = event.position
    elif event is InputEventMouseButton:
        pressed = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
        point = event.position

    if pressed and _tap_picture_at(point):
        get_viewport().set_input_as_handled()

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

    _sync_navigation()

func _sync_navigation() -> void:
    if back_button == null:
        return

    var art := _find_node_with_script(get_tree().root, "res://scripts/scene_art.gd")
    if art != null:
        current_room = str(art.get("room"))

    back_button.visible = current_room != "waiting"

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

func _tap_picture_at(point: Vector2) -> bool:
    var button := _find_picture_button(get_tree().root, point)
    if button == null:
        return false
    button.call_deferred("emit_signal", "pressed")
    return true

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

    var script := control.get_script()
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

func _find_node_with_script(node: Node, script_path: String) -> Node:
    var script := node.get_script()
    if script != null and script.resource_path == script_path:
        return node

    for child in node.get_children():
        var found := _find_node_with_script(child, script_path)
        if found != null:
            return found

    return null
