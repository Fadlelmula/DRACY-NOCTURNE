class_name ChoiceList
extends Control
## Keyboard-accessible authored choices. AI output can never create these.

signal choice_selected(option_id: String)

var panel: PanelContainer
var list: VBoxContainer
var _buttons: Array[Button] = []


func _ready() -> void:
	visible = false
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.offset_bottom = -250
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	panel = UIFactory.panel(Color(0.04, 0.02, 0.06, 0.97))
	panel.custom_minimum_size = Vector2(900, 0)
	center.add_child(panel)
	list = VBoxContainer.new()
	list.add_theme_constant_override("separation", 9)
	panel.add_child(list)


func present(prompt: String, options: Array, state: GameState) -> void:
	for child in list.get_children():
		child.queue_free()
	_buttons.clear()
	var title := UIFactory.label(UIFactory.format_text(prompt, state), 20, Color("#e5a2b8"), true)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	list.add_child(title)
	for index in options.size():
		var option: Dictionary = options[index]
		var button := UIFactory.button("%d  ·  %s" % [index + 1, Localizer.narrative_text("choice." + String(option.get("id", "")), String(option.get("text", "")), state)])
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(0, 48)
		var option_id := String(option.get("id", ""))
		button.pressed.connect(func() -> void: choice_selected.emit(option_id))
		list.add_child(button)
		_buttons.append(button)
	visible = true
	if not _buttons.is_empty():
		_buttons[0].grab_focus()


func hide_choices() -> void:
	visible = false
	for child in list.get_children():
		child.queue_free()
	_buttons.clear()
