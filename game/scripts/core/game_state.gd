class_name GameState
extends RefCounted
## All mutable player progress lives here. The AI client can read a projected
## snapshot, but has no reference to this object and cannot apply effects.

const SAVE_VERSION := 3
const RELATIONSHIP_KEYS := ["trust", "attraction", "dominance", "curiosity", "suspicion"]
const BOUNDARY_KEYS := ["friendly_only", "no_pressure", "no_dark_topics"]
const MAX_HISTORY := 120
const MAX_MEMORIES := 40

var save_version: int = SAVE_VERSION
var player_name: String = "Player"
var chapter_id: String = ""
var scene_id: String = ""
var scene_step: int = 0
var flags: Dictionary = {}
var relationships: Dictionary = {"trust": 1, "attraction": 0, "dominance": 0, "curiosity": 1, "suspicion": 0}
var boundaries: Array[String] = []
var memories: Array[Dictionary] = []
var history: Array[Dictionary] = []
var visited_scenes: Array[String] = []
var triggered_events: Array[String] = []
var decisions: Array[String] = []
var relationship_log: Array[Dictionary] = []
var completed_chapters: Array[String] = []
var play_seconds: float = 0.0
var updated_at: float = 0.0


static func new_game(player_name: String = "Player") -> GameState:
	var state := GameState.new()
	state.player_name = player_name.strip_edges().left(24)
	if state.player_name.is_empty():
		state.player_name = "Player"
	state.chapter_id = "prologue"
	state.updated_at = Time.get_unix_time_from_system()
	return state


func apply_effect(effect: Dictionary, source_id: String) -> bool:
	match effect.get("type", ""):
		"set_flag":
			var key := String(effect.get("key", ""))
			if not _safe_key(key):
				return false
			flags[key] = bool(effect.get("value", true))
		"relationship":
			var key := String(effect.get("key", ""))
			var delta := int(effect.get("delta", 0))
			var reason := String(effect.get("reason", "")).strip_edges()
			if key not in RELATIONSHIP_KEYS or delta == 0 or abs(delta) > 3 or reason.is_empty() or reason.length() > 160:
				return false
			var before := int(relationships.get(key, 0))
			var after := clampi(before + delta, 0, 10)
			if before == after:
				return true
			relationships[key] = after
			relationship_log.append({
				"dimension": key, "before": before, "after": after, "delta": after - before,
				"reason": reason, "source": source_id, "at": Time.get_unix_time_from_system()
			})
			if relationship_log.size() > 100:
				relationship_log = relationship_log.slice(relationship_log.size() - 100)
		"add_boundary":
			var key := String(effect.get("key", ""))
			if key not in BOUNDARY_KEYS:
				return false
			if key not in boundaries:
				boundaries.append(key)
		"remove_boundary":
			boundaries.erase(String(effect.get("key", "")))
		"memory":
			var memory := {
				"id": String(effect.get("id", "")),
				"text": String(effect.get("text", "")).strip_edges().left(280),
				"source": "authored",
				"created_at": Time.get_unix_time_from_system()
			}
			if not _safe_key(memory["id"]) or memory["text"].is_empty() or memory["text"].length() > 280:
				return false
			# A memory key is immutable: later authored beats may update it explicitly.
			for existing in memories:
				if existing.get("id") == memory["id"]:
					existing["text"] = memory["text"]
					existing["created_at"] = memory["created_at"]
					return true
			memories.append(memory)
			if memories.size() > MAX_MEMORIES:
				memories.pop_front()
		_:
			return false
	updated_at = Time.get_unix_time_from_system()
	return true


func add_history(entry: Dictionary) -> void:
	history.append(entry)
	if history.size() > MAX_HISTORY:
		history = history.slice(history.size() - MAX_HISTORY)


func mark_scene_visited(scene_id: String) -> void:
	if not scene_id.is_empty() and scene_id not in visited_scenes:
		visited_scenes.append(scene_id)


func to_dict() -> Dictionary:
	return {
		"save_version": SAVE_VERSION,
		"player_name": player_name,
		"chapter_id": chapter_id,
		"scene_id": scene_id,
		"scene_step": scene_step,
		"flags": flags.duplicate(true),
		"relationships": relationships.duplicate(true),
		"boundaries": boundaries.duplicate(),
		"memories": memories.duplicate(true),
		"history": history.duplicate(true),
		"visited_scenes": visited_scenes.duplicate(),
		"triggered_events": triggered_events.duplicate(),
		"decisions": decisions.duplicate(),
		"relationship_log": relationship_log.duplicate(true),
		"completed_chapters": completed_chapters.duplicate(),
		"play_seconds": play_seconds,
		"updated_at": updated_at
	}


func clone_state() -> GameState:
	return GameState.from_dict(to_dict())


static func from_dict(data: Dictionary) -> GameState:
	var state := GameState.new()
	if data.is_empty():
		return state
	state.save_version = clampi(int(data.get("save_version", 1)), 1, SAVE_VERSION)
	state.player_name = String(data.get("player_name", "Player")).strip_edges().left(24)
	if state.player_name.is_empty():
		state.player_name = "Player"
	state.chapter_id = String(data.get("chapter_id", "")).left(64)
	state.scene_id = String(data.get("scene_id", "")).left(96)
	state.scene_step = maxi(0, int(data.get("scene_step", 0)))
	state.flags = _string_keyed_dict(data.get("flags", {}), 128)
	for key in RELATIONSHIP_KEYS:
		state.relationships[key] = clampi(int(data.get("relationships", {}).get(key, state.relationships[key])), 0, 10)
	for value in data.get("boundaries", []):
		var key := String(value)
		if key in BOUNDARY_KEYS and key not in state.boundaries:
			state.boundaries.append(key)
	state.memories = _sanitize_memories(data.get("memories", []))
	state.history = _sanitize_history(data.get("history", []))
	state.visited_scenes = _safe_string_array(data.get("visited_scenes", []), 512)
	state.triggered_events = _safe_string_array(data.get("triggered_events", []), 256)
	state.decisions = _safe_string_array(data.get("decisions", []), 256)
	state.relationship_log = _sanitize_log(data.get("relationship_log", []))
	state.completed_chapters = _safe_string_array(data.get("completed_chapters", []), 32)
	state.play_seconds = clampf(float(data.get("play_seconds", 0.0)), 0.0, 10000000.0)
	state.updated_at = maxf(0.0, float(data.get("updated_at", 0.0)))
	state.save_version = SAVE_VERSION
	return state


static func _safe_key(key: String) -> bool:
	return not key.is_empty() and key.length() <= 96 and key.is_valid_identifier()


static func _string_keyed_dict(value: Variant, limit: int) -> Dictionary:
	var result := {}
	if value is Dictionary:
		for key in value:
			var safe_key := String(key)
			if safe_key.length() <= 96 and safe_key.is_valid_identifier() and result.size() < limit:
				result[safe_key] = value[key]
	return result


static func _safe_string_array(value: Variant, limit: int) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value:
			var text := String(item).left(128)
			if not text.is_empty() and text not in result and result.size() < limit:
				result.append(text)
	return result


static func _sanitize_memories(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if value is Array:
		for item in value:
			if item is Dictionary and _safe_key(String(item.get("id", ""))):
				var text := String(item.get("text", "")).strip_edges().left(280)
				if not text.is_empty():
					result.append({"id": item["id"], "text": text, "source": "authored", "created_at": maxf(0.0, float(item.get("created_at", 0.0)))})
	return result


static func _sanitize_history(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if value is Array:
		for item in value:
			if item is Dictionary:
				result.append({
					"speaker": String(item.get("speaker", "narrator")).left(32),
					"text": String(item.get("text", "")).left(1200),
					"line_id": String(item.get("line_id", "")).left(96),
					"scene_id": String(item.get("scene_id", "")).left(96)
				})
	return result


static func _sanitize_log(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if value is Array:
		for item in value:
			if item is Dictionary and item.get("dimension") in RELATIONSHIP_KEYS:
				result.append({
					"dimension": item["dimension"], "before": int(item.get("before", 0)),
					"after": int(item.get("after", 0)), "delta": int(item.get("delta", 0)),
					"reason": String(item.get("reason", "")).left(160), "source": String(item.get("source", "")).left(96),
					"at": maxf(0.0, float(item.get("at", 0.0)))
				})
	return result
