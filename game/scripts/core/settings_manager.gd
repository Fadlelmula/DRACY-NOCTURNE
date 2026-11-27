class_name SettingsManager
extends Node
## User preferences are intentionally separate from story saves. No API secrets
## are ever stored here; only a public backend URL and an enable switch.

signal settings_changed

# Explicit preload registers the Localizer global even on a cold import cache.
const _LocalizerPreload = preload("res://scripts/core/localizer.gd")

const CONFIG_PATH := "user://settings.cfg"
const DEFAULT_AI_ENDPOINT := "http://127.0.0.1:8787"

var master_volume: float = 0.8
var music_volume: float = 0.55
var sfx_volume: float = 0.7
var text_speed: float = 42.0
var reduced_motion: bool = false
var fullscreen: bool = false
var language: String = "en"
var ai_enabled: bool = false
var ai_endpoint: String = DEFAULT_AI_ENDPOINT
var install_id: String = ""
var content_accepted: bool = false


func _ready() -> void:
	load_settings()
	apply_all()


func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		install_id = _new_install_id()
		save_settings()
		return
	master_volume = clampf(float(config.get_value("audio", "master", 0.8)), 0.0, 1.0)
	music_volume = clampf(float(config.get_value("audio", "music", 0.55)), 0.0, 1.0)
	sfx_volume = clampf(float(config.get_value("audio", "sfx", 0.7)), 0.0, 1.0)
	text_speed = clampf(float(config.get_value("text", "speed", 42.0)), 8.0, 120.0)
	reduced_motion = bool(config.get_value("accessibility", "reduced_motion", false))
	fullscreen = bool(config.get_value("display", "fullscreen", false))
	language = String(config.get_value("language", "locale", "en"))
	Localizer.load_locale(language)
	ai_enabled = bool(config.get_value("ai", "enabled", false))
	ai_endpoint = sanitize_endpoint(String(config.get_value("ai", "endpoint", DEFAULT_AI_ENDPOINT)))
	install_id = String(config.get_value("privacy", "install_id", ""))
	content_accepted = bool(config.get_value("content", "accepted", false))
	if install_id.length() != 32:
		install_id = _new_install_id()


func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master", master_volume)
	config.set_value("audio", "music", music_volume)
	config.set_value("audio", "sfx", sfx_volume)
	config.set_value("text", "speed", text_speed)
	config.set_value("accessibility", "reduced_motion", reduced_motion)
	config.set_value("display", "fullscreen", fullscreen)
	config.set_value("language", "locale", language)
	config.set_value("ai", "enabled", ai_enabled)
	config.set_value("ai", "endpoint", ai_endpoint)
	config.set_value("privacy", "install_id", install_id)
	config.set_value("content", "accepted", content_accepted)
	var error := config.save(CONFIG_PATH)
	if error != OK:
		push_error("SettingsManager: could not save settings (%s)" % error)
		return
	settings_changed.emit()


func apply_all() -> void:
	_set_bus_volume("Master", master_volume)
	_set_bus_volume("Music", music_volume)
	_set_bus_volume("SFX", sfx_volume)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)


func set_volumes(master: float, music: float, sfx: float) -> void:
	master_volume = clampf(master, 0.0, 1.0)
	music_volume = clampf(music, 0.0, 1.0)
	sfx_volume = clampf(sfx, 0.0, 1.0)
	apply_all()
	save_settings()


func sanitize_endpoint(value: String) -> String:
	var trimmed := value.strip_edges().trim_suffix("/")
	if not (trimmed.begins_with("http://") or trimmed.begins_with("https://")):
		return DEFAULT_AI_ENDPOINT
	if trimmed.length() > 256 or " " in trimmed or "@" in trimmed or "?" in trimmed or "#" in trimmed:
		return DEFAULT_AI_ENDPOINT
	if trimmed.begins_with("http://"):
		var authority := trimmed.substr(7).split("/")[0]
		var host := authority.split(":")[0]
		if host not in ["127.0.0.1", "localhost", "::1"]:
			return DEFAULT_AI_ENDPOINT
	return trimmed


static func _set_bus_volume(bus_name: String, linear_volume: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(linear_volume, 0.0001)))


func _new_install_id() -> String:
	# A local pseudonymous correlation ID, not an account or authentication secret.
	var random := RandomNumberGenerator.new()
	random.randomize()
	var bytes := PackedByteArray()
	for index in 16:
		bytes.append(random.randi_range(0, 255))
	return bytes.hex_encode()
