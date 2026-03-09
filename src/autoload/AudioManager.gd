extends Node

## AudioManager - 音频管理器
## 负责背景音乐、音效的播放和管理

signal music_changed(track_name: String)
signal sfx_played(sfx_name: String)

# 音频播放器
@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var ambient_player: AudioStreamPlayer = AudioStreamPlayer.new()

# 音量设置
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 1.0
var ambient_volume: float = 0.5

# 当前播放的曲目
var current_music: String = ""
var current_ambient: String = ""

func _ready() -> void:
	print("[AudioManager] Initialized")
	_setup_players()

func _setup_players() -> void:
	# 设置音乐播放器
	music_player.bus = "Music"
	music_player.name = "MusicPlayer"
	add_child(music_player)
	
	# 设置环境音播放器
	ambient_player.bus = "Ambient"
	ambient_player.name = "AmbientPlayer"
	add_child(ambient_player)
	
	# 创建音频总线
	_setup_audio_buses()

func _setup_audio_buses() -> void:
	# 确保音频总线存在
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus(1)
		AudioServer.set_bus_name(1, "Music")
	
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus(2)
		AudioServer.set_bus_name(2, "SFX")
	
	if AudioServer.get_bus_index("Ambient") == -1:
		AudioServer.add_bus(3)
		AudioServer.set_bus_name(3, "Ambient")
	
	_update_volumes()

func play_music(track_name: String, fade_duration: float = 1.0) -> void:
	if current_music == track_name:
		return
	
	var path: String = "res://assets/audio/bgm/" + track_name + ".ogg"
	if ResourceLoader.exists(path):
		var stream: AudioStream = load(path)
		music_player.stream = stream
		music_player.play()
		current_music = track_name
		music_changed.emit(track_name)
		print("[AudioManager] Playing music: ", track_name)
	else:
		push_warning("[AudioManager] Music track not found: " + path)

func stop_music(fade_duration: float = 1.0) -> void:
	music_player.stop()
	current_music = ""
	print("[AudioManager] Music stopped")

func play_sfx(sfx_name: String, volume_db: float = 0.0) -> void:
	var path: String = "res://assets/audio/sfx/" + sfx_name + ".wav"
	if ResourceLoader.exists(path):
		var stream: AudioStream = load(path)
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.stream = stream
		player.volume_db = volume_db
		player.bus = "SFX"
		player.name = "SFX_" + sfx_name
		add_child(player)
		player.play()
		
		# 播放完成后自动删除
		player.finished.connect(func(): player.queue_free())
		
		sfx_played.emit(sfx_name)
	else:
		push_warning("[AudioManager] SFX not found: " + path)

func play_ambient(ambient_name: String) -> void:
	if current_ambient == ambient_name:
		return
	
	var path: String = "res://assets/audio/ambient/" + ambient_name + ".ogg"
	if ResourceLoader.exists(path):
		var stream: AudioStream = load(path)
		ambient_player.stream = stream
		ambient_player.play()
		current_ambient = ambient_name
		print("[AudioManager] Playing ambient: ", ambient_name)
	else:
		push_warning("[AudioManager] Ambient track not found: " + path)

func set_master_volume(volume: float) -> void:
	master_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))

func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

func set_ambient_volume(volume: float) -> void:
	ambient_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

func _update_volumes() -> void:
	var music_bus: int = AudioServer.get_bus_index("Music")
	var sfx_bus: int = AudioServer.get_bus_index("SFX")
	var ambient_bus: int = AudioServer.get_bus_index("Ambient")
	
	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume * master_volume))
	if sfx_bus != -1:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume * master_volume))
	if ambient_bus != -1:
		AudioServer.set_bus_volume_db(ambient_bus, linear_to_db(ambient_volume * master_volume))

func mute_all() -> void:
	AudioServer.set_bus_mute(0, true)

func unmute_all() -> void:
	AudioServer.set_bus_mute(0, false)
