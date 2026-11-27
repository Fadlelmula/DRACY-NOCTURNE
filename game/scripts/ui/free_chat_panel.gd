class_name FreeChatPanel
extends Control
## Optional conversation sandbox. It can display AI replies but cannot mutate
## story flags, boundaries, memories, or relationship dimensions.

signal closed

var state: GameState
var content: Dictionary = {}
var message_list: VBoxContainer
var scroll: ScrollContainer
var status_label: Label
var input: LineEdit
var send_button: Button
var topic_row: HBoxContainer
var ai_client: AiClient
var turns: Array[Dictionary] = []
var busy: bool = false


func _ready() -> void:
	var file := FileAccess.open("res://content/dialogue/offline_chat.json", FileAccess.READ)
	if file != null:
		content = JSON.parse_string(file.get_as_text())
	ai_client = AiClient.new()
	add_child(ai_client)
	_build()


func configure(player_state: GameState) -> void:
	state = player_state


func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.01, 0.005, 0.02, 0.9)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.offset_left = 100
	margin.offset_right = -100
	margin.offset_top = 55
	margin.offset_bottom = -45
	add_child(margin)
	var panel := UIFactory.panel(Color(0.03, 0.017, 0.047, 0.98))
	margin.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	panel.add_child(column)
	var header := HBoxContainer.new()
	var title := UIFactory.label("AFTER THE PROLOGUE", 30, UITheme.INK, true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	status_label = UIFactory.label("Offline scripted mode" if not Settings.ai_enabled else "Optional AI · backend required", 12, Color("#c586a0"))
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(status_label)
	var close := UIFactory.button("Close")
	close.custom_minimum_size = Vector2(110, 38)
	close.pressed.connect(func() -> void: closed.emit())
	header.add_child(close)
	column.add_child(header)
	var note := UIFactory.label("This conversation cannot change the story or relationship values. If the backend is unavailable, Dracy uses authored offline replies.", 12, Color("#907486"))
	column.add_child(note)
	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	message_list = VBoxContainer.new()
	message_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_list.add_theme_constant_override("separation", 10)
	scroll.add_child(message_list)
	topic_row = HBoxContainer.new()
	topic_row.add_theme_constant_override("separation", 7)
	column.add_child(topic_row)
	for topic in content.get("topics", []):
		var button := UIFactory.button(String(topic.get("label", "")))
		button.custom_minimum_size = Vector2(0, 36)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var topic_id := String(topic.get("id", ""))
		button.pressed.connect(func() -> void: _send_topic(topic_id))
		topic_row.add_child(button)
	var input_row := HBoxContainer.new()
	column.add_child(input_row)
	input = LineEdit.new()
	input.placeholder_text = "Say something to Dracy…"
	input.max_length = 400
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input.text_submitted.connect(func(_text: String) -> void: _send_custom())
	input_row.add_child(input)
	send_button = UIFactory.button("Send", true)
	send_button.custom_minimum_size = Vector2(110, 42)
	send_button.pressed.connect(_send_custom)
	input_row.add_child(send_button)
	call_deferred("_show_greeting")


func _show_greeting() -> void:
	var greeting_key := "promise_greeting" if state != null and state.flags.get("promised_to_meet", false) else "greeting"
	_append("dracy", String(content.get(greeting_key, "Hello.")))


func _send_topic(topic_id: String) -> void:
	if busy:
		return
	for topic in content.get("topics", []):
		if topic.get("id") == topic_id:
			_send(String(topic.get("label", "")), String(topic.get("text", "")))
			return


func _send_custom() -> void:
	if busy:
		return
	var message := input.text.strip_edges()
	if message.is_empty():
		return
	input.clear()
	_send(message, _offline_reply(message))


func _send(message: String, fallback: String) -> void:
	busy = true
	send_button.disabled = true
	input.editable = false
	_append("player", message)
	status_label.text = "Dracy is typing…"
	await get_tree().create_timer(0.65 if not Settings.reduced_motion else 0.1).timeout
	if not is_instance_valid(self):
		return
	var reply := fallback
	var used_ai := false
	if Settings.ai_enabled:
		var response := await ai_client.request_async(message, _build_context())
		if response.get("ok", false):
			reply = String(response.get("reply", fallback))
			used_ai = true
		else:
			status_label.text = "Backend unavailable · using offline reply"
	_append("dracy", reply)
	turns.append({"role": "user", "content": message})
	turns.append({"role": "assistant", "content": reply})
	if turns.size() > 12:
		turns = turns.slice(turns.size() - 12)
	status_label.text = "Optional AI connected" if used_ai else "Offline scripted mode"
	busy = false
	send_button.disabled = false
	input.editable = true
	input.grab_focus()


func _build_context() -> Dictionary:
	var safe_flags := [
		"dracy_shared_first_photo", "respected_dracy_busy", "player_shared_name",
		"player_suspects_supernatural_activity", "gateway_discovered",
		"dracy_secret_partially_revealed", "promised_to_meet", "dracy_felt_safe"
	]
	var flags := {}
	for key in safe_flags:
		flags[key] = bool(state.flags.get(key, false))
	return {
		"character": "dracy",
		"chapter_id": "prologue",
		"chapter_complete": "prologue" in state.completed_chapters,
		"player_name": state.player_name,
		"flags": flags,
		"relationships": state.relationships.duplicate(true),
		"boundaries": state.boundaries.duplicate(),
		"memories": state.memories.duplicate(true),
		"recent_turns": turns.duplicate(true)
	}


func _offline_reply(message: String) -> String:
	var lowered := message.to_lower()
	for key in content.get("keywords", {}):
		for keyword in content["keywords"][key]:
			if keyword in lowered:
				return String(content.get("fallbacks", {}).get(key, content.get("fallbacks", {}).get("default", "")))
	return String(content.get("fallbacks", {}).get("default", "I am listening."))


func _append(speaker: String, text: String) -> void:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_list.add_child(row)
	var bubble := PanelContainer.new()
	bubble.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var is_player := speaker == "player"
	bubble.add_theme_stylebox_override("panel", UITheme._box(Color(0.16, 0.07, 0.14, 0.96) if is_player else Color(0.07, 0.035, 0.095, 0.98), Color(0.42, 0.18, 0.35, 0.7), 12, 1))
	if is_player:
		var gap := Control.new()
		gap.custom_minimum_size.x = 120
		row.add_child(gap)
	row.add_child(bubble)
	if not is_player:
		var gap := Control.new()
		gap.custom_minimum_size.x = 120
		row.add_child(gap)
	var label := UIFactory.label((state.player_name if is_player else "Dracy") + "\n" + text, 16, UITheme.INK)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bubble.add_child(label)
	await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(scroll):
		scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
