class_name ArtCreditsPanel
extends Control

signal closed


func _ready() -> void:
	_build()


func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.01, 0.005, 0.02, 0.86)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := UIFactory.panel()
	panel.custom_minimum_size = Vector2(1020, 700)
	center.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	column.add_child(UIFactory.label("CHARACTER ARCHIVE", 34, UITheme.INK, true))
	column.add_child(UIFactory.label("Dracy · original master design and outfit studies", 15, Color("#d793ac")))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	column.add_child(row)
	for outfit in ["signature", "casual", "gothic", "alternative"]:
		var card := VBoxContainer.new()
		var art := TextureRect.new()
		art.texture = load(SpritePaths.outfit(outfit))
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		art.custom_minimum_size = Vector2(190, 360)
		card.add_child(art)
		var label := UIFactory.label(outfit.capitalize(), 15, UITheme.MUTED, true)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.add_child(label)
		row.add_child(card)
	var credits := UIFactory.label("Art, environments, music, and sound are original project assets generated from reproducible source tools. Fonts: Cormorant Garamond and Inter under the SIL Open Font License; license files are included in game/assets/fonts/. No anime character designs, Mobile Legends artwork, logos, music, or extracted assets are used.", 13, UITheme.MUTED)
	credits.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(credits)
	var done := UIFactory.button("Back", true)
	done.pressed.connect(func() -> void: closed.emit())
	column.add_child(done)
