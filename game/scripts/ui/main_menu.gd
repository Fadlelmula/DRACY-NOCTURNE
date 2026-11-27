class_name MainMenu
extends Control

var continue_button: Button
var continue_info: Label
var portrait: CharacterView
var _expression_index: int = 0
var _expressions := ["smiling", "mischievous", "neutral", "sarcastic"]


func _ready() -> void:
	theme = UITheme.create()
	_build_background()
	_build_title()
	_build_menu()
	_build_footer()
	Audio.play_music("prologue_theme", 2.5)
	_refresh_continue()
	if not Settings.reduced_motion:
		var timer := Timer.new()
		timer.wait_time = 6.5
		timer.autostart = true
		timer.timeout.connect(_next_expression)
		add_child(timer)
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.8)


func _build_background() -> void:
	var background := TextureRect.new()
	background.texture = load("res://assets/backgrounds/menu_nocturne.svg")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var left_shade := ColorRect.new()
	left_shade.color = Color(0.018, 0.008, 0.03, 0.86)
	left_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	left_shade.offset_right = 850
	left_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(left_shade)
	var gradient := ColorRect.new()
	gradient.color = Color(0.02, 0.008, 0.03, 0.18)
	gradient.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gradient.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(gradient)
	portrait = load("res://scenes/ui/character_view.tscn").instantiate()
	portrait.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	portrait.position = Vector2(748, 38)
	portrait.size = Vector2(500, 682)
	portrait.set_expression("smiling")
	add_child(portrait)


func _build_title() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.offset_left = 82
	margin.offset_top = 68
	margin.offset_right = -780
	margin.offset_bottom = -50
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	margin.add_child(column)
	var overline := UIFactory.label("A DARK FANTASY VISUAL NOVEL", 12, Color("#d2809b"))
	overline.add_theme_constant_override("outline_size", 0)
	column.add_child(overline)
	var title := UIFactory.label("DRACY", 82, Color("#f6e9ef"), true)
	column.add_child(title)
	var subtitle := UIFactory.label("N O C T U R N E", 27, Color("#c45a7c"), true)
	column.add_child(subtitle)
	var rule := HSeparator.new()
	rule.custom_minimum_size = Vector2(330, 12)
	rule.add_theme_color_override("separator", Color(0.55, 0.18, 0.34, 0.7))
	column.add_child(rule)
	var tagline := UIFactory.label("Some friendships begin with a message.\nOthers begin with a door.", 19, Color("#c6adbd"), true)
	tagline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(tagline)
	column.add_child(UIFactory.spacer(26))


func _build_menu() -> void:
	var column := VBoxContainer.new()
	column.position = Vector2(82, 382)
	column.custom_minimum_size = Vector2(330, 0)
	column.add_theme_constant_override("separation", 9)
	add_child(column)
	var new_game := UIFactory.button("New Game", true)
	new_game.pressed.connect(_open_new_game)
	column.add_child(new_game)
	continue_button = UIFactory.button("Continue")
	continue_button.pressed.connect(_continue_game)
	column.add_child(continue_button)
	continue_info = UIFactory.label("", 11, Color("#947687"))
	continue_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(continue_info)
	var settings := UIFactory.button("Settings")
	settings.pressed.connect(_open_settings)
	column.add_child(settings)
	var archive := UIFactory.button("Character Archive")
	archive.pressed.connect(_open_archive)
	column.add_child(archive)
	var quit := UIFactory.button("Quit")
	quit.pressed.connect(func() -> void: Audio.request_quit())
	column.add_child(quit)


func _build_footer() -> void:
	var left := UIFactory.label("M01 · THE GIRL BEHIND THE SCREEN", 11, Color("#866c80"))
	left.position = Vector2(82, 674)
	add_child(left)
	var right := UIFactory.label("OFFLINE READY  ·  18+", 11, Color("#b77d93"))
	right.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	right.offset_left = -260
	right.offset_top = -42
	right.offset_right = -82
	right.offset_bottom = -18
	right.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(right)


func _open_new_game() -> void:
	Audio.play_sfx("click")
	var panel: NewGamePanel = load("res://scenes/ui/new_game_panel.tscn").instantiate()
	add_child(panel)
	panel.start_requested.connect(func(player_name: String) -> void:
		VisualNovel.launch_mode = "new"
		VisualNovel.launch_player_name = player_name
		VisualNovel.launch_slot = "autosave"
		get_tree().change_scene_to_file("res://scenes/visual_novel/visual_novel.tscn"))
	panel.cancelled.connect(panel.queue_free)


func _open_settings() -> void:
	Audio.play_sfx("click")
	var panel: SettingsPanel = load("res://scenes/ui/settings_panel.tscn").instantiate()
	add_child(panel)
	panel.closed.connect(panel.queue_free)


func _open_archive() -> void:
	Audio.play_sfx("click")
	var panel: ArtCreditsPanel = load("res://scenes/ui/art_credits_panel.tscn").instantiate()
	add_child(panel)
	panel.closed.connect(panel.queue_free)


func _continue_game() -> void:
	var slot := _latest_save_slot()
	if slot.is_empty():
		return
	Audio.play_sfx("click")
	VisualNovel.launch_mode = "load"
	VisualNovel.launch_slot = slot
	VisualNovel.launch_player_name = "Player"
	get_tree().change_scene_to_file("res://scenes/visual_novel/visual_novel.tscn")


func _latest_save_slot() -> String:
	var best_slot := ""
	var best_time := -1.0
	for slot in SaveManager.SLOTS:
		var info := SaveManager.get_save_info(slot)
		if not info.is_empty() and float(info.get("updated_at", 0.0)) > best_time:
			best_time = float(info["updated_at"])
			best_slot = slot
	return best_slot


func _refresh_continue() -> void:
	var slot := _latest_save_slot()
	continue_button.disabled = slot.is_empty()
	if slot.is_empty():
		continue_info.text = "No saved journey"
		return
	var info := SaveManager.get_save_info(slot)
	continue_info.text = "%s · %d min" % [String(info.get("chapter", "Prologue")).capitalize(), int(float(info.get("play_seconds", 0.0)) / 60.0)]


func _next_expression() -> void:
	_expression_index = (_expression_index + 1) % _expressions.size()
	portrait.set_expression(_expressions[_expression_index])
