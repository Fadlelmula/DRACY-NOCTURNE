extends SceneTree
## Development utility: rasterize imported SVG art for visual review.

const EXPRESSIONS := [
	"neutral", "smiling", "mischievous", "sarcastic", "angry",
	"embarrassed", "flirting", "sad", "suspicious", "frightened",
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var output := ProjectSettings.globalize_path("user://art_review")
	DirAccess.make_dir_recursive_absolute(output)
	DirAccess.make_dir_recursive_absolute(output + "/expressions")
	for mode in EXPRESSIONS:
		_render("res://assets/characters/dracy/sprites/expressions/%s.svg" % mode,
				output + "/expressions/%s.png" % mode)
	_render("res://assets/characters/dracy/sprites/expressions/neutral.svg", output + "/dracy-neutral.png")
	_render("res://assets/characters/dracy/sprites/poses/standing.svg", output + "/dracy-standing.png")
	_render("res://assets/characters/dracy/sprites/poses/seated.svg", output + "/dracy-seated.png")
	_render("res://assets/characters/dracy/sprites/outfits/signature.svg", output + "/dracy-signature.png")
	_render("res://assets/characters/dracy/sprites/outfits/gothic.svg", output + "/dracy-gothic.png")
	_render("res://assets/characters/dracy/sprites/outfits/casual.svg", output + "/dracy-casual.png")
	_render("res://assets/characters/dracy/sprites/outfits/alternative.svg", output + "/dracy-alternative.png")
	_render("res://assets/backgrounds/menu_nocturne.svg", output + "/menu.png")
	_render("res://assets/backgrounds/bedroom.svg", output + "/bedroom.png")
	_render("res://assets/backgrounds/impossible_street.svg", output + "/street.png")
	print("Rendered art review images to " + output)
	quit()


func _render(path: String, output: String) -> void:
	var texture := load(path) as Texture2D
	if texture == null:
		push_error("Could not load preview source: " + path)
		return
	texture.get_image().save_png(output)
