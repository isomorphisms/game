extends Control

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
var zebra_as_unicorn := false
var wearing_wings := false
var horn_style := "none"
var look_messy := false
var status_label: Label
var content: VBoxContainer

func _ready() -> void:
    _show_waiting_room()

func _clear_screen() -> void:
    for child in get_children():
        remove_child(child)
        child.queue_free()

    var background := ColorRect.new()
    background.color = Color("fff0f7")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(background)

    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 48)
    margin.add_theme_constant_override("margin_right", 48)
    margin.add_theme_constant_override("margin_top", 32)
    margin.add_theme_constant_override("margin_bottom", 32)
    add_child(margin)

    var scroll := ScrollContainer.new()
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    margin.add_child(scroll)

    content = VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 16)
    scroll.add_child(content)

func _title(text: String) -> void:
    var label := Label.new()
    label.text = text
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 40)
    label.add_theme_color_override("font_color", Color("5d315d"))
    content.add_child(label)

func _note(text: String) -> void:
    var label := Label.new()
    label.text = text
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 24)
    label.add_theme_color_override("font_color", Color("483848"))
    content.add_child(label)

func _heading(text: String) -> void:
    var label := Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", 30)
    label.add_theme_color_override("font_color", Color("5d315d"))
    content.add_child(label)

func _button(text: String, action: Callable) -> Button:
    var button := Button.new()
    button.text = text
    button.custom_minimum_size = Vector2(0, 64)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.add_theme_font_size_override("font_size", 26)
    button.pressed.connect(action)
    content.add_child(button)
    return button

func _status(text: String = "") -> void:
    status_label = Label.new()
    status_label.text = text
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.add_theme_font_size_override("font_size", 22)
    status_label.add_theme_color_override("font_color", Color("704070"))
    content.add_child(status_label)

func _show_waiting_room() -> void:
    animal = ""
    animal_kind = ""
    zebra_as_unicorn = false
    wearing_wings = false
    horn_style = "none"
    look_messy = false
    _clear_screen()
    _title("Dress the Unicorn")
    _note("You are the hairstylist. Choose one animal from the waiting room. Everything is tap, not drag.")
    _button("Zebra", _choose_animal.bind("Zebra", "zebra"))
    _button("Horse", _choose_animal.bind("Horse", "horse"))
    _button("Unicorn 1", _choose_animal.bind("Unicorn 1", "unicorn"))
    _button("Unicorn 2", _choose_animal.bind("Unicorn 2", "unicorn"))

func _choose_animal(chosen: String, kind: String) -> void:
    animal = chosen
    animal_kind = kind
    _show_salon()

func _show_salon() -> void:
    _clear_screen()
    _title("%s in the salon" % animal)
    if animal_kind == "unicorn":
        _note("A unicorn can get messed up while doing something relaxing, then you can redo the look.")
    elif animal_kind == "zebra":
        _note("The zebra can dress up as a unicorn. Relaxing does not mess up the zebra.")
    else:
        _note("The horse is a regular dress-up customer.")

    _button("Dress up", _show_dress_up)
    _button("Do something relaxing", _relax)
    if look_messy:
        _button("Redo the look", _redo_look)
    _button("Snacks and drinks", _show_food)
    _button("Take a photo", _show_photo_room)
    _button("Back to waiting room", _show_waiting_room)
    _status(_appearance_text())

func _show_dress_up() -> void:
    _clear_screen()
    _title("Dress up %s" % animal)
    _note("Hairstyle and makeup choices are still for the game designer to decide.")

    if animal_kind == "zebra":
        _button("Dress as a unicorn: %s" % _on_off(zebra_as_unicorn), _toggle_zebra_costume)

    if _can_use_unicorn_accessories():
        _button("Wings: %s" % _on_off(wearing_wings), _toggle_wings)
        _button("Horn: %s" % _horn_label(), _cycle_horn)
    elif animal_kind == "horse":
        _note("Wings and horns are unicorn dress-up items, so they are not shown for the horse.")

    _button("Done", _show_salon)
    _status(_appearance_text())

func _on_off(value: bool) -> String:
    return "on" if value else "off"

func _can_use_unicorn_accessories() -> bool:
    return animal_kind == "unicorn" or (animal_kind == "zebra" and zebra_as_unicorn)

func _toggle_zebra_costume() -> void:
    zebra_as_unicorn = not zebra_as_unicorn
    if not zebra_as_unicorn:
        wearing_wings = false
        horn_style = "none"
    _show_dress_up()

func _toggle_wings() -> void:
    wearing_wings = not wearing_wings
    _show_dress_up()

func _cycle_horn() -> void:
    if horn_style == "none":
        horn_style = "horn"
    elif horn_style == "horn":
        horn_style = "rainbow horn"
    else:
        horn_style = "none"
    _show_dress_up()

func _horn_label() -> String:
    if horn_style == "none":
        return "off"
    return horn_style

func _relax() -> void:
    if animal_kind == "unicorn":
        look_messy = true
        _show_salon()
        status_label.text = "The unicorn got messed up while relaxing. Tap Redo the look when you want to fix it."
    else:
        _show_salon()
        status_label.text = "%s relaxed and stayed neat." % animal

func _redo_look() -> void:
    look_messy = false
    _show_salon()
    status_label.text = "%s is fixed up again." % animal

func _show_food() -> void:
    _clear_screen()
    _title("Snack and drink shop")
    _note("Tap anything to give it to %s." % animal)
    _heading("Drinks")
    for drink in DRINKS:
        _button(drink, _picked_food.bind(drink))
    _heading("Snacks")
    for snack in SNACKS:
        _button(snack, _picked_food.bind(snack))
    _button("Back to salon", _show_salon)
    _status()

func _picked_food(item: String) -> void:
    status_label.text = "%s had %s." % [animal, item]

func _show_photo_room() -> void:
    _clear_screen()
    _title("Photo time")
    _note("%s is ready for a picture." % animal)
    if look_messy:
        _note("This unicorn is still messy from relaxing.")
    _note(_appearance_text())
    _button("Save photo", _save_photo)
    _button("Back to salon", _show_salon)
    _button("Finish this animal", _show_waiting_room)
    _status()

func _save_photo() -> void:
    await RenderingServer.frame_post_draw
    var image := get_viewport().get_texture().get_image()
    var result := image.save_png("user://dress-the-unicorn-photo.png")
    if result == OK:
        status_label.text = "Photo saved in the app's storage."
    else:
        status_label.text = "The photo could not be saved."

func _appearance_text() -> String:
    if animal == "":
        return ""

    var text := animal
    if animal_kind == "zebra" and zebra_as_unicorn:
        text += " is dressed as a unicorn"
    elif animal_kind == "zebra":
        text += " is dressed as a zebra"
    elif animal_kind == "horse":
        text += " is dressed up"
    else:
        text += " is dressed up"

    if wearing_wings:
        text += " with wings"
    if horn_style != "none":
        text += " and a %s" % horn_style if wearing_wings else " with a %s" % horn_style
    if look_messy:
        text += ", but the look is messy"
    return text + "."
