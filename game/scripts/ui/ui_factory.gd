class_name UIFactory
extends RefCounted


static func label(text: String, size: int = 18, color: Color = UITheme.INK, display: bool = false) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", size)
	node.add_theme_color_override("font_color", color)
	if display:
		node.add_theme_font_override("font", UITheme.display_font())
	return node


static func button(text: String, accent: bool = false) -> Button:
	var node := Button.new()
	node.text = text
	node.custom_minimum_size = Vector2(220, 44)
	node.focus_mode = Control.FOCUS_ALL
	if accent:
		node.add_theme_color_override("font_color", Color("#fff2f6"))
		node.add_theme_color_override("font_hover_color", Color.WHITE)
	return node


static func panel(bg: Color = UITheme.PANEL, border: Color = UITheme.BORDER, radius: int = 14) -> PanelContainer:
	var node := PanelContainer.new()
	node.add_theme_stylebox_override("panel", UITheme._box(bg, border, radius, 1))
	return node


static func spacer(height: float) -> Control:
	var node := Control.new()
	node.custom_minimum_size.y = height
	return node


static func h_spacer(width: float) -> Control:
	var node := Control.new()
	node.custom_minimum_size.x = width
	return node


static func format_text(text: String, state: GameState) -> String:
	return text.replace("{player_name}", state.player_name)
