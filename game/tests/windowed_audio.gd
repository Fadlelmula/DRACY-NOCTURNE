extends Node

func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	Audio.play_music("prologue_theme", 0.1)
	Audio.play_sfx("message")
	await get_tree().create_timer(0.5).timeout
	Audio.play_sfx("click")
	await get_tree().create_timer(0.3).timeout
	print("Graphical audio playback: PASS")
	await Audio.request_quit()
