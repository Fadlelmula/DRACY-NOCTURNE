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
		_render(SpritePaths.expression(mode), output + "/expressions/%s.png" % mode)
	_render(SpritePaths.expression("neutral"), output + "/dracy-neutral.png")
	_render(SpritePaths.pose("standing"), output + "/dracy-standing.png")
	_render(SpritePaths.pose("seated"), output + "/dracy-seated.png")
	_render(SpritePaths.outfit("signature"), output + "/dracy-signature.png")
	_render(SpritePaths.outfit("gothic"), output + "/dracy-gothic.png")
	_render(SpritePaths.outfit("casual"), output + "/dracy-casual.png")
	_render(SpritePaths.outfit("alternative"), output + "/dracy-alternative.png")
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
