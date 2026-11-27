class_name SaveManager
extends RefCounted
## Atomic, checksummed, versioned saves with an automatic previous-copy backup.

const SAVE_DIR := "user://saves"
const ENVELOPE_VERSION := 1
const SLOTS := ["autosave", "slot_1", "slot_2", "slot_3"]
## Tests redirect saves so validation never overwrites a player's real progress.
static var save_dir_override: String = ""


static func save_game(state: GameState, slot: String = "autosave") -> bool:
	if state == null or slot not in SLOTS:
		return false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_root()))
	var payload := state.to_dict()
	var canonical := JSON.stringify(payload)
	var envelope := {
		"envelope_version": ENVELOPE_VERSION,
		"payload": payload,
		"checksum": _checksum(canonical)
	}
	var path := _slot_path(slot)
	var temp_path := path + ".tmp"
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: cannot open temporary save: %s" % FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify(envelope))
	file.flush()
	file.close()
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path + ".bak")
		if DirAccess.rename_absolute(path, path + ".bak") != OK:
			push_warning("SaveManager: could not rotate backup for %s" % slot)
	var rename_result := DirAccess.rename_absolute(temp_path, path)
	if rename_result != OK:
		push_error("SaveManager: atomic save rename failed for %s" % slot)
		return false
	return true


static func load_game(slot: String = "autosave") -> GameState:
	if slot not in SLOTS:
		return null
	var state := _load_path(_slot_path(slot))
	if state != null:
		return state
	var recovered := _load_path(_slot_path(slot) + ".bak")
	if recovered != null:
		push_warning("SaveManager: recovered %s from backup" % slot)
		# Repair the primary slot immediately so recovery is not repeated.
		save_game(recovered, slot)
		return recovered
	return null


static func has_save(slot: String = "autosave") -> bool:
	return slot in SLOTS and FileAccess.file_exists(_slot_path(slot))


static func get_save_info(slot: String) -> Dictionary:
	var state := load_game(slot)
	if state == null:
		return {}
	return {
		"chapter": state.chapter_id, "scene": state.scene_id,
		"updated_at": state.updated_at, "play_seconds": state.play_seconds,
		"player_name": state.player_name
	}


static func delete_save(slot: String) -> bool:
	if slot not in SLOTS or slot == "autosave":
		return false
	var result := DirAccess.remove_absolute(_slot_path(slot))
	DirAccess.remove_absolute(_slot_path(slot) + ".bak")
	return result == OK or not FileAccess.file_exists(_slot_path(slot))


static func delete_all_data() -> void:
	for slot in SLOTS:
		if slot != "autosave":
			delete_save(slot)
	DirAccess.remove_absolute(_slot_path("autosave"))
	DirAccess.remove_absolute(_slot_path("autosave") + ".bak")


static func _load_path(path: String) -> GameState:
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var raw := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(raw)
	if not parsed is Dictionary:
		return null
	var envelope: Dictionary = parsed
	if int(envelope.get("envelope_version", -1)) != ENVELOPE_VERSION:
		return null
	var payload: Variant = envelope.get("payload")
	if not payload is Dictionary:
		return null
	var expected := String(envelope.get("checksum", ""))
	if expected != _checksum(JSON.stringify(payload)):
		push_warning("SaveManager: checksum mismatch in %s" % path)
		return null
	var migrated := _migrate(payload)
	if migrated.is_empty():
		return null
	return GameState.from_dict(migrated)


static func _migrate(payload: Dictionary) -> Dictionary:
	var result := payload.duplicate(true)
	var version := int(result.get("save_version", 0))
	if version < 1 or version > GameState.SAVE_VERSION:
		return {}
	if version == 1:
		# v1 had no independent relationship dimensions.
		result["relationships"] = {"trust": int(result.get("trust", 1)), "attraction": 0, "dominance": 0, "curiosity": 1, "suspicion": 0}
		result.erase("trust")
		version = 2
	if version == 2:
		# v2 stored boundaries as flags; split them into a dedicated collection.
		var flags: Dictionary = result.get("flags", {})
		var boundaries: Array = result.get("boundaries", [])
		for key in GameState.BOUNDARY_KEYS:
			if flags.get(key, false) and key not in boundaries:
				boundaries.append(key)
			flags.erase(key)
		result["flags"] = flags
		result["boundaries"] = boundaries
		version = 3
	result["save_version"] = GameState.SAVE_VERSION
	return result


static func _slot_path(slot: String) -> String:
	return _root().path_join(slot + ".sav")


static func _root() -> String:
	return SAVE_DIR if save_dir_override.is_empty() else save_dir_override


static func _checksum(text: String) -> String:
	# Normalize JSON number representation (Godot parses all JSON numbers as float).
	var normalized: Variant = JSON.parse_string(text)
	if normalized is Dictionary or normalized is Array:
		text = JSON.stringify(normalized)
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(text.to_utf8_buffer())
	return context.finish().hex_encode()
