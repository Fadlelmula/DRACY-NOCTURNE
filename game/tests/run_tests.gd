extends SceneTree
## Dependency-light automated tests. Run with:
## godot --headless --path game --script res://tests/run_tests.gd

var failures: int = 0
var checks: int = 0
var tests: Array[Callable] = []


func _initialize() -> void:
	tests.assign([
		_test_narrative_validation,
		_test_story_graph_coverage,
		_test_authored_routes,
		_test_pending_choice_save,
		_test_relationship_independence,
		_test_conditions,
		_test_save_roundtrip,
		_test_save_recovery,
		_test_save_migration,
		_test_validator_rejects_bad_reference
	])
	call_deferred("_run")


func _run() -> void:
	print("\n=== DRACY: NOCTURNE — automated tests ===")
	for test in tests:
		await test.call()
	print("=== %d checks, %d failures ===" % [checks, failures])
	SaveManager.save_dir_override = ""
	quit(1 if failures > 0 else 0)


func _check(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + message)
	else:
		failures += 1
		push_error("FAIL: " + message)


func _load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	return JSON.parse_string(file.get_as_text())


func _load_chapter(engine: NarrativeEngine) -> bool:
	return engine.load_chapter("res://content/chapters/prologue.json", _load_json("res://content/narrative_catalog.json"))


func _test_narrative_validation() -> void:
	var chapter := _load_json("res://content/chapters/prologue.json")
	var catalog := _load_json("res://content/narrative_catalog.json")
	var errors := NarrativeValidator.validate_chapter(chapter, catalog)
	_check(errors.is_empty(), "authored prologue passes all reference/schema checks")
	for error in errors:
		print("  VALIDATION: " + error)
	var words := 0
	for scene in chapter.get("scenes", []):
		for step in scene.get("steps", []):
			if step.get("type") == "line":
				words += String(step.get("text", "")).split(" ").size()
			elif step.get("type") == "choice":
				for option in step.get("options", []):
					words += String(option.get("text", "")).split(" ").size()
	_check(words >= 1700 and words <= 3600, "prologue has a plausible 10–15 minute reading/choice length (%d words)" % words)


func _test_story_graph_coverage() -> void:
	var chapter := _load_json("res://content/chapters/prologue.json")
	var expected_lines := {}
	var expected_options := {}
	var expected_scenes := {}
	for scene in chapter.get("scenes", []):
		expected_scenes[scene["id"]] = true
		for step in scene.get("steps", []):
			if step.get("type") == "line":
				expected_lines[step["id"]] = true
			elif step.get("type") == "choice":
				for option in step.get("options", []):
					expected_options[option["id"]] = true
	var seen_lines := {}
	var seen_options := {}
	var seen_scenes := {}
	var seen_endings := {}
	var queue: Array[GameState] = [GameState.new_game("Test")]
	var visited_states := {}
	var expansions := 0
	while not queue.is_empty() and expansions < 800:
		var state: GameState = queue.pop_back()
		var key := JSON.stringify([state.scene_id, state.scene_step, state.flags, state.relationships, state.boundaries])
		if visited_states.has(key):
			continue
		visited_states[key] = true
		expansions += 1
		var engine := NarrativeEngine.new()
		if not _load_chapter(engine):
			_check(false, "chapter loads during graph traversal")
			return
		if state.scene_id.is_empty():
			engine.start(state)
		else:
			engine.restore(state)
			engine.advance()
		seen_scenes[engine.current_scene_id] = true
		if engine.finished:
			seen_endings[String(engine.current_scene.get("ending", ""))] = true
			continue
		if not engine.current_line.is_empty():
			seen_lines[String(engine.current_line.get("id", ""))] = true
			engine.advance()
			queue.append(state.clone_state())
		elif not engine.pending_choices.is_empty():
			var branch_engine := NarrativeEngine.new()
			_load_chapter(branch_engine)
			for option in engine.pending_choices:
				seen_options[String(option.get("id", ""))] = true
				var branch := state.clone_state()
				branch_engine.restore(branch)
				branch_engine.advance()
				branch_engine.choose(String(option.get("id", "")))
				queue.append(branch)
	_check(seen_lines.size() >= 30, "bounded graph sample advances through authored content (%d lines)" % seen_lines.size())
	_check(seen_options.size() == expected_options.size(), "every player choice is reachable (%d/%d)" % [seen_options.size(), expected_options.size()])
	_check(seen_scenes.size() == expected_scenes.size(), "every scene is structurally reachable (%d/%d)" % [seen_scenes.size(), expected_scenes.size()])
	_check(seen_endings.size() == chapter.get("endings", []).size(), "both prologue endings are reachable (%d/2)" % seen_endings.size())


func _test_authored_routes() -> void:
	var chapter := _load_json("res://content/chapters/prologue.json")
	var expected_lines := {}
	for scene in chapter.get("scenes", []):
		for step in scene.get("steps", []):
			if step.get("type") == "line":
				expected_lines[step["id"]] = true
	var seen_lines := {}
	var seen_endings := {}
	var routes := [
		["o002_honest", "o005_editor", "o008_support", "o011_photo", "o013_wait", "o016_accept", "o020_horror", "o022_friendly", "o027_obey", "o029_accept", "o033_no_visit", "o034_share_name", "o037_world", "o040_agree", "o045_promise", "o046_stay", "o049_truth", "o052_accept"],
		["o001_curious", "o006_username", "o007_play", "o012_eyes", "o015_double", "o018_tease", "o021_both", "o024_tease_dom", "o025_ask", "o028_search", "o031_called_out", "o035_weakness", "o039_fiction", "o041_boundary", "o043_later", "o047_peephole", "o050_anger", "o054_tease"],
		["o003_tease", "o004_name", "o009_tease_game", "o010_jacket", "o014_curious_wait", "o017_gentle", "o019_gothic", "o023_specific", "o026_joke", "o030_ask_photo", "o032_deflect", "o036_space", "o038_question", "o042_joke", "o044_curious", "o048_open", "o051_gentle", "o053_time"]
	]
	for route in routes:
		var engine := NarrativeEngine.new()
		if not _load_chapter(engine):
			_check(false, "chapter loads for authored route")
			return
		var state := GameState.new_game("Route Tester")
		engine.start(state)
		var choice_index := 0
		var guard := 0
		while not engine.finished and guard < 500:
			guard += 1
			if not engine.current_line.is_empty():
				seen_lines[String(engine.current_line.get("id", ""))] = true
				engine.advance()
			elif not engine.pending_choices.is_empty():
				_check(choice_index < route.size(), "authored route does not run out of choices")
				if choice_index >= route.size():
					break
				var option_id := String(route[choice_index])
				var found := false
				for option in engine.pending_choices:
					if option.get("id") == option_id:
						found = true
				_check(found, "authored route option '%s' is available" % option_id)
				if not found:
					break
				engine.choose(option_id)
				choice_index += 1
			else:
				engine.advance()
		if engine.finished:
			seen_endings[String(engine.current_scene.get("ending", ""))] = true
	_check(seen_lines.size() == expected_lines.size(), "three authored routes cover every line including conditional dialogue (%d/%d)" % [seen_lines.size(), expected_lines.size()])
	for line_id in expected_lines:
		if not seen_lines.has(line_id):
			print("  UNCOVERED LINE: " + line_id)
	_check(seen_endings.size() == 2, "authored routes complete both endings")


func _test_pending_choice_save() -> void:
	SaveManager.save_dir_override = "user://dracy_test_pending_choice"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveManager.save_dir_override))
	var engine := NarrativeEngine.new()
	_load_chapter(engine)
	var state := GameState.new_game("Choice Tester")
	engine.start(state)
	while engine.current_line.is_empty() and engine.pending_choices.is_empty() and not engine.finished:
		engine.advance()
	while not engine.current_line.is_empty() and engine.pending_choices.is_empty() and not engine.finished:
		engine.advance()
	_check(not engine.pending_choices.is_empty(), "test reaches a pending choice")
	_check(SaveManager.save_game(state, "slot_1"), "pending choice autosave writes")
	var loaded := SaveManager.load_game("slot_1")
	var restored := NarrativeEngine.new()
	_load_chapter(restored)
	_check(loaded != null and restored.restore(loaded), "pending choice save restores")
	if loaded != null:
		restored.advance()
		_check(not restored.pending_choices.is_empty(), "pending choice is reconstructed instead of skipped")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveManager.save_dir_override))


func _test_relationship_independence() -> void:
	var state := GameState.new_game()
	var before := state.relationships.duplicate()
	_check(state.apply_effect({"type": "relationship", "key": "trust", "delta": 2, "reason": "Test trust change"}, "test"), "valid relationship effect is accepted")
	_check(state.relationships["trust"] == before["trust"] + 2, "trust changes by the authored amount")
	for key in ["attraction", "dominance", "curiosity", "suspicion"]:
		_check(state.relationships[key] == before[key], "%s remains independent of trust" % key)
	_check(not state.apply_effect({"type": "relationship", "key": "trust", "delta": 9, "reason": "Invalid"}, "test"), "oversized AI-style relationship mutation is rejected")
	_check(not state.apply_effect({"type": "set_flag", "key": "gateway;drop", "value": true}, "test"), "unsafe state keys are rejected")


func _test_conditions() -> void:
	var state := GameState.new_game()
	state.flags["met_dracy"] = true
	state.boundaries.append("friendly_only")
	_check(NarrativeCondition.evaluate({"type": "flag", "key": "met_dracy", "op": "eq", "value": true}, state), "flag condition evaluates")
	_check(not NarrativeCondition.evaluate({"type": "flag", "key": "gateway_discovered", "op": "eq", "value": true}, state), "missing flag evaluates false")
	_check(NarrativeCondition.evaluate({"type": "boundary", "key": "friendly_only", "op": "set", "value": true}, state), "boundary condition evaluates")
	_check(NarrativeCondition.evaluate({"type": "relationship", "key": "trust", "op": "gte", "value": 1}, state), "relationship threshold evaluates")
	_check(NarrativeCondition.evaluate({"type": "not", "condition": {"type": "flag", "key": "gateway_discovered", "op": "eq", "value": true}}, state), "nested negation evaluates")
	state.decisions.append("o001_curious")
	_check(NarrativeCondition.evaluate({"type": "choice_made", "key": "o001_curious", "op": "eq", "value": true}, state), "authored choice history evaluates")


func _test_save_roundtrip() -> void:
	SaveManager.save_dir_override = "user://dracy_test_saves"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveManager.save_dir_override))
	var state := GameState.new_game("Save Tester")
	state.scene_id = "p009_warning"
	state.scene_step = 3
	state.flags["met_dracy"] = true
	state.relationships["trust"] = 5
	state.boundaries.append("no_pressure")
	state.memories.append({"id": "mem_test", "text": "A tested memory.", "source": "authored", "created_at": 1.0})
	_check(SaveManager.save_game(state, "slot_1"), "save writes successfully")
	var loaded := SaveManager.load_game("slot_1")
	_check(loaded != null, "save loads successfully")
	if loaded != null:
		_check(loaded.player_name == "Save Tester" and loaded.scene_id == "p009_warning", "identity and narrative cursor survive restart")
		_check(loaded.relationships["trust"] == 5 and loaded.flags["met_dracy"], "relationships and flags survive restart")
		_check(loaded.boundaries.has("no_pressure") and loaded.memories.size() == 1, "boundaries and memories survive restart")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveManager.save_dir_override))


func _test_save_recovery() -> void:
	SaveManager.save_dir_override = "user://dracy_test_recovery"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveManager.save_dir_override))
	var state := GameState.new_game("Recovery")
	state.scene_id = "p010_impossible_photo"
	_check(SaveManager.save_game(state, "slot_1"), "recovery seed save succeeds")
	_check(SaveManager.save_game(state, "slot_1"), "recovery backup is created by a subsequent save")
	var path := ProjectSettings.globalize_path(SaveManager._slot_path("slot_1"))
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string('{"envelope_version":1,"payload":{},"checksum":"corrupt"}')
	file.close()
	var loaded := SaveManager.load_game("slot_1")
	_check(loaded != null and loaded.player_name == "Recovery", "corrupt primary save recovers from checksum-valid backup")
	_check(SaveManager.save_game(loaded, "slot_1") and SaveManager.load_game("slot_1") != null, "recovered save is repaired atomically")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveManager.save_dir_override))


func _test_save_migration() -> void:
	SaveManager.save_dir_override = "user://dracy_test_migration"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveManager.save_dir_override))
	var legacy := {
		"save_version": 2, "player_name": "Legacy", "chapter_id": "prologue", "scene_id": "p001_midnight_scroll", "scene_step": 4,
		"flags": {"met_dracy": true, "friendly_only": true}, "relationships": {"trust": 3, "attraction": 1, "dominance": 0, "curiosity": 2, "suspicion": 1},
		"boundaries": [], "memories": [], "history": [], "visited_scenes": [], "triggered_events": [], "relationship_log": [], "completed_chapters": []
	}
	var envelope := {"envelope_version": 1, "payload": legacy, "checksum": SaveManager._checksum(JSON.stringify(legacy))}
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SaveManager.save_dir_override))
	var path := ProjectSettings.globalize_path(SaveManager._slot_path("slot_2"))
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(envelope))
	file.close()
	var loaded := SaveManager.load_game("slot_2")
	_check(loaded != null, "v2 save is readable")
	if loaded != null:
		_check(loaded.save_version == GameState.SAVE_VERSION, "legacy save migrates to current version")
		_check(loaded.boundaries.has("friendly_only") and not loaded.flags.has("friendly_only"), "legacy boundary flag migrates without losing meaning")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveManager.save_dir_override))


func _test_validator_rejects_bad_reference() -> void:
	var chapter := _load_json("res://content/chapters/prologue.json")
	var catalog := _load_json("res://content/narrative_catalog.json")
	chapter["scenes"][0]["steps"][-1]["options"][0]["target"] = "scene_that_does_not_exist"
	var errors := NarrativeValidator.validate_chapter(chapter, catalog)
	_check(not errors.is_empty(), "validator rejects broken choice references")
