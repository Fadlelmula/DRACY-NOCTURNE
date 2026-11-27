extends Node
## Graphical startup check: lets the real main menu and audio initialize, then
## uses the same graceful quit path as the Quit button.

func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var menu: MainMenu = load("res://scenes/main_menu/main_menu.tscn").instantiate()
	get_tree().root.add_child(menu)
	for frame in 30:
		await get_tree().process_frame
	print("Graphical main-menu startup: PASS")
	await Audio.request_quit()
