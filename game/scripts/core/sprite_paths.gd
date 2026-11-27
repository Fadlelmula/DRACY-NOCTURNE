class_name SpritePaths
extends RefCounted
## Resolves Dracy art paths. Generated transparent PNGs win when present so a
## painted sprite set can be dropped in without editing any UI code; removing
## the generated folder restores the reproducible vector fallback.

const GENERATED_DIR := "res://assets/characters/dracy/sprites/generated/%s.png"
const VECTOR_EXPRESSION := "res://assets/characters/dracy/sprites/expressions/%s.svg"
const VECTOR_POSE := "res://assets/characters/dracy/sprites/poses/%s.svg"
const VECTOR_OUTFIT := "res://assets/characters/dracy/sprites/outfits/%s.svg"


static func expression(name: String) -> String:
	return _resolve(name, VECTOR_EXPRESSION)


static func pose(name: String) -> String:
	return _resolve(name, VECTOR_POSE)


static func outfit(name: String) -> String:
	return _resolve(name, VECTOR_OUTFIT)


static func uses_generated() -> bool:
	return ResourceLoader.exists(GENERATED_DIR % "neutral")


static func _resolve(name: String, vector_template: String) -> String:
	var generated := GENERATED_DIR % name
	if ResourceLoader.exists(generated):
		return generated
	return vector_template % name
