class_name SettingsPanel
extends Control

signal closed

var master_slider: HSlider
var music_slider: HSlider
var sfx_slider: HSlider
var speed_slider: HSlider
var motion_check: CheckBox
var fullscreen_check: CheckBox
var ai_check: CheckBox
var endpoint_edit: LineEdit


func _ready() -> void:
	_build()


func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.01, 0.005, 0.02, 0.84)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := UIFactory.panel()
	panel.custom_minimum_size = Vector2(740, 610)
	center.add_child(panel)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(700, 560)
	panel.add_child(scroll)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 12)
	scroll.add_child(column)
	column.add_child(UIFactory.label("SETTINGS", 36, UITheme.INK, true))
	column.add_child(UIFactory.label("Audio", 18, Color("#e49ab2"), true))
	master_slider = _add_slider(column, "Master volume", Settings.master_volume * 100.0)
	music_slider = _add_slider(column, "Music volume", Settings.music_volume * 100.0)
	sfx_slider = _add_slider(column, "Interface & ambience", Settings.sfx_volume * 100.0)
	for slider in [master_slider, music_slider, sfx_slider]:
		slider.value_changed.connect(_update_volumes)
		slider.drag_ended.connect(func(_changed: bool) -> void: Settings.save_settings())
	column.add_child(HSeparator.new())
	column.add_child(UIFactory.label("Text & display", 18, Color("#e49ab2"), true))
	speed_slider = _add_slider(column, "Text speed", Settings.text_speed)
	speed_slider.min_value = 8.0
	speed_slider.max_value = 120.0
	speed_slider.step = 1.0
	speed_slider.value_changed.connect(func(value: float) -> void: Settings.text_speed = value)
	speed_slider.drag_ended.connect(func(_changed: bool) -> void: Settings.save_settings())
	motion_check = CheckBox.new()
	motion_check.text = "Reduce motion and animation"
	motion_check.button_pressed = Settings.reduced_motion
	motion_check.toggled.connect(func(value: bool) -> void:
		Settings.reduced_motion = value
		Settings.save_settings())
	column.add_child(motion_check)
	fullscreen_check = CheckBox.new()
	fullscreen_check.text = "Fullscreen"
	fullscreen_check.button_pressed = Settings.fullscreen
	fullscreen_check.toggled.connect(func(value: bool) -> void:
		Settings.fullscreen = value
		Settings.apply_all()
		Settings.save_settings())
	column.add_child(fullscreen_check)
	column.add_child(HSeparator.new())
	column.add_child(UIFactory.label("Optional AI conversation", 18, Color("#e49ab2"), true))
	var ai_note := UIFactory.label("The authored story is always offline. AI only powers optional post-prologue conversation through a backend you control. Never enter an API key here.", 14, UITheme.MUTED)
	ai_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(ai_note)
	ai_check = CheckBox.new()
	ai_check.text = "Enable optional AI conversation"
	ai_check.button_pressed = Settings.ai_enabled
	ai_check.toggled.connect(func(value: bool) -> void:
		Settings.ai_enabled = value
		Settings.save_settings())
	column.add_child(ai_check)
	column.add_child(UIFactory.label("Public backend URL", 13, Color("#b994a8")))
	endpoint_edit = LineEdit.new()
	endpoint_edit.text = Settings.ai_endpoint
	endpoint_edit.placeholder_text = "http://127.0.0.1:8787"
	endpoint_edit.text_submitted.connect(_save_endpoint)
	column.add_child(endpoint_edit)
	column.add_child(UIFactory.label("Language: English · additional locales can be added without code changes.", 12, Color("#806a7b")))
	var done := UIFactory.button("Done", true)
	done.pressed.connect(func() -> void: closed.emit())
	column.add_child(done)


func _add_slider(parent: VBoxContainer, title: String, value: float) -> HSlider:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	parent.add_child(box)
	var row := HBoxContainer.new()
	var label := UIFactory.label(title, 14, UITheme.MUTED)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var value_label := UIFactory.label(str(int(value)), 13, Color("#d59ab1"))
	row.add_child(value_label)
	box.add_child(row)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0
	slider.value = value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(func(new_value: float) -> void: value_label.text = str(int(new_value)))
	box.add_child(slider)
	return slider


func _update_volumes(_value: float) -> void:
	Settings.master_volume = master_slider.value / 100.0
	Settings.music_volume = music_slider.value / 100.0
	Settings.sfx_volume = sfx_slider.value / 100.0
	Settings.apply_all()


func _save_endpoint(value: String) -> void:
	Settings.ai_endpoint = Settings.sanitize_endpoint(value)
	endpoint_edit.text = Settings.ai_endpoint
	Settings.save_settings()
