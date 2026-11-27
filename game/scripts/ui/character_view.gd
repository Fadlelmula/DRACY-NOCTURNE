class_name CharacterView
extends Control
## Displays one complete transparent expression sprite. Every expression is
## generated from the same approved master, preventing identity drift.


var sprite: TextureRect
var _expression_tween: Tween
var _queued_expression: String = "neutral"


func _ready() -> void:
	sprite = TextureRect.new()
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sprite)
	set_expression(_queued_expression)


func set_expression(name: String) -> void:
	_queued_expression = name
	if sprite == null:
		return
	var path := SpritePaths.expression(name)
	if not ResourceLoader.exists(path):
		path = SpritePaths.expression("neutral")
	var texture := load(path) as Texture2D
	if texture == null:
		return
	if _expression_tween != null and _expression_tween.is_valid():
		_expression_tween.kill()
	sprite.texture = texture
	sprite.modulate.a = 0.0
	if Settings.reduced_motion:
		sprite.modulate.a = 1.0
		return
	_expression_tween = create_tween()
	_expression_tween.tween_property(sprite, "modulate:a", 1.0, 0.18)


func set_portrait_opacity(value: float) -> void:
	if sprite != null:
		sprite.modulate.a = value
