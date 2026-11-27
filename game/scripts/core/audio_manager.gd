class_name AudioManager
extends Node
## Original soundtrack playback with seamless loops, crossfades, and UI SFX.

var _music_a: AudioStreamPlayer
var _music_b: AudioStreamPlayer
var _active: AudioStreamPlayer
var _current_track: String = ""
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_index: int = 0
var _ambience: AudioStreamPlayer
var _music_tween: Tween
var _quitting: bool = false
var _headless: bool = false


func _ready() -> void:
	_headless = DisplayServer.get_name() == "headless"
	get_tree().auto_accept_quit = false
	_music_a = AudioStreamPlayer.new()
	_music_b = AudioStreamPlayer.new()
	_music_a.bus = "Music"
	_music_b.bus = "Music"
	_music_a.volume_db = -80.0
	_music_b.volume_db = -80.0
	add_child(_music_a)
	add_child(_music_b)
	_active = _music_a
	_ambience = AudioStreamPlayer.new()
	_ambience.bus = "SFX"
	_ambience.volume_db = -12.0
	add_child(_ambience)
	for index in 6:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_players.append(player)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		request_quit()


func request_quit(exit_code: int = 0) -> void:
	if _quitting:
		return
	_quitting = true
	prepare_shutdown()
	await get_tree().create_timer(0.2).timeout
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().quit(exit_code)


func prepare_shutdown() -> void:
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	_music_a.stop()
	_music_b.stop()
	_music_a.stream = null
	_music_b.stream = null
	_ambience.stop()
	_ambience.stream = null
	for player in _sfx_players:
		player.stop()
		player.stream = null


func _exit_tree() -> void:
	# Fallback for explicit engine shutdown paths.
	prepare_shutdown()


func play_music(track: String, fade_time: float = 1.8) -> void:
	if _headless or track == _current_track:
		return
	var path := "res://assets/audio/music/%s.wav" % track
	if not ResourceLoader.exists(path):
		push_warning("AudioManager: missing music '%s'" % track)
		return
	var source := load(path) as AudioStreamWAV
	if source == null:
		return
	var stream := source.duplicate() as AudioStreamWAV
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = int(stream.get_length() * float(stream.mix_rate))
	var next_player := _music_b if _active == _music_a else _music_a
	var previous := _active
	next_player.stream = stream
	next_player.volume_db = -80.0
	next_player.play()
	_active = next_player
	_current_track = track
	var tween := create_tween()
	_music_tween = tween
	tween.set_parallel(true)
	tween.tween_property(next_player, "volume_db", 0.0, fade_time)
	tween.tween_property(previous, "volume_db", -80.0, fade_time)
	tween.chain().tween_callback(previous.stop)


func stop_music(fade_time: float = 1.0) -> void:
	var previous := _active
	_current_track = ""
	var tween := create_tween()
	tween.tween_property(previous, "volume_db", -80.0, fade_time)
	tween.tween_callback(previous.stop)


func play_ambience(name: String) -> void:
	if _headless:
		return
	var path := "res://assets/audio/ambience/%s.wav" % name
	if not ResourceLoader.exists(path):
		stop_ambience()
		return
	if _ambience.stream != null and _ambience.stream.resource_path == path and _ambience.playing:
		return
	var source := load(path) as AudioStreamWAV
	var stream := source.duplicate() as AudioStreamWAV
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = int(stream.get_length() * float(stream.mix_rate))
	_ambience.stream = stream
	_ambience.play()


func stop_ambience() -> void:
	_ambience.stop()
	_ambience.stream = null


func play_sfx(name: String) -> void:
	if _headless:
		return
	var path := "res://assets/audio/sfx/%s.wav" % name
	if not ResourceLoader.exists(path):
		return
	var player := _sfx_players[_sfx_index]
	_sfx_index = (_sfx_index + 1) % _sfx_players.size()
	player.stream = load(path)
	player.play()
