class_name Localizer
extends RefCounted
## Lightweight JSON localization. Authored lines may be overridden using
## line.<line_id> and choices using choice.<option_id> without touching code.

static var _catalog: Dictionary = {}


static func load_locale(locale: String = "en") -> void:
	_catalog.clear()
	var path := "res://localization/%s.json" % locale
	if not FileAccess.file_exists(path):
		path = "res://localization/en.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		_catalog = parsed


static func t(key: String, fallback: String = "") -> String:
	var value := String(_catalog.get(key, ""))
	return fallback if value.is_empty() else value


static func narrative_text(key: String, fallback: String, state: GameState) -> String:
	var value := t(key, "")
	if value.is_empty():
		value = fallback
	return UIFactory.format_text(value, state)
