class_name ChatWindow
extends Control
## Diegetic messaging UI used for the online-friendship portion of the prologue.

var panel: PanelContainer
var message_list: VBoxContainer
var scroll: ScrollContainer
var typing_label: Label
var profile_card: PanelContainer


func _ready() -> void:
	var chat_margin := MarginContainer.new()
	chat_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	chat_margin.offset_left = 72
	chat_margin.offset_right = -380
	chat_margin.offset_top = 72
	chat_margin.offset_bottom = -42
	chat_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(chat_margin)
	panel = UIFactory.panel(Color(0.028, 0.016, 0.043, 0.96))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chat_margin.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	panel.add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	var avatar := PanelContainer.new()
	avatar.custom_minimum_size = Vector2(46, 46)
	avatar.add_theme_stylebox_override("panel", UITheme._box(Color("#59172f"), Color("#b93458"), 23, 1))
	var avatar_label := UIFactory.label("D", 23, Color("#ffe7ee"), true)
	avatar_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	avatar_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	avatar.add_child(avatar_label)
	header.add_child(avatar)
	var names := VBoxContainer.new()
	names.add_theme_constant_override("separation", 0)
	var name_label := UIFactory.label("dracy.nocturne", 19, UITheme.INK)
	var status := UIFactory.label("online · probably ignoring a teamfight", 12, Color("#ba8298"))
	names.add_child(name_label)
	names.add_child(status)
	header.add_child(names)
	header.add_child(UIFactory.spacer(200))
	var privacy := UIFactory.label("PRIVATE CHAT", 11, Color("#8f7387"))
	privacy.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(privacy)
	var rule := HSeparator.new()
	rule.add_theme_color_override("separator", Color(0.35, 0.16, 0.28, 0.6))
	column.add_child(rule)
	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(scroll)
	message_list = VBoxContainer.new()
	message_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_list.add_theme_constant_override("separation", 12)
	scroll.add_child(message_list)
	typing_label = UIFactory.label("Dracy is typing…", 13, Color("#c27b96"))
	typing_label.visible = false
	column.add_child(typing_label)
	var footer := UIFactory.label("A small corner of the internet. Nothing supernatural here.", 11, Color("#796273"))
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(footer)
	_build_profile_card()


func _build_profile_card() -> void:
	profile_card = UIFactory.panel(Color(0.04, 0.022, 0.06, 0.82))
	profile_card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	profile_card.offset_left = 920
	profile_card.offset_right = -72
	profile_card.offset_top = 120
	profile_card.offset_bottom = -100
	profile_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(profile_card)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	profile_card.add_child(column)
	var portrait := TextureRect.new()
	portrait.texture = load("res://assets/characters/dracy/profile.svg")
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.custom_minimum_size = Vector2(250, 250)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(portrait)
	var name_label := UIFactory.label("DRACY", 30, UITheme.INK, true)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(name_label)
	var handle := UIFactory.label("@dracy.nocturne", 13, Color("#c07d96"))
	handle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(handle)
	var bio := UIFactory.label("gothic fashion · folklore · bad decisions\n24 · Morocco · nocturnal by inconvenience", 13, Color("#aa91a5"))
	bio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(bio)
	var quote := UIFactory.label("“The vampire username is an aesthetic, not a confession.”", 15, Color("#d8b6c8"), true)
	quote.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(quote)


func clear_messages() -> void:
	for child in message_list.get_children():
		child.queue_free()


func set_typing(value: bool) -> void:
	typing_label.visible = value
	if value:
		_scroll_to_bottom()


func append_message(speaker: String, raw_text: String, state: GameState, localization_key: String = "") -> void:
	var text := Localizer.narrative_text(localization_key, raw_text, state)
	if speaker == "narrator":
		var narration := UIFactory.label(text, 14, Color("#a58b9f"))
		narration.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		narration.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		message_list.add_child(narration)
		_scroll_to_bottom()
		return
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_list.add_child(row)
	var bubble := PanelContainer.new()
	bubble.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var is_player := speaker == "player"
	var bg := Color(0.16, 0.075, 0.14, 0.96) if is_player else Color(0.075, 0.038, 0.10, 0.98)
	var border := Color(0.42, 0.20, 0.37, 0.75) if is_player else Color(0.30, 0.13, 0.27, 0.8)
	bubble.add_theme_stylebox_override("panel", UITheme._box(bg, border, 12, 1))
	if is_player:
		row.add_child(UIFactory.h_spacer(90))
	row.add_child(bubble)
	if not is_player:
		row.add_child(UIFactory.h_spacer(90))
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 3)
	bubble.add_child(content)
	var sender := UIFactory.label(state.player_name if is_player else "Dracy", 11, Color("#d784a0"))
	content.add_child(sender)
	var message := UIFactory.label(text, 17, UITheme.INK)
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(message)
	bubble.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(bubble, "modulate:a", 1.0, 0.16)
	_scroll_to_bottom()


func _scroll_to_bottom() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(scroll):
		scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
