class_name UITheme
extends RefCounted
## One source of truth for the game's dark-luxury visual language.

const INK := Color("#f2e8ee")
const MUTED := Color("#b9a5b6")
const CRIMSON := Color("#b93458")
const WINE := Color("#5b1736")
const PANEL := Color(0.045, 0.025, 0.065, 0.94)
const BORDER := Color(0.48, 0.20, 0.33, 0.75)
static var _cached_display_font: Font


static func create() -> Theme:
	var theme := Theme.new()
	var body := FontVariation.new()
	body.base_font = load("res://assets/fonts/Inter.ttf")
	body.variation_opentype = {"wght": 450, "opsz": 16}
	var display := FontVariation.new()
	display.base_font = load("res://assets/fonts/CormorantGaramond.ttf")
	display.variation_opentype = {"wght": 600}
	theme.default_font = body
	theme.default_font_size = 18
	theme.set_color("font_color", "Label", INK)
	theme.set_color("font_hover_color", "Button", Color("#ffeaf2"))
	theme.set_color("font_pressed_color", "Button", Color("#ffffff"))
	theme.set_color("font_disabled_color", "Button", Color(0.45, 0.36, 0.44, 0.7))
	theme.set_stylebox("normal", "Button", _box(Color(0.10, 0.055, 0.13, 0.92), BORDER, 8, 1))
	theme.set_stylebox("hover", "Button", _box(Color(0.22, 0.075, 0.16, 0.97), CRIMSON, 8, 2))
	theme.set_stylebox("pressed", "Button", _box(Color(0.34, 0.09, 0.20, 1.0), Color("#e06483"), 8, 2))
	theme.set_stylebox("disabled", "Button", _box(Color(0.07, 0.05, 0.08, 0.7), Color(0.3, 0.2, 0.28, 0.5), 8, 1))
	theme.set_stylebox("focus", "Button", _box(Color(0, 0, 0, 0), Color("#e58aa3"), 8, 2))
	theme.set_stylebox("panel", "PanelContainer", _box(PANEL, BORDER, 14, 1))
	theme.set_stylebox("normal", "LineEdit", _box(Color(0.035, 0.02, 0.05, 0.95), BORDER, 8, 1))
	theme.set_stylebox("focus", "LineEdit", _box(Color(0.05, 0.025, 0.07, 0.98), CRIMSON, 8, 2))
	theme.set_stylebox("read_only", "LineEdit", _box(Color(0.04, 0.025, 0.05, 0.9), BORDER, 8, 1))
	theme.set_stylebox("slider", "HSlider", _box(Color(0.18, 0.09, 0.16, 1), Color(0, 0, 0, 0), 3, 0))
	theme.set_stylebox("grabber_area", "HSlider", _box(WINE, Color(0, 0, 0, 0), 3, 0))
	theme.set_stylebox("grabber_area_highlight", "HSlider", _box(CRIMSON, Color(0, 0, 0, 0), 3, 0))
	theme.set_constant("separation", "VBoxContainer", 12)
	theme.set_constant("separation", "HBoxContainer", 10)
	theme.set_font("font", "Button", body)
	theme.set_font_size("font_size", "Button", 17)
	theme.set_font("font", "Label", body)
	theme.set_font("font", "LineEdit", body)
	# Display font is applied explicitly by UIFactory rather than globally.
	theme.set_meta("display_font", display)
	return theme


static func display_font() -> Font:
	if _cached_display_font != null:
		return _cached_display_font
	var display := FontVariation.new()
	display.base_font = load("res://assets/fonts/CormorantGaramond.ttf")
	display.variation_opentype = {"wght": 600}
	_cached_display_font = display
	return _cached_display_font


static func _box(bg: Color, border: Color, radius: int, width: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 16
	box.content_margin_right = 16
	box.content_margin_top = 10
	box.content_margin_bottom = 10
	return box
