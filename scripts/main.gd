extends Control

const AnimalView = preload("res://scripts/animal_view.gd")
const SceneArt = preload("res://scripts/scene_art.gd")
const IconView = preload("res://scripts/icon_view.gd")
const FoodIcon = preload("res://scripts/food_icon.gd")

const DEBUG_UI := false

const DRINKS := [
    "Lemonade",
    "Pink lemonade",
    "Milk",
    "Milkshake",
    "Strawberry milkshake",
    "Coconut water",
    "Pineapple juice",
    "Banana smoothie",
    "Blueberry smoothie",
    "Strawberry smoothie",
    "Pineapple smoothie",
]

const SNACKS := [
    "Croissants",
    "Buns",
    "Tomatoes",
    "Cookies",
    "Cucumbers",
    "Ground cherries",
    "Carrots",
    "Mango",
    "Chips",
    "Chickpeas",
    "Soup",
    "Guacamole and chips",
    "Gummy eyeballs",
    "Gummies",
    "Candy",
    "Lollipops",
    "Gushers",
    "Jolly Ranchers",
]

var animal := ""
var animal_kind := ""
var animal_variant := 0
var zebra_as_unicorn := false
var outfit_index := 0
var hair_index := 0
var makeup_index := 0
var wearing_wings := false
var horn_style := "none"
var look_messy := false
var last_food := ""
var photo_saved := false

var content: VBoxContainer

func _ready() -> void:
    _show_waiting_room()

func _clear_screen(room: String) -> void:
    for child in get_children():
        remove_child(child)
        child.queue_free()

    var backdrop = SceneArt.new()
    backdrop.configure(room)
    add_child(backdrop)

    var shade := ColorRect.new()
    shade.color = Color(1.0, 1.0, 1.0, 0.10)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(shade)

    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 36)
    margin.add_theme_constant_override("margin_right", 36)
    margin.add_theme_constant_override("margin_top", 20)
    margin.add_theme_constant_override("margin_bottom", 22)
    add_child(margin)

    content = VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 12)
    margin.add_child(content)

func _header(title: String, subtitle: String = "") -> void:
    var title_label := Label.new()
    title_label.text = title
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_label.add_theme_font_size_override("font_size", 38)
    title_label.add_theme_color_override("font_color", Color("5b365f"))
    content.add_child(title_label)

    if subtitle != "":
        var sub := Label.new()
        sub.text = subtitle
        sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        sub.add_theme_font_size_override("font_size", 20)
        sub.add_theme_color_override("font_color", Color("725e75"))
        content.add_child(sub)

func _panel(bg: Color = Color(1.0, 1.0, 1.0, 0.90)) -> PanelContainer:
    var panel := PanelContainer.new()
    var style := StyleBoxFlat.new()
    style.bg_color = bg
    style.corner_radius_top_left = 18
    style.corner_radius_top_right = 18
    style.corner_radius_bottom_left = 18
    style.corner_radius_bottom_right = 18
    style.border_width_left = 2
    style.border_width_top = 2
    style.border_width_right = 2
    style.border_width_bottom = 2
    style.border_color = Color(0.42, 0.28, 0.43, 0.16)
    style.content_margin_left = 10.0
    style.content_margin_right = 10.0
    style.content_margin_top = 10.0
    style.content_margin_bottom = 10.0
    panel.add_theme_stylebox_override("panel", style)
    return panel

func _button(parent: Node, text: String, action: Callable, min_height: int = 54) -> Button:
    var button := Button.new()
    button.text = text
    button.custom_minimum_size = Vector2(0, min_height)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.add_theme_font_size_override("font_size", 20)
    button.pressed.connect(action)
    parent.add_child(button)
    return button

func _section_label(parent: Node, text: String) -> void:
    var label := Label.new()
    label.text = text
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 24)
    label.add_theme_color_override("font_color", Color("5b365f"))
    parent.add_child(label)

func _debug_state(parent: Node) -> void:
    if not DEBUG_UI:
        return
    var debug := Label.new()
    debug.text = "DEBUG: " + _appearance_text()
    debug.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    debug.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    debug.add_theme_font_size_override("font_size", 15)
    debug.add_theme_color_override("font_color", Color("7a3f6e"))
    parent.add_child(debug)

func _new_animal_view():
    return _make_animal_view(
        animal_kind, animal_variant, outfit_index, hair_index, makeup_index,
        zebra_as_unicorn, wearing_wings, horn_style, look_messy
    )

func _make_animal_view(
    kind: String,
    variant: int,
    outfit: int,
    hair: int,
    makeup: int,
    as_unicorn: bool,
    wings: bool,
    horn: String,
    messy: bool
):
    var view = AnimalView.new()
    view.configure(kind, variant, outfit, hair, makeup, as_unicorn, wings, horn, messy)
    return view

func _icon_action(parent: Node, icon_id: String, label: String, action: Callable) -> VBoxContainer:
    var card := VBoxContainer.new()
    card.custom_minimum_size = Vector2(155, 132)
    card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    card.add_theme_constant_override("separation", 4)
    var icon = IconView.new()
    icon.custom_minimum_size = Vector2(0, 72)
    icon.configure(icon_id)
    card.add_child(icon)
    _button(card, label, action, 46)
    parent.add_child(card)
    return card

func _animal_card(parent: Node, label: String, kind: String, variant: int, action: Callable) -> void:
    var panel := _panel(Color(1.0, 1.0, 1.0, 0.94))
    panel.custom_minimum_size = Vector2(250, 455)
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    parent.add_child(panel)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 5)
    panel.add_child(box)

    var view = _make_animal_view(kind, variant, 0, 0, 0, false, false, "none", false)
    view.custom_minimum_size = Vector2(0, 350)
    box.add_child(view)
    _button(box, label, action, 58)

func _show_waiting_room() -> void:
    animal = ""
    animal_kind = ""
    animal_variant = 0
    zebra_as_unicorn = false
    outfit_index = 0
    hair_index = 0
    makeup_index = 0
    wearing_wings = false
    horn_style = "none"
    look_messy = false
    last_food = ""
    photo_saved = false

    _clear_screen("waiting")
    _header("Dress the Unicorn", "Tap one animal in the waiting room")

    var grid := GridContainer.new()
    grid.columns = 4
    grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
    grid.add_theme_constant_override("h_separation", 14)
    content.add_child(grid)

    _animal_card(grid, "Zebra", "zebra", 0, _choose_animal.bind("Zebra", "zebra", 0))
    _animal_card(grid, "Horse", "horse", 0, _choose_animal.bind("Horse", "horse", 0))
    _animal_card(grid, "Unicorn 1", "unicorn", 0, _choose_animal.bind("Unicorn 1", "unicorn", 0))
    _animal_card(grid, "Unicorn 2", "unicorn", 1, _choose_animal.bind("Unicorn 2", "unicorn", 1))

func _choose_animal(chosen: String, kind: String, variant: int) -> void:
    animal = chosen
    animal_kind = kind
    animal_variant = variant
    if animal_kind == "unicorn":
        horn_style = "horn"
    _show_salon()

func _show_salon() -> void:
    _clear_screen("salon")
    _header("%s in the salon" % animal)

    var row := HBoxContainer.new()
    row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.size_flags_vertical = Control.SIZE_EXPAND_FILL
    row.add_theme_constant_override("separation", 18)
    content.add_child(row)

    var animal_panel := _panel(Color(1.0, 1.0, 1.0, 0.72))
    animal_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    animal_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    animal_panel.custom_minimum_size = Vector2(720, 0)
    row.add_child(animal_panel)
    var animal_view = _new_animal_view()
    animal_view.custom_minimum_size = Vector2(0, 500)
    animal_panel.add_child(animal_view)

    var actions_panel := _panel(Color(1.0, 0.97, 1.0, 0.94))
    actions_panel.custom_minimum_size = Vector2(430, 0)
    actions_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    row.add_child(actions_panel)

    var actions := GridContainer.new()
    actions.columns = 2
    actions.add_theme_constant_override("h_separation", 10)
    actions.add_theme_constant_override("v_separation", 10)
    actions_panel.add_child(actions)

    _icon_action(actions, "dress", "Dress up", _show_dress_up)
    _icon_action(actions, "relax", "Relax", _relax)
    _icon_action(actions, "food", "Snacks", _show_food)
    _icon_action(actions, "camera", "Photo", _show_photo_room)
    _icon_action(actions, "waiting", "Waiting room", _show_waiting_room)
    if look_messy and animal_kind == "unicorn":
        _icon_action(actions, "done", "Redo look", _redo_look)
    else:
        _icon_action(actions, "done", "All done", _show_photo_room)

    _debug_state(content)

func _show_dress_up() -> void:
    _clear_screen("dress")
    _header("Dress up %s" % animal)

    var row := HBoxContainer.new()
    row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.size_flags_vertical = Control.SIZE_EXPAND_FILL
    row.add_theme_constant_override("separation", 16)
    content.add_child(row)

    var preview_panel := _panel(Color(1.0, 1.0, 1.0, 0.80))
    preview_panel.custom_minimum_size = Vector2(620, 0)
    preview_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    preview_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    row.add_child(preview_panel)
    var preview = _new_animal_view()
    preview.custom_minimum_size = Vector2(0, 510)
    preview_panel.add_child(preview)

    var choices_panel := _panel(Color(1.0, 0.98, 1.0, 0.96))
    choices_panel.custom_minimum_size = Vector2(560, 0)
    choices_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    row.add_child(choices_panel)

    var scroll := ScrollContainer.new()
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    choices_panel.add_child(scroll)

    var choices := VBoxContainer.new()
    choices.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    choices.add_theme_constant_override("separation", 12)
    scroll.add_child(choices)

    _section_label(choices, "Outfits")
    var outfits := GridContainer.new()
    outfits.columns = 2
    outfits.add_theme_constant_override("h_separation", 10)
    outfits.add_theme_constant_override("v_separation", 10)
    choices.add_child(outfits)
    for i in range(4):
        _outfit_choice(outfits, i)

    _section_label(choices, "Hair")
    var hairs := GridContainer.new()
    hairs.columns = 3
    hairs.add_theme_constant_override("h_separation", 8)
    choices.add_child(hairs)
    _icon_action(hairs, "hair1", "Natural", _set_hair.bind(0))
    _icon_action(hairs, "hair2", "Braid", _set_hair.bind(1))
    _icon_action(hairs, "hair3", "Curly", _set_hair.bind(2))

    _section_label(choices, "Makeup")
    var makeup := GridContainer.new()
    makeup.columns = 3
    makeup.add_theme_constant_override("h_separation", 8)
    choices.add_child(makeup)
    _icon_action(makeup, "makeup1", "None", _set_makeup.bind(0))
    _icon_action(makeup, "makeup2", "Blush", _set_makeup.bind(1))
    _icon_action(makeup, "makeup3", "Sparkle", _set_makeup.bind(2))

    if animal_kind == "zebra":
        _section_label(choices, "Unicorn costume")
        var zebra_costume := GridContainer.new()
        zebra_costume.columns = 2
        choices.add_child(zebra_costume)
        _icon_action(zebra_costume, "unicorn", "Costume off", _set_zebra_costume.bind(false))
        _icon_action(zebra_costume, "unicorn", "Costume on", _set_zebra_costume.bind(true))

    if _can_use_unicorn_accessories():
        _section_label(choices, "Unicorn accessories")
        var accessories := GridContainer.new()
        accessories.columns = 3
        accessories.add_theme_constant_override("h_separation", 8)
        choices.add_child(accessories)
        _icon_action(accessories, "wings", "Wings", _toggle_wings)
        _icon_action(accessories, "horn", "Gold horn", _set_horn.bind("horn"))
        _icon_action(accessories, "rainbow_horn", "Rainbow", _set_horn.bind("rainbow horn"))
        if animal_kind == "zebra":
            _icon_action(accessories, "done", "No horn", _set_horn.bind("none"))

    _icon_action(choices, "done", "Done", _show_salon)
    _debug_state(choices)

func _outfit_choice(parent: Node, index: int) -> void:
    var panel := _panel(Color(1.0, 1.0, 1.0, 0.94))
    panel.custom_minimum_size = Vector2(245, 250)
    parent.add_child(panel)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 3)
    panel.add_child(box)

    var view = _make_animal_view(animal_kind, animal_variant, index, hair_index, makeup_index, zebra_as_unicorn, wearing_wings, horn_style, false)
    view.custom_minimum_size = Vector2(0, 188)
    box.add_child(view)

    var names := ["No outfit", "Pink dress", "Blue dress", "Green overalls"]
    _button(box, names[index], _set_outfit.bind(index), 44)

func _set_outfit(index: int) -> void:
    outfit_index = index
    _show_dress_up()

func _set_hair(index: int) -> void:
    hair_index = index
    look_messy = false
    _show_dress_up()

func _set_makeup(index: int) -> void:
    makeup_index = index
    _show_dress_up()

func _set_zebra_costume(enabled: bool) -> void:
    zebra_as_unicorn = enabled
    if not enabled:
        wearing_wings = false
        horn_style = "none"
    _show_dress_up()

func _can_use_unicorn_accessories() -> bool:
    return animal_kind == "unicorn" or (animal_kind == "zebra" and zebra_as_unicorn)

func _toggle_wings() -> void:
    wearing_wings = not wearing_wings
    _show_dress_up()

func _set_horn(style: String) -> void:
    horn_style = style
    _show_dress_up()

func _relax() -> void:
    if animal_kind == "unicorn":
        look_messy = true
    _show_salon()

func _redo_look() -> void:
    look_messy = false
    _show_salon()

func _show_food() -> void:
    _clear_screen("food")
    _header("Snack and drink shop")

    var row := HBoxContainer.new()
    row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.size_flags_vertical = Control.SIZE_EXPAND_FILL
    row.add_theme_constant_override("separation", 14)
    content.add_child(row)

    var customer_panel := _panel(Color(1.0, 1.0, 1.0, 0.88))
    customer_panel.custom_minimum_size = Vector2(330, 0)
    customer_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    row.add_child(customer_panel)
    var customer_box := VBoxContainer.new()
    customer_box.add_theme_constant_override("separation", 8)
    customer_panel.add_child(customer_box)
    var view = _new_animal_view()
    view.custom_minimum_size = Vector2(0, 320)
    customer_box.add_child(view)
    if last_food != "":
        _section_label(customer_box, "Just picked")
        var chosen_icon = FoodIcon.new()
        chosen_icon.custom_minimum_size = Vector2(0, 90)
        chosen_icon.configure(last_food)
        customer_box.add_child(chosen_icon)
        var chosen_label := Label.new()
        chosen_label.text = last_food
        chosen_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        chosen_label.add_theme_font_size_override("font_size", 18)
        customer_box.add_child(chosen_label)
    _button(customer_box, "Back to salon", _show_salon, 52)

    var shop_panel := _panel(Color(1.0, 0.99, 0.94, 0.96))
    shop_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    shop_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    row.add_child(shop_panel)
    var scroll := ScrollContainer.new()
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    shop_panel.add_child(scroll)
    var grid := GridContainer.new()
    grid.columns = 4
    grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    grid.add_theme_constant_override("h_separation", 9)
    grid.add_theme_constant_override("v_separation", 9)
    scroll.add_child(grid)

    for drink in DRINKS:
        _food_card(grid, drink)
    for snack in SNACKS:
        _food_card(grid, snack)

func _food_card(parent: Node, item: String) -> void:
    var panel := _panel(Color(1.0, 1.0, 1.0, 0.94))
    panel.custom_minimum_size = Vector2(190, 142)
    parent.add_child(panel)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 3)
    panel.add_child(box)
    var icon = FoodIcon.new()
    icon.custom_minimum_size = Vector2(0, 76)
    icon.configure(item)
    box.add_child(icon)
    _button(box, item, _picked_food.bind(item), 52)

func _picked_food(item: String) -> void:
    last_food = item
    _show_food()

func _show_photo_room() -> void:
    _clear_screen("photo")
    _header("Photo time")

    var row := HBoxContainer.new()
    row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.size_flags_vertical = Control.SIZE_EXPAND_FILL
    row.add_theme_constant_override("separation", 16)
    content.add_child(row)

    var photo_panel := _panel(Color(1.0, 1.0, 1.0, 0.46))
    photo_panel.custom_minimum_size = Vector2(850, 0)
    photo_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    photo_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    row.add_child(photo_panel)
    var view = _new_animal_view()
    view.custom_minimum_size = Vector2(0, 510)
    photo_panel.add_child(view)

    var controls := _panel(Color(1.0, 0.98, 1.0, 0.94))
    controls.custom_minimum_size = Vector2(300, 0)
    controls.size_flags_vertical = Control.SIZE_EXPAND_FILL
    row.add_child(controls)
    var control_box := VBoxContainer.new()
    control_box.alignment = BoxContainer.ALIGNMENT_CENTER
    control_box.add_theme_constant_override("separation", 14)
    controls.add_child(control_box)
    _icon_action(control_box, "camera", "Save photo", _save_photo)
    if photo_saved:
        _icon_action(control_box, "done", "Photo saved", _show_photo_room)
    _icon_action(control_box, "dress", "Back to salon", _show_salon)
    _icon_action(control_box, "waiting", "Finish animal", _show_waiting_room)

    _debug_state(content)

func _save_photo() -> void:
    await RenderingServer.frame_post_draw
    var image := get_viewport().get_texture().get_image()
    var result := image.save_png("user://dress-the-unicorn-photo.png")
    photo_saved = result == OK
    _show_photo_room()

func _appearance_text() -> String:
    if animal == "":
        return "no animal selected"
    var parts := PackedStringArray()
    parts.append(animal)
    parts.append("outfit=%d" % outfit_index)
    parts.append("hair=%d" % hair_index)
    parts.append("makeup=%d" % makeup_index)
    parts.append("zebra_unicorn=%s" % zebra_as_unicorn)
    parts.append("wings=%s" % wearing_wings)
    parts.append("horn=%s" % horn_style)
    parts.append("messy=%s" % look_messy)
    return " ".join(parts)
