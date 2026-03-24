extends Control
class_name SettingsUI

## SettingsUI - 设置界面
## 游戏设置：音量、按键显示

signal settings_closed()

func _ready() -> void:
	hide()
	_populate_sliders()

func _populate_sliders() -> void:
	# 主音量
	if has_node("VBox/MainVolumeRow/Slider"):
		$VBox/MainVolumeRow/Slider.value = 1.0 if AudioManager == null else 1.0
	# 音乐音量
	if has_node("VBox/MusicVolumeRow/Slider"):
		$VBox/MusicVolumeRow/Slider.value = 0.8
	# 音效音量
	if has_node("VBox/SFXVolumeRow/Slider"):
		$VBox/SFXVolumeRow/Slider.value = 1.0

func open() -> void:
	show()
	_populate_sliders()
	get_tree().paused = true

func close() -> void:
	hide()
	get_tree().paused = false
	settings_closed.emit()

func _on_close_pressed() -> void:
	close()

func _on_main_volume_changed(value: float) -> void:
	if AudioManager and AudioManager.has_method("set_master_volume"):
		AudioManager.set_master_volume(value)
	print("[Settings] Master volume: %.0f%%" % (value * 100))

func _on_music_volume_changed(value: float) -> void:
	if AudioManager and AudioManager.has_method("set_music_volume"):
		AudioManager.set_music_volume(value)
	print("[Settings] Music volume: %.0f%%" % (value * 100))

func _on_sfx_volume_changed(value: float) -> void:
	if AudioManager and AudioManager.has_method("set_sfx_volume"):
		AudioManager.set_sfx_volume(value)
	print("[Settings] SFX volume: %.0f%%" % (value * 100))
