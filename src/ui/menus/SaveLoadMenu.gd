extends Control
class_name SaveLoadMenu

## SaveLoadMenu - 存档/读档菜单
## 支持多存档槽位管理

signal save_completed(slot: int)
signal load_completed(slot: int)
signal menu_closed

enum Mode { SAVE, LOAD }

@export var mode: Mode = Mode.SAVE

const SLOT_COUNT: int = 3

# 节点引用
var slot_container: VBoxContainer
var button_container: HBoxContainer
var close_button: Button
var title_label: Label

# 存档槽位按钮
var slot_buttons: Array[Button] = []
var delete_buttons: Array[Button] = []

var selected_slot: int = -1

func _ready() -> void:
	_setup_ui()
	_refresh_slots()

func _setup_ui() -> void:
	# 创建主容器
	var main_vbox := VBoxContainer.new()
	main_vbox.name = "MainVBox"
	main_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(main_vbox)

	# 标题
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 32)
	main_vbox.add_child(title_label)
	_update_title()

	# 分隔
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	main_vbox.add_child(spacer)

	# 存档槽位容器
	slot_container = VBoxContainer.new()
	slot_container.name = "SlotContainer"
	slot_container.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(slot_container)

	# 创建存档槽位
	for i in range(SLOT_COUNT):
		var slot_hbox := HBoxContainer.new()
		slot_hbox.name = "SlotHBox" + str(i)
		slot_hbox.alignment = BoxContainer.ALIGNMENT_CENTER

		# 存档按钮
		var slot_button := Button.new()
		slot_button.name = "SlotButton" + str(i)
		slot_button.custom_minimum_size = Vector2(400, 80)
		slot_button.pressed.connect(_on_slot_pressed.bind(i))
		slot_hbox.add_child(slot_button)
		slot_buttons.append(slot_button)

		# 删除按钮
		var delete_button := Button.new()
		delete_button.name = "DeleteButton" + str(i)
		delete_button.text = "X"
		delete_button.custom_minimum_size = Vector2(40, 80)
		delete_button.pressed.connect(_on_delete_pressed.bind(i))
		slot_hbox.add_child(delete_button)
		delete_buttons.append(delete_button)

		slot_container.add_child(slot_hbox)

	# 分隔
	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 20)
	main_vbox.add_child(spacer2)

	# 按钮容器
	button_container = HBoxContainer.new()
	button_container.name = "ButtonContainer"
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(button_container)

	# 关闭按钮
	close_button = Button.new()
	close_button.name = "CloseButton"
	close_button.text = "关闭"
	close_button.custom_minimum_size = Vector2(120, 40)
	close_button.pressed.connect(_on_close_pressed)
	button_container.add_child(close_button)

	# 设置锚点和位置
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.5
	anchor_bottom = 0.5
	offset_left = -250
	offset_right = 250
	offset_top = -200
	offset_bottom = 200

func _update_title() -> void:
	if mode == Mode.SAVE:
		title_label.text = "保存游戏"
	else:
		title_label.text = "加载游戏"

func _refresh_slots() -> void:
	for i in range(SLOT_COUNT):
		var info: Dictionary = SaveManager.get_save_info(i)
		var button: Button = slot_buttons[i]
		var delete_button: Button = delete_buttons[i]

		if info.get("exists", false):
			var play_time: float = info.get("play_time", 0.0)
			var hours: int = int(play_time) / 3600
			var minutes: int = (int(play_time) % 3600) / 60
			var time_str: String = "%02d:%02d" % [hours, minutes]

			button.text = "存档 %d\n%s\n游戏时间: %s" % [
				i + 1,
				info.get("date", "Unknown"),
				time_str
			]
			button.disabled = (mode == Mode.LOAD and not SaveManager.has_save(i))
			delete_button.disabled = false
			delete_button.visible = true
		else:
			if mode == Mode.SAVE:
				button.text = "存档 %d\n- 空存档 -" % (i + 1)
				button.disabled = false
			else:
				button.text = "存档 %d\n- 空存档 -" % (i + 1)
				button.disabled = true
			delete_button.disabled = true
			delete_button.visible = false

func _on_slot_pressed(slot: int) -> void:
	selected_slot = slot

	if mode == Mode.SAVE:
		_save_game(slot)
	else:
		_load_game(slot)

func _save_game(slot: int) -> void:
	var success: bool = SaveManager.save_game(slot)
	if success:
		save_completed.emit(slot)
		_refresh_slots()
		_show_message("游戏已保存到存档 %d" % (slot + 1))
	else:
		_show_message("保存失败！")

func _load_game(slot: int) -> void:
	var success: bool = SaveManager.load_game(slot)
	if success:
		load_completed.emit(slot)
		_show_message("已加载存档 %d" % (slot + 1))
		# 加载成功后关闭菜单
		await get_tree().create_timer(0.5).timeout
		close()
	else:
		_show_message("加载失败！")

func _on_delete_pressed(slot: int) -> void:
	# 简单确认对话框
	var dialog := ConfirmationDialog.new()
	dialog.dialog_text = "确定要删除存档 %d 吗？" % (slot + 1)
	dialog.title = "删除存档"
	dialog.confirmed.connect(_confirm_delete.bind(slot))
	add_child(dialog)
	dialog.popup_centered()

func _confirm_delete(slot: int) -> void:
	SaveManager.delete_save(slot)
	_refresh_slots()
	_show_message("存档 %d 已删除" % (slot + 1))

func _on_close_pressed() -> void:
	close()

func close() -> void:
	menu_closed.emit()
	queue_free()

func _show_message(msg: String) -> void:
	print("[SaveLoadMenu] ", msg)
	# 可以添加通知显示

func set_mode(new_mode: Mode) -> void:
	mode = new_mode
	if title_label:
		_update_title()
		_refresh_slots()
