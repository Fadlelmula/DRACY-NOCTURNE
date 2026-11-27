extends Node
## Headless UI smoke test loaded as a normal scene so project autoloads exist.
## Run: godot --headless --path game res://tests/smoke_playthrough.tscn

var failures: int = 0
var checks: int = 0
var _old_reduced_motion: bool
var _old_ai_enabled: bool


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	print("\n=== DRACY: NOCTURNE — UI smoke playthrough ===")
	_old_reduced_motion = Settings.reduced_motion
	_old_ai_enabled = Settings.ai_enabled
	Settings.reduced_motion = true
	Settings.ai_enabled = false
	SaveManager.save_dir_override = "user://dracy_ui_smoke_saves"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveManager.save_dir_override))
	VisualNovel.launch_mode = "new"
	VisualNovel.launch_player_name = "Smoke Tester"
	VisualNovel.launch_slot = "autosave"
	var scene := load("res://scenes/visual_novel/visual_novel.tscn").instantiate() as VisualNovel
	get_tree().root.add_child(scene)
	await get_tree().process_frame
	await get_tree().process_frame
	_check(scene.engine != null and scene.state != null, "visual novel initializes engine and state")
	_check(scene.chat.visible, "prologue opens in the messaging interface")
	var expression_paths := {}
	var guard := 0
	while not scene.engine.finished and guard < 800:
		guard += 1
		if scene._presenting:
			await get_tree().create_timer(0.02).timeout
			continue
		if scene.engine.current_line.get("speaker", "") == "dracy" and scene.portrait.sprite != null:
			expression_paths[scene.portrait.sprite.texture.resource_path] = true
		if not scene.engine.pending_choices.is_empty():
			scene._on_choice_selected(String(scene.engine.pending_choices[0].get("id", "")))
		else:
			scene._advance()
		await get_tree().process_frame
	_check(scene.engine.finished, "presentation coordinator completes the prologue")
	_check(scene.state.completed_chapters.has("prologue"), "completion persists in state")
	_check(expression_paths.size() >= 2, "portrait expressions change during the story")
	_check(scene.dialogue.visible, "later scenes use visual-novel dialogue presentation")
	await get_tree().create_timer(0.25).timeout
	_check(scene.current_modal is EndPanel, "completion opens the ending panel")
	var saved := SaveManager.load_game("autosave")
	_check(saved != null and saved.completed_chapters.has("prologue"), "completed autosave reloads after restart")

	scene._open_settings()
	await get_tree().process_frame
	_check(scene.current_modal is SettingsPanel, "settings panel opens")
	scene._close_modal()
	scene._open_save()
	await get_tree().process_frame
	_check(scene.current_modal is SavePanel, "manual save panel opens")
	scene._close_modal()
	scene._open_load()
	await get_tree().process_frame
	_check(scene.current_modal is SavePanel, "load panel opens")
	scene._close_modal()
	scene._open_backlog()
	await get_tree().process_frame
	_check(scene.current_modal is BacklogPanel, "transcript panel opens")
	scene._close_modal()
	scene._open_data()
	await get_tree().process_frame
	_check(scene.current_modal is MemoryDataPanel, "memory and privacy panel opens")
	scene._close_modal()

	scene._open_free_chat()
	await get_tree().process_frame
	await get_tree().process_frame
	_check(scene.current_modal is FreeChatPanel, "post-prologue conversation opens")
	var free_chat := scene.current_modal as FreeChatPanel
	if free_chat != null:
		free_chat.input.text = "Tell me about your matchmaking disaster"
		free_chat._send_custom()
		await get_tree().create_timer(1.0).timeout
		_check(free_chat.message_list.get_child_count() >= 3, "offline fallback conversation sends and receives")
		_check(free_chat.turns.size() == 2, "free-chat turns remain session-only")

	scene.queue_free()
	await get_tree().process_frame
	var menu: MainMenu = load("res://scenes/main_menu/main_menu.tscn").instantiate()
	get_tree().root.add_child(menu)
	await get_tree().process_frame
	_check(menu is MainMenu, "main menu initializes independently")
	menu.queue_free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveManager.save_dir_override))
	SaveManager.save_dir_override = ""
	Settings.reduced_motion = _old_reduced_motion
	Settings.ai_enabled = _old_ai_enabled
	print("=== UI smoke: %d checks, %d failures ===" % [checks, failures])
	await Audio.request_quit(1 if failures > 0 else 0)


func _check(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + message)
	else:
		failures += 1
		push_error("FAIL: " + message)
