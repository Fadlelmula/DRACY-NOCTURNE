class_name SavePanel
extends Control

signal closed
signal load_requested(slot: String)
signal data_changed

var state: GameState
var mode: String = "save"
var list: VBoxContainer


func _ready() -> void:
	_build()


func configure(player_state: GameState, panel_mode: String) -> void:
	state = player_state
	mode = panel_mode


func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.01, 0.005, 0.02, 0.84)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := UIFactory.panel()
	panel.custom_minimum_size = Vector2(820, 590)
	center.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	panel.add_child(column)
	var title := UIFactory.label("SAVE PROGRESS" if mode == "save" else "LOAD PROGRESS", 34, UITheme.INK, true)
	column.add_child(title)
	var note := UIFactory.label("Progress is also autosaved after every line and choice. Manual slots are never overwritten without your action.", 13, UITheme.MUTED)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(note)
	var autosave_info := SaveManager.get_save_info("autosave")
	var autosave_text := "Autosave: " + (_describe(autosave_info) if not autosave_info.is_empty() else "No autosave yet")
	column.add_child(UIFactory.label(autosave_text, 13, Color("#c58aa2")))
	list = VBoxContainer.new()
	list.add_theme_constant_override("separation", 8)
	column.add_child(list)
	_refresh_slots()
	var done := UIFactory.button("Back", true)
	done.pressed.connect(func() -> void: closed.emit())
	column.add_child(done)


func _refresh_slots() -> void:
	for child in list.get_children():
		child.queue_free()
	for index in 3:
		var slot := "slot_%d" % (index + 1)
		var row := UIFactory.panel(Color(0.065, 0.035, 0.085, 0.92), Color(0.32, 0.15, 0.28, 0.7), 10)
		list.add_child(row)
		var content := HBoxContainer.new()
		row.add_child(content)
		var info := SaveManager.get_save_info(slot)
		var text := VBoxContainer.new()
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text.add_theme_constant_override("separation", 2)
		text.add_child(UIFactory.label("SLOT %d" % (index + 1), 15, Color("#e2a0b6"), true))
		text.add_child(UIFactory.label(_describe(info) if not info.is_empty() else "Empty", 13, UITheme.MUTED))
		content.add_child(text)
		if mode == "save":
			var save := UIFactory.button("Save here")
			save.custom_minimum_size = Vector2(130, 40)
			save.pressed.connect(func() -> void: _save_to(slot))
			content.add_child(save)
		else:
			var load := UIFactory.button("Load")
			load.custom_minimum_size = Vector2(110, 40)
			load.disabled = info.is_empty()
			load.pressed.connect(func() -> void: load_requested.emit(slot))
			content.add_child(load)
		if not info.is_empty():
			var delete := UIFactory.button("Delete")
			delete.custom_minimum_size = Vector2(100, 40)
			delete.pressed.connect(func() -> void: _confirm_delete(slot))
			content.add_child(delete)


func _save_to(slot: String) -> void:
	if state == null:
		return
	if SaveManager.save_game(state, slot):
		Audio.play_sfx("click")
		_refresh_slots()
		data_changed.emit()


func _confirm_delete(slot: String) -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "Delete this save?"
	dialog.dialog_text = "This cannot be undone. The autosave and other manual slots are not affected."
	dialog.confirmed.connect(func() -> void:
		SaveManager.delete_save(slot)
		_refresh_slots()
		data_changed.emit())
	add_child(dialog)
	dialog.popup_centered(Vector2i(440, 150))


func _describe(info: Dictionary) -> String:
	var chapter := String(info.get("chapter", "prologue")).capitalize()
	var timestamp := Time.get_datetime_string_from_unix_time(int(info.get("updated_at", 0)), true)
	var minutes := int(float(info.get("play_seconds", 0.0)) / 60.0)
	return "%s · %s · %d min" % [chapter, timestamp, minutes]
