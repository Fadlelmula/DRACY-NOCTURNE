class_name DialogueBox
extends Control
## Typewritten VN dialogue with accessible click/space advancement.

signal advance_requested

var panel: PanelContainer
var name_label: Label
var text_label: RichTextLabel
var indicator: Label
var _full_text: String = ""
var _typing: bool = false
var _characters: float = 0.0


func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	margin.offset_left = 70
	margin.offset_right = -70
	margin.offset_top = -238
	margin.offset_bottom = -34
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)
	panel = UIFactory.panel(Color(0.035, 0.018, 0.052, 0.96))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	panel.add_child(column)
	name_label = UIFactory.label("", 18, Color("#e78ca6"), true)
	name_label.visible = false
	column.add_child(name_label)
	text_label = RichTextLabel.new()
	text_label.bbcode_enabled = true
	text_label.fit_content = false
	text_label.scroll_active = false
	text_label.custom_minimum_size = Vector2(0, 112)
	text_label.add_theme_font_size_override("normal_font_size", 23)
	text_label.add_theme_color_override("default_color", UITheme.INK)
	text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(text_label)
	indicator = UIFactory.label("▾", 18, Color("#d5829c"))
	indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	indicator.visible = false
	column.add_child(indicator)
	gui_input.connect(_on_gui_input)


func present(line: Dictionary, state: GameState) -> void:
	var speaker := String(line.get("speaker", "narrator"))
	name_label.text = "DRACY" if speaker == "dracy" else (state.player_name.to_upper() if speaker == "player" else "")
	name_label.visible = speaker != "narrator"
	_full_text = Localizer.narrative_text("line." + String(line.get("id", "")), String(line.get("text", "")), state).replace("[", "[lb]")
	_characters = 0.0
	_typing = not Settings.reduced_motion
	indicator.visible = false
	if Settings.reduced_motion:
		text_label.text = _full_text
		indicator.visible = true
	else:
		text_label.text = ""
		text_label.visible_ratio = 0.0


func _process(delta: float) -> void:
	if not _typing:
		return
	_characters += delta * Settings.text_speed
	text_label.visible_ratio = clampf(_characters / maxf(1.0, float(_full_text.length())), 0.0, 1.0)
	if text_label.visible_ratio >= 1.0:
		_finish_typing()


func request_advance() -> void:
	if _typing:
		_finish_typing()
	else:
		advance_requested.emit()


func _finish_typing() -> void:
	_typing = false
	text_label.visible_ratio = 1.0
	text_label.text = _full_text
	indicator.visible = true


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		request_advance()
		accept_event()
