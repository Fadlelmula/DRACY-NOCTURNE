class_name NarrativeCondition
extends RefCounted
## Pure, data-driven condition evaluation. Authored content and tests share this.
## Conditions are validated before a chapter is allowed to run.

const OPS := ["eq", "neq", "gt", "gte", "lt", "lte", "set", "unset"]


static func evaluate(condition: Dictionary, state: GameState) -> bool:
	match condition.get("type", ""):
		"flag":
			return _compare(state.flags.get(condition.get("key", ""), false), condition)
		"relationship":
			return _compare(float(state.relationships.get(condition.get("key", ""), 0)), condition)
		"boundary":
			var present: bool = condition.get("key", "") in state.boundaries
			return _compare(present, condition)
		"scene_visited":
			return _compare(condition.get("key", "") in state.visited_scenes, condition)
		"choice_made":
			return _compare(condition.get("key", "") in state.decisions, condition)
		"not":
			return not evaluate(condition.get("condition", {}), state)
		"all":
			for child in condition.get("conditions", []):
				if not evaluate(child, state):
					return false
			return true
		"any":
			for child in condition.get("conditions", []):
				if evaluate(child, state):
					return true
			return false
	return false


static func evaluate_all(conditions: Array, state: GameState) -> bool:
	for condition in conditions:
		if not evaluate(condition, state):
			return false
	return true


static func _compare(actual: Variant, condition: Dictionary) -> bool:
	var op := String(condition.get("op", "eq"))
	var expected: Variant = condition.get("value", null)
	match op:
		"eq": return actual == expected
		"neq": return actual != expected
		"gt": return float(actual) > float(expected)
		"gte": return float(actual) >= float(expected)
		"lt": return float(actual) < float(expected)
		"lte": return float(actual) <= float(expected)
		"set": return bool(actual) == bool(expected)
		"unset": return bool(actual) != bool(expected)
	return false
