class_name NarrativeEngine
extends RefCounted
## Executes validated, authored narrative data. It is the only game system allowed
## to mutate story flags, boundaries, memories, and relationship dimensions.

signal line_presented(line: Dictionary)
signal choices_presented(options: Array)
signal scene_changed(scene: Dictionary)
signal progress_changed
signal effects_applied(effects: Array, source_id: String)
signal chapter_finished(ending: String)
signal error_occurred(message: String)

var chapter: Dictionary = {}
var state: GameState
var current_scene_id: String = ""
var current_scene: Dictionary = {}
var current_line: Dictionary = {}
var pending_choices: Array = []
var current_choice_prompt: String = ""
var finished: bool = false
var _scene_map: Dictionary = {}
var _event_map: Dictionary = {}
var _guard_counter: int = 0


func load_chapter(path: String, catalog: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		error_occurred.emit("Cannot open chapter: %s" % path)
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		error_occurred.emit("Chapter is not valid JSON: %s" % path)
		return false
	chapter = parsed
	var errors := NarrativeValidator.validate_chapter(chapter, catalog)
	if not errors.is_empty():
		error_occurred.emit("Narrative validation failed:\n" + "\n".join(errors))
		return false
	for scene in chapter.get("scenes", []):
		_scene_map[scene["id"]] = scene
	for event in chapter.get("events", []):
		_event_map[event["id"]] = event
	return true


func start(player_state: GameState) -> bool:
	if chapter.is_empty():
		error_occurred.emit("No chapter loaded")
		return false
	state = player_state
	state.chapter_id = String(chapter["id"])
	finished = false
	_enter_scene(String(chapter["start_scene"]))
	if not finished:
		advance()
	return not finished or state.scene_id == String(chapter["start_scene"])


func restore(player_state: GameState) -> bool:
	if chapter.is_empty() or not _scene_map.has(player_state.scene_id):
		return false
	state = player_state
	state.chapter_id = String(chapter["id"])
	current_scene_id = player_state.scene_id
	current_scene = _scene_map[current_scene_id]
	finished = false
	pending_choices.clear()
	current_line.clear()
	scene_changed.emit(current_scene)
	progress_changed.emit()
	return true


func advance() -> void:
	if finished or state == null or not pending_choices.is_empty():
		return
	current_line.clear()
	_guard_counter = 0
	while not finished and current_line.is_empty() and pending_choices.is_empty():
		_guard_counter += 1
		if _guard_counter > 10000:
			error_occurred.emit("Narrative loop guard triggered in %s" % current_scene_id)
			return
		_process_next_step()


func choose(option_id: String) -> bool:
	var selected: Dictionary = {}
	for option in pending_choices:
		if option.get("id") == option_id:
			selected = option
			break
	if selected.is_empty():
		return false
	pending_choices.clear()
	current_line.clear()
	state.scene_step += 1
	if option_id not in state.decisions:
		state.decisions.append(option_id)
	_apply_effects(selected.get("effects", []), String(selected.get("id", "")))
	_check_events()
	progress_changed.emit()
	var target := String(selected.get("target", ""))
	if target.is_empty():
		error_occurred.emit("Choice %s has no target" % option_id)
		return false
	_enter_scene(target)
	if not finished:
		advance()
	return true


func available_choices() -> Array:
	return pending_choices


func _process_next_step() -> void:
	var steps: Array = current_scene.get("steps", [])
	if state.scene_step >= steps.size():
		_finish_scene()
		return
	var step: Dictionary = steps[state.scene_step]
	# A pending choice must remain replayable after save/load. All other steps
	# advance the cursor immediately; choices advance only when selected.
	if String(step.get("type", "")) != "choice":
		state.scene_step += 1
	if not NarrativeCondition.evaluate_all(step.get("conditions", []), state):
		return
	match String(step.get("type", "")):
		"line":
			current_line = step
			var entry := {
				"speaker": step.get("speaker", "narrator"), "text": step.get("text", ""),
				"line_id": step.get("id", ""), "scene_id": current_scene_id
			}
			state.add_history(entry)
			line_presented.emit(step)
			progress_changed.emit()
		"choice":
			var options: Array = []
			for option in step.get("options", []):
				if NarrativeCondition.evaluate_all(option.get("conditions", []), state):
					options.append(option)
			if options.is_empty():
				var fallback := String(step.get("fallback", ""))
				if not fallback.is_empty():
					_enter_scene(fallback)
				else:
					error_occurred.emit("No available option for choice %s" % step.get("id", ""))
				return
			pending_choices = options
			current_choice_prompt = String(step.get("prompt", "What do you say?"))
			choices_presented.emit(options)
			progress_changed.emit()
		"effect":
			_apply_effects([step.get("effect", {})], String(step.get("id", "")))
			_check_events()
		"jump":
			_enter_scene(String(step.get("target", "")))
		"event":
			var event_id := String(step.get("event_id", ""))
			if event_id in state.triggered_events:
				return
			var event: Dictionary = _event_map.get(event_id, {})
			if event.is_empty():
				error_occurred.emit("Unknown event: %s" % event_id)
				return
			if NarrativeCondition.evaluate_all(event.get("conditions", []), state):
				state.triggered_events.append(event_id)
				_apply_effects(event.get("effects", []), event_id)
		"end":
			_finish_scene()
		_:
			error_occurred.emit("Unsupported step: %s" % step.get("id", ""))


func _enter_scene(scene_id: String) -> void:
	if not _scene_map.has(scene_id):
		error_occurred.emit("Unknown scene: %s" % scene_id)
		finished = true
		return
	current_scene_id = scene_id
	current_scene = _scene_map[scene_id]
	state.scene_id = scene_id
	state.scene_step = 0
	current_line.clear()
	pending_choices.clear()
	state.mark_scene_visited(scene_id)
	_apply_effects(current_scene.get("on_enter", []), scene_id + "/on_enter")
	_check_events()
	scene_changed.emit(current_scene)
	progress_changed.emit()


func _finish_scene() -> void:
	_check_events()
	var next_scene := String(current_scene.get("next_scene", ""))
	if not next_scene.is_empty():
		_enter_scene(next_scene)
		return
	var ending := String(current_scene.get("ending", ""))
	if ending.is_empty():
		error_occurred.emit("Scene %s has no exit" % current_scene_id)
		finished = true
		return
	finished = true
	current_line.clear()
	pending_choices.clear()
	if state.chapter_id not in state.completed_chapters:
		state.completed_chapters.append(state.chapter_id)
	chapter_finished.emit(ending)
	progress_changed.emit()


func _apply_effects(effects: Array, source_id: String) -> void:
	for effect in effects:
		if not state.apply_effect(effect, source_id):
			error_occurred.emit("Authored effect rejected at %s: %s" % [source_id, JSON.stringify(effect)])
	if not effects.is_empty():
		effects_applied.emit(effects, source_id)


func _check_events() -> void:
	for event in chapter.get("events", []):
		var event_id := String(event.get("id", ""))
		if event_id in state.triggered_events:
			continue
		if NarrativeCondition.evaluate_all(event.get("conditions", []), state):
			state.triggered_events.append(event_id)
			_apply_effects(event.get("effects", []), event_id)
