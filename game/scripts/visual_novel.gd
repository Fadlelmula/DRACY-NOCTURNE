class_name VisualNovel
extends Control
## Scene coordinator. NarrativeEngine owns authored state mutations; this class
## owns presentation, input, local persistence, and optional non-canonical chat.

static var launch_mode: String = "new"
static var launch_player_name: String = "Player"
static var launch_slot: String = "autosave"

const CHAPTER_PATH := "res://content/chapters/prologue.json"
const CATALOG_PATH := "res://content/narrative_catalog.json"

var state: GameState
var engine: NarrativeEngine
var catalog: Dictionary
var background: TextureRect
var portrait: CharacterView
var chat: ChatWindow
var dialogue: DialogueBox
var choices: ChoiceList
var top_bar: HBoxContainer
var chapter_label: Label
var save_indicator: Label
var modal_layer: Control
var transition: ColorRect
var toast_panel: PanelContainer
var toast_label: Label
var current_modal: Control
var end_panel: EndPanel
var _presenting: bool = false
var _presentation_token: int = 0
var _background_tween: Tween
var _autosave_elapsed: float = 0.0
var _current_background: String = ""
var _launched: bool = false
var _skip_save_on_exit: bool = false


func _ready() -> void:
	theme = UITheme.create()
	_build_world()
	_build_components()
	_build_navigation()
	_build_feedback()
	_launch()


func _build_world() -> void:
	background = TextureRect.new()
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.006, 0.025, 0.24)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var vignette := TextureRect.new()
	vignette.texture = load("res://assets/ui/vignette.svg")
	vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vignette.stretch_mode = TextureRect.STRETCH_SCALE
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette)


func _build_components() -> void:
	portrait = load("res://scenes/ui/character_view.tscn").instantiate()
	portrait.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	portrait.position = Vector2(662, 12)
	portrait.size = Vector2(570, 708)
	add_child(portrait)
	chat = load("res://scenes/ui/chat_window.tscn").instantiate()
	add_child(chat)
	dialogue = load("res://scenes/ui/dialogue_box.tscn").instantiate()
	add_child(dialogue)
	dialogue.advance_requested.connect(_advance)
	choices = load("res://scenes/ui/choice_list.tscn").instantiate()
	add_child(choices)
	choices.choice_selected.connect(_on_choice_selected)
	modal_layer = Control.new()
	modal_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	modal_layer.z_index = 100
	add_child(modal_layer)
	transition = ColorRect.new()
	transition.color = Color(0.015, 0.006, 0.025, 0.0)
	transition.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transition.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition.z_index = 90
	add_child(transition)


func _build_navigation() -> void:
	top_bar = HBoxContainer.new()
	top_bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_left = 30
	top_bar.offset_right = -30
	top_bar.offset_top = 18
	top_bar.offset_bottom = 62
	top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_bar)
	chapter_label = UIFactory.label("PROLOGUE · THE GIRL BEHIND THE SCREEN", 13, Color("#d39ab0"), true)
	chapter_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chapter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_bar.add_child(chapter_label)
	save_indicator = UIFactory.label("Autosave ready", 11, Color("#9b8194"))
	save_indicator.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_bar.add_child(save_indicator)
	for item in [["Log", _open_backlog], ["Save", _open_save], ["Load", _open_load], ["Data", _open_data], ["Settings", _open_settings], ["Menu", _return_to_menu]]:
		var button := UIFactory.button(String(item[0]))
		button.custom_minimum_size = Vector2(78, 34)
		button.add_theme_font_size_override("font_size", 13)
		button.pressed.connect(item[1])
		top_bar.add_child(button)


func _build_feedback() -> void:
	toast_panel = UIFactory.panel(Color(0.075, 0.035, 0.095, 0.96), Color(0.55, 0.22, 0.38, 0.8), 10)
	toast_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	toast_panel.offset_left = -270
	toast_panel.offset_right = 270
	toast_panel.offset_top = 76
	toast_panel.offset_bottom = 126
	toast_panel.visible = false
	toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(toast_panel)
	toast_label = UIFactory.label("", 14, Color("#f0bfd0"))
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_panel.add_child(toast_label)


func _launch() -> void:
	catalog = _read_json(CATALOG_PATH)
	engine = NarrativeEngine.new()
	engine.line_presented.connect(_on_line_presented)
	engine.choices_presented.connect(_on_choices_presented)
	engine.scene_changed.connect(_on_scene_changed)
	engine.progress_changed.connect(_on_progress_changed)
	engine.effects_applied.connect(_on_effects_applied)
	engine.chapter_finished.connect(_on_chapter_finished)
	engine.error_occurred.connect(_on_narrative_error)
	if launch_mode == "load":
		state = SaveManager.load_game(launch_slot)
		if state == null:
			_show_error("This save could not be read. A backup was checked automatically. You can return to the main menu and start a new journey.")
			return
		if not engine.load_chapter(CHAPTER_PATH, catalog):
			_show_error("The authored chapter failed validation. The game has stopped safely instead of showing broken content.")
			return
		engine.restore(state)
		if state.scene_id == "p020_promise_ending" or state.scene_id == "p020_undecided_ending":
			chat.clear_messages()
		engine.advance()
	else:
		state = GameState.new_game(launch_player_name)
		if not engine.load_chapter(CHAPTER_PATH, catalog):
			_show_error("The authored chapter failed validation. The game has stopped safely instead of showing broken content.")
			return
		engine.start(state)
	_launched = true
	SaveManager.save_game(state, "autosave")
	_show_chapter_card()


func _on_scene_changed(scene: Dictionary) -> void:
	var mode := String(scene.get("mode", "vn"))
	chat.visible = mode == "chat"
	dialogue.visible = mode != "chat"
	portrait.visible = mode == "vn"
	choices.hide_choices()
	_change_background(String(scene.get("background", "bedroom")))
	var music := String(scene.get("music", ""))
	if not music.is_empty():
		Audio.play_music(music)
	if scene.get("background") == "rain_window":
		Audio.play_ambience("rain")
	else:
		Audio.stop_ambience()
	chapter_label.text = "PROLOGUE · " + String(scene.get("title", "")).to_upper()


func _change_background(name: String) -> void:
	if name == _current_background:
		return
	var path := "res://assets/backgrounds/%s.svg" % name
	if not ResourceLoader.exists(path):
		push_warning("VisualNovel: missing background %s" % path)
		return
	_current_background = name
	if _background_tween != null and _background_tween.is_valid():
		_background_tween.kill()
	if Settings.reduced_motion:
		background.texture = load(path)
		background.modulate.a = 1.0
		return
	_background_tween = create_tween()
	_background_tween.tween_property(background, "modulate:a", 0.0, 0.22)
	_background_tween.tween_callback(func() -> void: background.texture = load(path))
	_background_tween.tween_property(background, "modulate:a", 1.0, 0.38)


func _on_line_presented(line: Dictionary) -> void:
	_present_line(line)


func _present_line(line: Dictionary) -> void:
	_presenting = true
	_presentation_token += 1
	var token := _presentation_token
	choices.hide_choices()
	var speaker := String(line.get("speaker", "narrator"))
	if speaker == "dracy" and portrait.visible:
		portrait.set_expression(String(line.get("expression", "neutral")))
	var delay := 0.0
	if speaker == "dracy" and chat.visible:
		delay = float(line.get("delay", 0.8))
		chat.set_typing(delay > 0.05)
		if delay > 0.05:
			await get_tree().create_timer(delay if not Settings.reduced_motion else 0.08).timeout
	if token != _presentation_token or not is_instance_valid(self):
		return
	chat.set_typing(false)
	if chat.visible:
		chat.append_message(speaker, String(line.get("text", "")), state, "line." + String(line.get("id", "")))
	else:
		dialogue.present(line, state)
	if speaker != "narrator":
		Audio.play_sfx("message")
	_presenting = false


func _on_choices_presented(options: Array) -> void:
	_presenting = false
	choices.present(engine.current_choice_prompt, options, state)
	Audio.play_sfx("click")


func _on_choice_selected(option_id: String) -> void:
	if engine.pending_choices.is_empty():
		return
	if chat.visible:
		for option in engine.pending_choices:
			if option.get("id") == option_id:
				chat.append_message("player", String(option.get("text", "")), state, "choice." + String(option.get("id", "")))
				break
	Audio.play_sfx("click")
	engine.choose(option_id)


func _advance() -> void:
	if not _launched or _presenting or current_modal != null or not engine.pending_choices.is_empty() or engine.finished:
		return
	if dialogue.visible and dialogue._typing:
		dialogue.request_advance()
		return
	engine.advance()


func _unhandled_input(event: InputEvent) -> void:
	if current_modal != null or not _launched:
		return
	var advance := false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		advance = true
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_SPACE, KEY_ENTER]:
		advance = true
	if advance:
		_advance()
		get_viewport().set_input_as_handled()


func _on_progress_changed() -> void:
	if state == null:
		return
	state.updated_at = Time.get_unix_time_from_system()
	if SaveManager.save_game(state, "autosave"):
		save_indicator.text = "Autosaved"


func _on_effects_applied(effects: Array, _source_id: String) -> void:
	var messages: Array[String] = []
	for effect in effects:
		if effect.get("type") == "relationship":
			var dimension := String(effect.get("key", "")).capitalize()
			var delta := int(effect.get("delta", 0))
			messages.append("%s %s%d · %s" % [dimension, "+" if delta > 0 else "", delta, String(effect.get("reason", ""))])
	if not messages.is_empty():
		_show_toast("\n".join(messages))


func _show_toast(text: String) -> void:
	toast_label.text = text
	toast_panel.visible = true
	toast_panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(toast_panel, "modulate:a", 1.0, 0.18)
	tween.tween_interval(3.2)
	tween.tween_property(toast_panel, "modulate:a", 0.0, 0.35)
	tween.tween_callback(func() -> void: toast_panel.visible = false)


func _on_chapter_finished(ending: String) -> void:
	SaveManager.save_game(state, "autosave")
	await get_tree().create_timer(0.8 if not Settings.reduced_motion else 0.1).timeout
	_show_end_panel(ending)


func _show_end_panel(ending: String) -> void:
	if end_panel != null and is_instance_valid(end_panel):
		end_panel.queue_free()
	end_panel = load("res://scenes/ui/end_panel.tscn").instantiate()
	end_panel.configure(state, ending)
	modal_layer.add_child(end_panel)
	current_modal = end_panel
	end_panel.talk_requested.connect(_open_free_chat)
	end_panel.main_menu_requested.connect(_return_to_menu)


func _open_free_chat() -> void:
	if end_panel != null:
		end_panel.queue_free()
	var panel: FreeChatPanel = load("res://scenes/ui/free_chat_panel.tscn").instantiate()
	panel.configure(state)
	modal_layer.add_child(panel)
	current_modal = panel
	panel.closed.connect(func() -> void:
		current_modal = null
		panel.queue_free()
		var ending := "a_door_awaits" if state.flags.get("promised_to_meet", false) else "until_midnight"
		_show_end_panel(ending))


func _open_settings() -> void:
	var panel: SettingsPanel = load("res://scenes/ui/settings_panel.tscn").instantiate()
	modal_layer.add_child(panel)
	current_modal = panel
	panel.closed.connect(_close_modal)


func _open_save() -> void:
	var panel: SavePanel = load("res://scenes/ui/save_panel.tscn").instantiate()
	panel.configure(state, "save")
	modal_layer.add_child(panel)
	current_modal = panel
	panel.closed.connect(_close_modal)


func _open_load() -> void:
	var panel: SavePanel = load("res://scenes/ui/save_panel.tscn").instantiate()
	panel.configure(state, "load")
	modal_layer.add_child(panel)
	current_modal = panel
	panel.closed.connect(_close_modal)
	panel.load_requested.connect(func(slot: String) -> void: _load_slot(slot))


func _load_slot(slot: String) -> void:
	var loaded := SaveManager.load_game(slot)
	if loaded == null:
		_show_error("That save could not be loaded.")
		return
	_close_modal()
	state = loaded
	engine.restore(state)
	chat.clear_messages()
	engine.advance()
	SaveManager.save_game(state, "autosave")


func _open_backlog() -> void:
	var panel: BacklogPanel = load("res://scenes/ui/backlog_panel.tscn").instantiate()
	panel.configure(state)
	modal_layer.add_child(panel)
	current_modal = panel
	panel.closed.connect(_close_modal)


func _open_data() -> void:
	var panel: MemoryDataPanel = load("res://scenes/ui/memory_data_panel.tscn").instantiate()
	panel.configure(state)
	modal_layer.add_child(panel)
	current_modal = panel
	panel.closed.connect(_close_modal)
	panel.main_menu_requested.connect(func() -> void:
		_skip_save_on_exit = true
		_return_to_menu())


func _close_modal() -> void:
	if current_modal != null:
		current_modal.queue_free()
		current_modal = null


func _return_to_menu() -> void:
	if state != null and not _skip_save_on_exit:
		SaveManager.save_game(state, "autosave")
	Audio.stop_ambience()
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _on_narrative_error(message: String) -> void:
	_show_error(message)


func _show_error(message: String) -> void:
	_close_modal()
	var panel := UIFactory.panel()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -360
	panel.offset_right = 360
	panel.offset_top = -150
	panel.offset_bottom = 150
	modal_layer.add_child(panel)
	current_modal = panel
	var column := VBoxContainer.new()
	panel.add_child(column)
	column.add_child(UIFactory.label("THE DOOR DID NOT OPEN", 28, Color("#e89ab3"), true))
	var text := UIFactory.label(message, 16, UITheme.INK)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(text)
	var back := UIFactory.button("Return to main menu", true)
	back.pressed.connect(_return_to_menu)
	column.add_child(back)


func _show_chapter_card() -> void:
	var card := ColorRect.new()
	card.color = Color(0.015, 0.006, 0.025, 0.96)
	card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.z_index = 200
	add_child(card)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(center)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(column)
	var overline := UIFactory.label("PROLOGUE", 15, Color("#d77e9c"))
	overline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(overline)
	var title := UIFactory.label("The Girl Behind the Screen", 50, UITheme.INK, true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var subtitle := UIFactory.label("An ordinary night. An unusual message.", 16, UITheme.MUTED)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(subtitle)
	if Settings.reduced_motion:
		await get_tree().create_timer(0.8).timeout
		card.queue_free()
		return
	card.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(card, "modulate:a", 1.0, 0.45)
	tween.tween_interval(2.2)
	tween.tween_property(card, "modulate:a", 0.0, 0.6)
	tween.tween_callback(card.queue_free)


func _process(delta: float) -> void:
	if state == null or not _launched:
		return
	state.play_seconds += delta
	_autosave_elapsed += delta
	if _autosave_elapsed >= 30.0:
		_autosave_elapsed = 0.0
		SaveManager.save_game(state, "autosave")


func _read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed if parsed is Dictionary else {}
