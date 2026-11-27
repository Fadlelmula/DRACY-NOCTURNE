class_name BacklogPanel
extends Control

signal closed

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
	panel.custom_minimum_size = Vector2(920, 620)
	center.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	column.add_child(UIFactory.label("TRANSCRIPT", 34, UITheme.INK, true))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 12)
	scroll.add_child(list)
	if state != null:
		for entry in state.history:
			var speaker := String(entry.get("speaker", "narrator"))
			var name_text := "Dracy" if speaker == "dracy" else (state.player_name if speaker == "player" else "Narration")
			var line := UIFactory.label("%s\n%s" % [name_text.to_upper(), UIFactory.format_text(String(entry.get("text", "")), state)], 16, UITheme.INK if speaker != "narrator" else UITheme.MUTED)
			line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			list.add_child(line)
	var done := UIFactory.button("Back", true)
	done.pressed.connect(func() -> void: closed.emit())
	column.add_child(done)
