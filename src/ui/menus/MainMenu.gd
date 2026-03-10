extends Control
class_name MainMenu

## MainMenu - 主菜单
## 游戏启动时的主菜单界面

signal new_game_requested
signal load_game_requested
signal settings_requested
signal quit_game_requested

# 节点引用
var main_vbox: VBoxContainer
var title_label: Label
var new_game_button: Button
var load_game_button: Button
var settings_button: Button
var quit_button: Button
var version_label: Label

# 存档菜单引用
var save_load_menu: SaveLoadMenu = null

const GAME_VERSION: String = "1.0.0"

func _ready() -> void:
	_setup_ui()
	_update_load_button_state()

func _setup_ui() -> void:
	# 设置背景色
	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color(0.1, 0.15, 0.2)
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	add_child(background)

	# 主容器
	main_vbox = VBoxContainer.new()
	main_vbox.name = "MainVBox"
	main_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(main_vbox)

	# 游戏标题
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "Pastoral Tales"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 48)
	main_vbox.add_child(title_label)

	# 副标题
	var subtitle := Label.new()
	subtitle.text = "田园物语"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 24)
	subtitle.modulate = Color(0.7, 0.7, 0.7)
	main_vbox.add_child(subtitle)

	# 分隔
	_add_spacer(50)

	# 新游戏按钮
	new_game_button = _create_button("新游戏", "_on_new_game_pressed")
	main_vbox.add_child(new_game_button)

	# 加载游戏按钮
	load_game_button = _create_button("加载游戏", "_on_load_game_pressed")
	main_vbox.add_child(load_game_button)

	# 设置按钮
	settings_button = _create_button("设置", "_on_settings_pressed")
	main_vbox.add_child(settings_button)

	# 分隔
	_add_spacer(20)

	# 退出按钮
	quit_button = _create_button("退出游戏", "_on_quit_pressed")
	main_vbox.add_child(quit_button)

	# 分隔
	_add_spacer(40)

	# 版本号
	version_label = Label.new()
	version_label.text = "版本: " + GAME_VERSION
	version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version_label.modulate = Color(0.5, 0.5, 0.5)
	main_vbox.add_child(version_label)

	# 设置锚点居中
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.5
	anchor_bottom = 0.5
	offset_left = -150
	offset_right = 150
	offset_top = -250
	offset_bottom = 250

func _create_button(text: String, callback: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(200, 50)
	button.pressed.connect(Callable(self, callback))
	return button

func _add_spacer(height: float) -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	main_vbox.add_child(spacer)

func _update_load_button_state() -> void:
	# 检查是否有存档
	var has_any_save: bool = false
	var save_manager = get_node_or_null("/root/SaveManager")
	if save_manager:
		for i in range(10):  # MAX_SAVE_SLOTS
			if save_manager.has_save(i):
				has_any_save = true
				break
	if load_game_button:
		load_game_button.disabled = not has_any_save

func _on_new_game_pressed() -> void:
	print("[MainMenu] 新游戏按钮被点击")
	new_game_requested.emit()
	# 直接切换到农场场景
	_start_new_game()

func _start_new_game() -> void:
	print("[MainMenu] 开始新游戏...")
	# 初始化游戏状态
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		game_manager.start_game()
	# 切换到农场场景
	get_tree().change_scene_to_file("res://src/world/maps/Farm.tscn")

func _on_load_game_pressed() -> void:
	_open_load_menu()

func _on_settings_pressed() -> void:
	settings_requested.emit()
	# TODO: 打开设置界面

func _on_quit_pressed() -> void:
	quit_game_requested.emit()
	get_tree().quit()

func _open_load_menu() -> void:
	if save_load_menu:
		save_load_menu.queue_free()

	save_load_menu = SaveLoadMenu.new()
	save_load_menu.mode = SaveLoadMenu.Mode.LOAD
	save_load_menu.menu_closed.connect(_on_load_menu_closed)
	save_load_menu.load_completed.connect(_on_load_completed)
	add_child(save_load_menu)

func _on_load_menu_closed() -> void:
	save_load_menu = null

func _on_load_completed(_slot: int) -> void:
	# 加载完成后，开始游戏
	load_game_requested.emit()
