extends Control
class_name QuestTracker

## QuestTracker - 任务追踪UI
## 在屏幕边缘显示当前追踪任务的进度

## 任务面板场景
const QUEST_PANEL_SCENE: PackedScene = preload("res://src/ui/hud/QuestPanel.tscn")

## 追踪面板容器
@onready var _panel_container: VBoxContainer = $MarginContainer/VBoxContainer

## 标题标签
@onready var _title_label: Label = $MarginContainer/VBoxContainer/TitleLabel

## 任务列表容器
@onready var _quest_list: VBoxContainer = $MarginContainer/VBoxContainer/QuestList

## 展开/折叠按钮
@onready var _toggle_button: Button = $MarginContainer/VBoxContainer/ToggleButton

## 是否展开
var _is_expanded: bool = true

## 最大显示任务数
const MAX_DISPLAYED_QUESTS: int = 5

## 当前追踪的任务ID列表
var _tracked_quests: Array[String] = []

## 任务面板缓存
var _quest_panels: Dictionary = {}

## 动画持续时间
const ANIM_DURATION: float = 0.3


func _ready() -> void:
	_connect_signals()
	_create_toggle_button()
	_update_display()


func _connect_signals() -> void:
	if QuestSystem:
		QuestSystem.quest_accepted.connect(_on_quest_accepted)
		QuestSystem.quest_completed.connect(_on_quest_completed)
		QuestSystem.quest_turned_in.connect(_on_quest_turned_in)
		QuestSystem.quest_progress_updated.connect(_on_quest_progress_updated)
		QuestSystem.objective_completed.connect(_on_objective_completed)
		QuestSystem.quest_failed.connect(_on_quest_failed)


func _create_toggle_button() -> void:
	if _toggle_button:
		_toggle_button.text = "收起"
		_toggle_button.pressed.connect(_toggle_expanded)


func _toggle_expanded() -> void:
	_is_expanded = not _is_expanded

	if _toggle_button:
		_toggle_button.text = "展开" if not _is_expanded else "收起"

	if _quest_list:
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_QUAD)

		if _is_expanded:
			_quest_list.visible = true
			tween.tween_property(_quest_list, "modulate:a", 1.0, ANIM_DURATION)
		else:
			tween.tween_property(_quest_list, "modulate:a", 0.0, ANIM_DURATION)
			tween.tween_callback(func(): _quest_list.visible = false)


func _update_display() -> void:
	if not _quest_list:
		return

	# 清空现有面板
	for child in _quest_list.get_children():
		child.queue_free()

	_quest_panels.clear()

	# 获取活跃任务
	if not QuestSystem:
		return

	var active_quests: Array = QuestSystem.get_active_quests()

	# 限制显示数量
	var display_count: int = mini(active_quests.size(), MAX_DISPLAYED_QUESTS)

	for i in range(display_count):
		var quest: QuestSystem.QuestData = active_quests[i]
		_add_quest_panel(quest)

	# 更新标题
	if _title_label:
		if active_quests.size() > MAX_DISPLAYED_QUESTS:
			_title_label.text = "任务追踪 (%d/%d)" % [MAX_DISPLAYED_QUESTS, active_quests.size()]
		else:
			_title_label.text = "任务追踪 (%d)" % active_quests.size()


func _add_quest_panel(quest: QuestSystem.QuestData) -> void:
	if not _quest_list:
		return

	var panel: Control = _create_quest_panel(quest)
	_quest_list.add_child(panel)
	_quest_panels[quest.id] = panel


func _create_quest_panel(quest: QuestSystem.QuestData) -> Control:
	# 创建面板容器
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(250, 0)

	# 创建样式
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.85)
	style.border_color = Color(0.3, 0.3, 0.4)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)

	# 内容容器
	var content: VBoxContainer = VBoxContainer.new()
	content.add_theme_constant_override("separation", 4)
	panel.add_child(content)

	# 任务标题
	var title: Label = Label.new()
	title.text = quest.title
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.6))
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 2)
	content.add_child(title)

	# 目标列表
	var progress: QuestSystem.QuestProgress = QuestSystem.get_quest_progress(quest.id)

	for i in quest.objectives.size():
		var objective: Dictionary = quest.objectives[i]
		var current: int = progress.objective_progress[i] if progress and i < progress.objective_progress.size() else 0
		var required: int = objective.required

		var obj_label: Label = Label.new()
		obj_label.text = QuestSystem.get_objective_description(quest.id, i)

		# 完成状态颜色
		if current >= required:
			obj_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
			obj_label.text = "✓ " + obj_label.text
		else:
			obj_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
			obj_label.text = "○ " + obj_label.text + " (%d/%d)" % [current, required]

		obj_label.add_theme_font_size_override("font_size", 12)
		obj_label.add_theme_color_override("font_outline_color", Color.BLACK)
		obj_label.add_theme_constant_override("outline_size", 1)
		obj_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content.add_child(obj_label)

	# 完成进度条
	if quest.objectives.size() > 1:
		var progress_bar: ProgressBar = ProgressBar.new()
		progress_bar.custom_minimum_size = Vector2(0, 8)
		progress_bar.show_percentage = false

		var completed: int = 0
		for i in quest.objectives.size():
			if QuestSystem.is_objective_completed(quest.id, i):
				completed += 1

		progress_bar.max_value = quest.objectives.size()
		progress_bar.value = completed

		# 进度条样式
		var bg_style: StyleBoxFlat = StyleBoxFlat.new()
		bg_style.bg_color = Color(0.2, 0.2, 0.2)
		bg_style.set_corner_radius_all(4)
		progress_bar.add_theme_stylebox_override("background", bg_style)

		var fill_style: StyleBoxFlat = StyleBoxFlat.new()
		fill_style.bg_color = Color(0.3, 0.7, 0.3)
		fill_style.set_corner_radius_all(4)
		progress_bar.add_theme_stylebox_override("fill", fill_style)

		content.add_child(progress_bar)

	return panel


func _refresh_quest_panel(quest_id: String) -> void:
	if not _quest_panels.has(quest_id):
		return

	var quest: QuestSystem.QuestData = QuestSystem.get_quest(quest_id)
	if not quest:
		return

	# 移除旧面板
	var old_panel: Control = _quest_panels[quest_id]
	var index: int = old_panel.get_index()

	old_panel.queue_free()
	_quest_panels.erase(quest_id)

	# 创建新面板
	await get_tree().process_frame

	if _quest_list and _quest_list.get_child_count() >= index:
		var new_panel: Control = _create_quest_panel(quest)
		_quest_list.add_child(new_panel)
		_quest_list.move_child(new_panel, index)
		_quest_panels[quest_id] = new_panel


# ===== 信号处理 =====


func _on_quest_accepted(quest_id: String) -> void:
	_update_display()
	_show_notification("新任务: " + _get_quest_title(quest_id))


func _on_quest_completed(quest_id: String) -> void:
	_show_notification("任务完成: " + _get_quest_title(quest_id), true)
	_update_display()


func _on_quest_turned_in(quest_id: String, _rewards: Dictionary) -> void:
	if _quest_panels.has(quest_id):
		var panel: Control = _quest_panels[quest_id]
		panel.queue_free()
		_quest_panels.erase(quest_id)

	_update_display()


func _on_quest_progress_updated(quest_id: String, _objective_index: int, _current: int, _required: int) -> void:
	_refresh_quest_panel(quest_id)


func _on_objective_completed(quest_id: String, _objective_index: int) -> void:
	_refresh_quest_panel(quest_id)


func _on_quest_failed(quest_id: String, _reason: String) -> void:
	_show_notification("任务失败: " + _get_quest_title(quest_id), false, true)
	_update_display()


func _get_quest_title(quest_id: String) -> String:
	var quest: QuestSystem.QuestData = QuestSystem.get_quest(quest_id)
	if quest:
		return quest.title
	return quest_id


func _show_notification(message: String, is_complete: bool = false, is_fail: bool = false) -> void:
	if EventBus:
		var type: int = 0  # 普通通知
		if is_complete:
			type = 1  # 成功通知
		elif is_fail:
			type = 2  # 失败通知
		EventBus.notification_shown.emit(message, type)


## 打开任务日志界面
func open_quest_log() -> void:
	# TODO: 实现任务日志界面
	print("[QuestTracker] Opening quest log...")


## 追踪指定任务
func track_quest(quest_id: String) -> void:
	if not _tracked_quests.has(quest_id):
		_tracked_quests.append(quest_id)
		_update_display()


## 取消追踪任务
func untrack_quest(quest_id: String) -> void:
	if _tracked_quests.has(quest_id):
		_tracked_quests.erase(quest_id)
		_update_display()


## 获取追踪的任务列表
func get_tracked_quests() -> Array[String]:
	return _tracked_quests


## 保存设置
func save_settings() -> Dictionary:
	return {
		"is_expanded": _is_expanded,
		"tracked_quests": _tracked_quests
	}


## 加载设置
func load_settings(data: Dictionary) -> void:
	_is_expanded = data.get("is_expanded", true)
	_tracked_quests.clear()

	for qid in data.get("tracked_quests", []):
		_tracked_quests.append(str(qid))

	if _toggle_button:
		_toggle_button.text = "展开" if not _is_expanded else "收起"

	_update_display()