class_name MemoryDataPanel
extends Control

signal closed
signal data_changed
signal main_menu_requested

var state: GameState


func _ready() -> void:
	_build()


func configure(player_state: GameState) -> void:
	state = player_state


func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.01, 0.005, 0.02, 0.86)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := UIFactory.panel()
	panel.custom_minimum_size = Vector2(900, 650)
	center.add_child(panel)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(860, 610)
	panel.add_child(scroll)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 10)
	scroll.add_child(column)
	column.add_child(UIFactory.label("MEMORY & PRIVACY", 34, UITheme.INK, true))
	var note := UIFactory.label("Authored memories are stored only in local saves. Optional AI receives a limited snapshot only while enabled. Deleting a memory does not rewrite story flags or events.", 14, UITheme.MUTED)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(note)
	if state != null:
		column.add_child(UIFactory.label("Relationship dimensions", 18, Color("#e2a0b6"), true))
		for key in GameState.RELATIONSHIP_KEYS:
			var row := HBoxContainer.new()
			var label := UIFactory.label(String(key).capitalize(), 15, UITheme.INK)
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(label)
			row.add_child(UIFactory.label("%d / 10" % int(state.relationships.get(key, 0)), 14, Color("#c991a8")))
			column.add_child(row)
		var explanation := UIFactory.label("These dimensions are independent. Trust is not romance; attraction is not trust; comfort with teasing is not a reward for affection.", 12, Color("#8f7487"))
		explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(explanation)
		column.add_child(UIFactory.label("Active boundaries", 18, Color("#e2a0b6"), true))
		var boundaries := "None set"
		if not state.boundaries.is_empty():
			boundaries = " · ".join(state.boundaries.map(func(value: String) -> String: return value.replace("_", " ").capitalize()))
		column.add_child(UIFactory.label(boundaries, 14, UITheme.MUTED))
		column.add_child(UIFactory.label("Saved memories", 18, Color("#e2a0b6"), true))
		if state.memories.is_empty():
			column.add_child(UIFactory.label("No saved memories.", 14, UITheme.MUTED))
		for memory in state.memories:
			var row := HBoxContainer.new()
			var text := UIFactory.label(String(memory.get("text", "")), 14, UITheme.INK)
			text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(text)
			var delete := UIFactory.button("Forget")
			delete.custom_minimum_size = Vector2(100, 38)
			delete.pressed.connect(func() -> void:
				state.memories.erase(memory)
				SaveManager.save_game(state, "autosave")
				data_changed.emit()
				queue_free())
			row.add_child(delete)
			column.add_child(row)
	column.add_child(HSeparator.new())
	var delete_all := UIFactory.button("Delete all local save data")
	delete_all.pressed.connect(_confirm_delete_all)
	column.add_child(delete_all)
	var done := UIFactory.button("Back", true)
	done.pressed.connect(func() -> void: closed.emit())
	column.add_child(done)


func _confirm_delete_all() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "Delete all local saves?"
	dialog.dialog_text = "This removes the autosave and every manual slot from this device. Settings and the pseudonymous install ID remain. This cannot be undone."
	dialog.confirmed.connect(func() -> void:
		SaveManager.delete_all_data()
		main_menu_requested.emit())
	add_child(dialog)
	dialog.popup_centered(Vector2i(480, 170))
