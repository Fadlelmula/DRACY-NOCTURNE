class_name EndPanel
extends Control

signal talk_requested
signal main_menu_requested

var state: GameState
var ending: String = ""


func _ready() -> void:
	_build()


func configure(player_state: GameState, ending_id: String) -> void:
	state = player_state
	ending = ending_id


func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.015, 0.007, 0.025, 0.78)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := UIFactory.panel(Color(0.04, 0.02, 0.06, 0.97))
	panel.custom_minimum_size = Vector2(720, 0)
	center.add_child(panel)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 13)
	panel.add_child(column)
	column.add_child(UIFactory.label("PROLOGUE COMPLETE", 14, Color("#df87a3")))
	var title := "A Door Awaits" if ending == "a_door_awaits" else "Until Midnight"
	column.add_child(UIFactory.label(title, 46, UITheme.INK, true))
	var subtitle := "You made a promise. The next chapter begins on the other side." if ending == "a_door_awaits" else "You chose time. Nocturne will wait — for now."
	var sub := UIFactory.label(subtitle, 17, UITheme.MUTED)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(sub)
	if state != null:
		column.add_child(HSeparator.new())
		var stats := UIFactory.label("Trust %d  ·  Attraction %d  ·  Curiosity %d  ·  Suspicion %d\n%d authored memories saved" % [state.relationships["trust"], state.relationships["attraction"], state.relationships["curiosity"], state.relationships["suspicion"], state.memories.size()], 14, Color("#c58ca5"))
		stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		column.add_child(stats)
	var talk := UIFactory.button("Talk a little longer", true)
	talk.pressed.connect(func() -> void: talk_requested.emit())
	column.add_child(talk)
	var menu := UIFactory.button("Return to main menu")
	menu.pressed.connect(func() -> void: main_menu_requested.emit())
	column.add_child(menu)
	column.add_child(UIFactory.label("Chapter 01 is not implemented in M01. No content has been fabricated.", 11, Color("#806a7b")))
