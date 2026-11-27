class_name NewGamePanel
extends Control
## Content notice, age confirmation, and optional first-name entry.

signal start_requested(player_name: String)
signal cancelled

var age_check: CheckBox
var name_edit: LineEdit
var start_button: Button


func _ready() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.01, 0.005, 0.02, 0.82)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := UIFactory.panel()
	panel.custom_minimum_size = Vector2(680, 0)
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)
	column.add_child(UIFactory.label("BEFORE THE DOOR OPENS", 14, Color("#d77d9a")))
	column.add_child(UIFactory.label("DRACY: NOCTURNE", 40, UITheme.INK, true))
	var notice := UIFactory.label("This story is intended for adults 18+. It contains dark fantasy themes, supernatural danger, psychological tension, strong language, and optional flirtation. The prologue contains no explicit sexual content.", 17, UITheme.MUTED)
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(notice)
	column.add_child(HSeparator.new())
	age_check = CheckBox.new()
	age_check.text = "I confirm that I am 18 years of age or older."
	age_check.toggled.connect(_update_start_state)
	age_check.button_pressed = Settings.content_accepted
	_update_start_state(age_check.button_pressed)
	column.add_child(age_check)
	column.add_child(UIFactory.label("What should Dracy call you? (optional)", 14, Color("#c495aa")))
	name_edit = LineEdit.new()
	name_edit.placeholder_text = "Your first name or nickname"
	name_edit.max_length = 24
	column.add_child(name_edit)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_END
	column.add_child(row)
	var cancel := UIFactory.button("Back")
	cancel.pressed.connect(func() -> void: cancelled.emit())
	row.add_child(cancel)
	start_button = UIFactory.button("Begin the prologue", true)
	start_button.disabled = true
	start_button.pressed.connect(_start)
	row.add_child(start_button)
	age_check.grab_focus()


func _update_start_state(_checked: bool) -> void:
	start_button.disabled = not age_check.button_pressed


func _start() -> void:
	if not age_check.button_pressed:
		return
	Settings.content_accepted = true
	Settings.save_settings()
	start_requested.emit(name_edit.text.strip_edges())
