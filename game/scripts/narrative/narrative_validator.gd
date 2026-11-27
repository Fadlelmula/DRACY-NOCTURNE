class_name NarrativeValidator
extends RefCounted
## Static validation catches broken references before content reaches players.

static func validate_chapter(chapter: Dictionary, catalog: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	var scenes: Array = chapter.get("scenes", [])
	var scene_ids := {}
	var line_ids := {}
	var step_ids := {}
	var event_ids := {}
	var all_option_ids := {}
	var characters: Dictionary = catalog.get("characters", {})
	var backgrounds: Array = catalog.get("backgrounds", [])
	var music: Array = catalog.get("music", [])
	var known_flags: Array = catalog.get("flags", [])
	var known_memories: Dictionary = catalog.get("memories", {})

	if int(chapter.get("schema_version", 0)) != 1:
		errors.append("Chapter schema_version must be 1")
	if String(chapter.get("id", "")).is_empty():
		errors.append("Chapter id is required")
	if String(chapter.get("start_scene", "")).is_empty():
		errors.append("Chapter start_scene is required")

	for scene in scenes:
		if not scene is Dictionary:
			errors.append("Every scene must be an object")
			continue
		var id := String(scene.get("id", ""))
		if id.is_empty() or id.length() > 96 or not id.is_valid_identifier():
			errors.append("Invalid scene id: %s" % id)
		elif scene_ids.has(id):
			errors.append("Duplicate scene id: %s" % id)
		scene_ids[id] = scene
		if scene.get("mode", "vn") not in ["vn", "chat", "narration"]:
			errors.append("%s: invalid presentation mode" % id)
		if String(scene.get("background", "")) not in backgrounds:
			errors.append("%s: unknown background '%s'" % [id, scene.get("background", "")])
		if not String(scene.get("music", "")).is_empty() and scene.get("music") not in music:
			errors.append("%s: unknown music '%s'" % [id, scene.get("music", "")])
		_validate_conditions(scene.get("prerequisites", []), known_flags, "%s prerequisites" % id, errors)
		_validate_effects(scene.get("on_enter", []), known_flags, known_memories, "%s on_enter" % id, errors)
		var steps: Array = scene.get("steps", [])
		if steps.is_empty():
			errors.append("%s: scene has no steps" % id)
		for step in steps:
			if not step is Dictionary:
				errors.append("%s: every step must be an object" % id)
				continue
			var step_id := String(step.get("id", ""))
			if step_id.is_empty() or step_id.length() > 96 or not step_id.is_valid_identifier():
				errors.append("%s: invalid step id '%s'" % [id, step_id])
			elif step_ids.has(step_id):
				errors.append("Duplicate step id: %s" % step_id)
			step_ids[step_id] = true
			var step_type := String(step.get("type", ""))
			match step_type:
				"line":
					var line_id := String(step.get("id", ""))
					if line_ids.has(line_id):
						errors.append("Duplicate line id: %s" % line_id)
					line_ids[line_id] = true
					var speaker := String(step.get("speaker", "narrator"))
					if speaker != "narrator" and speaker != "player" and not characters.has(speaker):
						errors.append("%s: unknown speaker '%s'" % [step_id, speaker])
					var text := String(step.get("text", "")).strip_edges()
					if text.is_empty() or text.length() > 1200:
						errors.append("%s: dialogue must contain 1-1200 characters" % step_id)
					if characters.has(speaker):
						var expression := String(step.get("expression", "neutral"))
						if expression not in characters[speaker].get("expressions", []):
							errors.append("%s: unknown expression '%s' for %s" % [step_id, expression, speaker])
					if step.has("delay") and (float(step["delay"]) < 0.0 or float(step["delay"]) > 10.0):
						errors.append("%s: delay must be between 0 and 10 seconds" % step_id)
				"choice":
					_validate_conditions(step.get("conditions", []), known_flags, "%s conditions" % step_id, errors)
					var options: Array = step.get("options", [])
					if options.is_empty():
						errors.append("%s: choice has no options" % step_id)
					var local_option_ids := {}
					for option in options:
						if not option is Dictionary:
							errors.append("%s: option must be an object" % step_id)
							continue
						var option_id := String(option.get("id", ""))
						if option_id.is_empty() or local_option_ids.has(option_id) or all_option_ids.has(option_id):
							errors.append("%s: invalid or duplicate option id '%s'" % [step_id, option_id])
						local_option_ids[option_id] = true
						all_option_ids[option_id] = true
						if String(option.get("text", "")).strip_edges().is_empty():
							errors.append("%s/%s: option text is required" % [step_id, option_id])
						_validate_conditions(option.get("conditions", []), known_flags, "%s/%s" % [step_id, option_id], errors)
						_validate_effects(option.get("effects", []), known_flags, known_memories, "%s/%s" % [step_id, option_id], errors)
						if String(option.get("target", "")).is_empty():
							errors.append("%s/%s: target is required" % [step_id, option_id])
				"effect":
					_validate_effects([step.get("effect", {})], known_flags, known_memories, step_id, errors)
				"jump":
					_validate_conditions(step.get("conditions", []), known_flags, "%s conditions" % step_id, errors)
					if String(step.get("target", "")).is_empty():
						errors.append("%s: jump target is required" % step_id)
				"event":
					_validate_conditions(step.get("conditions", []), known_flags, "%s conditions" % step_id, errors)
					var event_id := String(step.get("event_id", ""))
					if event_id.is_empty():
						errors.append("%s: event_id is required" % step_id)
				"end":
					pass
				_:
					errors.append("%s: unknown step type '%s'" % [step_id, step_type])
		if not String(scene.get("next_scene", "")).is_empty() and not String(scene.get("ending", "")).is_empty():
			errors.append("%s: scene cannot have both next_scene and ending" % id)

	# Reference checks happen after every id has been collected.
	for scene in scenes:
		if not scene is Dictionary:
			continue
		var id := String(scene.get("id", ""))
		var next_scene := String(scene.get("next_scene", ""))
		if not next_scene.is_empty() and not scene_ids.has(next_scene):
			errors.append("%s: unknown next_scene '%s'" % [id, next_scene])
		var ending := String(scene.get("ending", ""))
		if not ending.is_empty() and ending not in chapter.get("endings", []):
			errors.append("%s: unknown ending '%s'" % [id, ending])
		for step in scene.get("steps", []):
			if not step is Dictionary:
				continue
			var step_type := String(step.get("type", ""))
			if step_type == "jump":
				var target := String(step.get("target", ""))
				if not scene_ids.has(target):
					errors.append("%s: unknown jump target '%s'" % [step.get("id", ""), target])
				if target == id:
					errors.append("%s: unconditional self-jump can trap the player" % step.get("id", ""))
			elif step_type == "choice":
				for option in step.get("options", []):
					if option is Dictionary and not scene_ids.has(String(option.get("target", ""))):
						errors.append("%s: unknown choice target '%s'" % [option.get("id", ""), option.get("target", "")])

	for event in chapter.get("events", []):
		if not event is Dictionary:
			errors.append("Every event must be an object")
			continue
		var event_id := String(event.get("id", ""))
		if event_id.is_empty() or event_ids.has(event_id):
			errors.append("Invalid or duplicate event id: %s" % event_id)
		event_ids[event_id] = true
		_validate_conditions(event.get("conditions", []), known_flags, "event %s" % event_id, errors)
		_validate_effects(event.get("effects", []), known_flags, known_memories, "event %s" % event_id, errors)
	for scene in scenes:
		if scene is Dictionary:
			for step in scene.get("steps", []):
				if step is Dictionary and step.get("type") == "event" and not event_ids.has(String(step.get("event_id", ""))):
					errors.append("%s: unknown event '%s'" % [step.get("id", ""), step.get("event_id", "")])

	# Choice-condition references are checked after all option ids are known.
	var referenced_choices := {}
	for scene in scenes:
		if scene is Dictionary:
			_collect_choice_refs(scene.get("prerequisites", []), referenced_choices)
			for step in scene.get("steps", []):
				if step is Dictionary:
					_collect_choice_refs(step.get("conditions", []), referenced_choices)
					if step.get("type") == "choice":
						for option in step.get("options", []):
							if option is Dictionary:
								_collect_choice_refs(option.get("conditions", []), referenced_choices)
	for event in chapter.get("events", []):
		if event is Dictionary:
			_collect_choice_refs(event.get("conditions", []), referenced_choices)
	for choice_id in referenced_choices:
		if not all_option_ids.has(choice_id):
			errors.append("Unknown choice_made reference: %s" % choice_id)

	# Reachability ignores conditions; conditional content is checked by playthrough tests.
	var reachable := {}
	var queue: Array[String] = [String(chapter.get("start_scene", ""))]
	while not queue.is_empty():
		var current: String = queue.pop_front()
		if reachable.has(current) or not scene_ids.has(current):
			continue
		reachable[current] = true
		var scene: Dictionary = scene_ids[current]
		var next_scene := String(scene.get("next_scene", ""))
		if not next_scene.is_empty():
			queue.append(next_scene)
		for step in scene.get("steps", []):
			if step is Dictionary:
				if step.get("type") == "jump":
					queue.append(String(step.get("target", "")))
				elif step.get("type") == "choice":
					for option in step.get("options", []):
						if option is Dictionary:
							queue.append(String(option.get("target", "")))
	for scene_id in scene_ids:
		if not reachable.has(scene_id):
			errors.append("Scene is unreachable: %s" % scene_id)
	return errors


static func _collect_choice_refs(value: Variant, result: Dictionary) -> void:
	if value is Array:
		for child in value:
			_collect_choice_refs(child, result)
	elif value is Dictionary:
		if value.get("type") == "choice_made":
			result[String(value.get("key", ""))] = true
		if value.has("condition"):
			_collect_choice_refs(value["condition"], result)
		if value.has("conditions"):
			_collect_choice_refs(value["conditions"], result)


static func _validate_conditions(conditions: Variant, known_flags: Array, location: String, errors: PackedStringArray) -> void:
	if not conditions is Array:
		errors.append("%s: conditions must be an array" % location)
		return
	for condition in conditions:
		if not condition is Dictionary:
			errors.append("%s: condition must be an object" % location)
			continue
		var type := String(condition.get("type", ""))
		match type:
			"flag":
				if condition.get("key") not in known_flags:
					errors.append("%s: unknown flag '%s'" % [location, condition.get("key", "")])
				if condition.get("op") not in ["eq", "neq"]:
					errors.append("%s: flag conditions require eq/neq" % location)
			"relationship":
				if condition.get("key") not in GameState.RELATIONSHIP_KEYS:
					errors.append("%s: unknown relationship '%s'" % [location, condition.get("key", "")])
				if condition.get("op") not in ["eq", "neq", "gt", "gte", "lt", "lte"]:
					errors.append("%s: invalid relationship operator" % location)
				if int(condition.get("value", -99)) < 0 or int(condition.get("value", -99)) > 10:
					errors.append("%s: relationship threshold must be 0-10" % location)
			"boundary":
				if condition.get("key") not in GameState.BOUNDARY_KEYS:
					errors.append("%s: unknown boundary '%s'" % [location, condition.get("key", "")])
				if condition.get("op") not in ["set", "unset"]:
					errors.append("%s: boundary conditions require set/unset" % location)
			"scene_visited":
				if String(condition.get("key", "")).is_empty():
					errors.append("%s: scene_visited key is required" % location)
				if condition.get("op") not in ["eq", "neq"]:
					errors.append("%s: scene_visited requires eq/neq" % location)
			"choice_made":
				if String(condition.get("key", "")).is_empty() or not String(condition.get("key", "")).is_valid_identifier():
					errors.append("%s: choice_made key must be a valid option id" % location)
				if condition.get("op") not in ["eq", "neq"]:
					errors.append("%s: choice_made requires eq/neq" % location)
			"not":
				_validate_conditions([condition.get("condition", {})], known_flags, location + "/not", errors)
			"all", "any":
				_validate_conditions(condition.get("conditions", []), known_flags, location + "/" + type, errors)
			_:
				errors.append("%s: unknown condition type '%s'" % [location, type])


static func _validate_effects(effects: Variant, known_flags: Array, known_memories: Dictionary, location: String, errors: PackedStringArray) -> void:
	if not effects is Array:
		errors.append("%s: effects must be an array" % location)
		return
	for effect in effects:
		if not effect is Dictionary:
			errors.append("%s: effect must be an object" % location)
			continue
		match effect.get("type", ""):
			"set_flag":
				if effect.get("key") not in known_flags:
					errors.append("%s: unknown flag '%s'" % [location, effect.get("key", "")])
				if typeof(effect.get("value", true)) != TYPE_BOOL:
					errors.append("%s: flag value must be boolean" % location)
			"relationship":
				if effect.get("key") not in GameState.RELATIONSHIP_KEYS:
					errors.append("%s: unknown relationship '%s'" % [location, effect.get("key", "")])
				var delta := int(effect.get("delta", 0))
				if delta == 0 or abs(delta) > 3:
					errors.append("%s: relationship delta must be +/-1..3" % location)
				if String(effect.get("reason", "")).strip_edges().is_empty():
					errors.append("%s: relationship change needs an authored reason" % location)
			"add_boundary", "remove_boundary":
				if effect.get("key") not in GameState.BOUNDARY_KEYS:
					errors.append("%s: unknown boundary '%s'" % [location, effect.get("key", "")])
			"memory":
				if not known_memories.has(effect.get("id", "")):
					errors.append("%s: unknown memory id '%s'" % [location, effect.get("id", "")])
				if String(effect.get("text", "")).strip_edges().is_empty() or String(effect.get("text", "")).length() > 280:
					errors.append("%s: memory text must contain 1-280 characters" % location)
			_:
				errors.append("%s: unknown effect type '%s'" % [location, effect.get("type", "")])
