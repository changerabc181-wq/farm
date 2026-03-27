extends Control
class_name FestivalUI

## FestivalUI - 节日界面
## 显示节日信息、活动列表、奖励等

# 信号
signal closed
signal activity_selected(activity_id: String)
signal reward_claimed(reward_id: String)

# UI节点
@onready var panel: PanelContainer = $PanelContainer
@onready var title_label: Label = $PanelContainer/VBoxContainer/Header/TitleLabel
@onready var description_label: Label = $PanelContainer/VBoxContainer/Header/DescriptionLabel
@onready var time_label: Label = $PanelContainer/VBoxContainer/Header/TimeLabel
@onready var progress_bar: ProgressBar = $PanelContainer/VBoxContainer/ProgressBox/ProgressBar
@onready var progress_label: Label = $PanelContainer/VBoxContainer/ProgressBox/ProgressLabel
@onready var activities_container: VBoxContainer = $PanelContainer/VBoxContainer/ActivitiesBox/ScrollContainer/ActivitiesList
@onready var rewards_container: VBoxContainer = $PanelContainer/VBoxContainer/RewardsBox/RewardsList
@onready var close_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/CloseButton
@onready var shop_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/ShopButton

# 当前节日数据
var current_festival_id: String = ""
var festival_data: Dictionary = {}

# 活动按钮场景
const ACTIVITY_BUTTON_SCENE = preload("res://src/ui/festival/FestivalActivityButton.tscn")
const REWARD_BUTTON_SCENE = preload("res://src/ui/festival/FestivalRewardButton.tscn")


func _ready() -> void:
	visible = false
	_connect_signals()
	_setup_buttons()


func _connect_signals() -> void:
	if EventBus:
		get_node("/root/EventBus").festival_started.connect(_on_festival_started)
		get_node("/root/EventBus").festival_ended.connect(_on_festival_ended)
		get_node("/root/EventBus").festival_activity_completed.connect(_on_activity_completed)
		get_node("/root/EventBus").festival_reward_claimed.connect(_on_reward_claimed)


func _setup_buttons() -> void:
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	if shop_button:
		shop_button.pressed.connect(_on_shop_pressed)


## 打开节日界面
func open_festival(festival_id: String) -> void:
	current_festival_id = festival_id
	festival_data = FestivalSystem.get_festival_data(festival_id)

	if festival_data.is_empty():
		push_warning("[FestivalUI] Festival not found: " + festival_id)
		return

	_update_display()
	visible = true
	get_node("/root/EventBus").ui_opened.emit("festival_ui")


## 关闭节日界面
func close() -> void:
	visible = false
	current_festival_id = ""
	festival_data = {}
	get_node("/root/EventBus").ui_closed.emit("festival_ui")
	closed.emit()


## 更新显示
func _update_display() -> void:
	if festival_data.is_empty():
		return

	# 更新标题和描述
	title_label.text = festival_data.get("name", "未知节日")
	description_label.text = festival_data.get("description", "")

	# 更新时间
	var start_hour: int = festival_data.get("start_hour", 10)
	var end_hour: int = festival_data.get("end_hour", 22)
	time_label.text = "活动时间: %d:00 - %d:00" % [start_hour, end_hour]

	# 更新进度
	_update_progress()

	# 更新活动列表
	_update_activities()

	# 更新奖励列表
	_update_rewards()

	# 更新商店按钮
	if shop_button:
		var vendors: Array = festival_data.get("vendors", [])
		shop_button.visible = not vendors.is_empty()


## 更新进度
func _update_progress() -> void:
	var progress = FestivalSystem.get_festival_progress(current_festival_id)

	progress_bar.max_value = progress.get("total_activities", 1)
	progress_bar.value = progress.get("completed_activities", 0)

	var completed: int = progress.get("completed_activities", 0)
	var total: int = progress.get("total_activities", 0)
	progress_label.text = "活动进度: %d/%d" % [completed, total]


## 更新活动列表
func _update_activities() -> void:
	# 清空现有按钮
	for child in activities_container.get_children():
		child.queue_free()

	var activities = FestivalSystem.get_available_activities(current_festival_id)

	for activity in activities:
		_create_activity_button(activity)


## 创建活动按钮
func _create_activity_button(activity: Dictionary) -> void:
	var button := Button.new()
	button.text = activity.get("name", "未知活动")

	if activity.get("completed", false):
		button.text += " [已完成]"
		button.modulate = Color(0.6, 0.6, 0.6)

	button.tooltip_text = activity.get("description", "")

	var activity_id: String = activity.get("id", "")
	button.pressed.connect(func(): _on_activity_button_pressed(activity_id, activity))

	activities_container.add_child(button)


## 更新奖励列表
func _update_rewards() -> void:
	# 清空现有按钮
	for child in rewards_container.get_children():
		child.queue_free()

	var rewards: Array = festival_data.get("rewards", [])

	for reward in rewards:
		_create_reward_button(reward)


## 创建奖励按钮
func _create_reward_button(reward: Dictionary) -> void:
	var button := Button.new()
	button.text = reward.get("name", "未知奖励")

	var reward_id: String = reward.get("id", "")
	var requirements: Dictionary = reward.get("requirements", {})
	var required_activities: int = requirements.get("activities_completed", 0)

	# 检查是否可领取
	var progress = FestivalSystem.get_festival_progress(current_festival_id)
	var completed: int = progress.get("completed_activities", 0)

	if completed >= required_activities:
		button.text += " [可领取]"
		button.modulate = Color(0.8, 1.0, 0.8)
	else:
		button.text += " (需要完成 %d 项活动)" % required_activities
		button.modulate = Color(0.7, 0.7, 0.7)
		button.disabled = true

	button.tooltip_text = reward.get("description", "")
	button.pressed.connect(func(): _on_reward_button_pressed(reward_id))

	rewards_container.add_child(button)


## 信号回调：节日开始
func _on_festival_started(festival_id: String, _data: Dictionary) -> void:
	# 可选：自动打开节日界面
	pass


## 信号回调：节日结束
func _on_festival_ended(_festival_id: String, _data: Dictionary) -> void:
	if visible:
		close()


## 信号回调：活动完成
func _on_activity_completed(festival_id: String, _activity_id: String, _rewards: Dictionary) -> void:
	if festival_id == current_festival_id:
		_update_display()


## 信号回调：奖励领取
func _on_reward_claimed(festival_id: String, _reward_id: String) -> void:
	if festival_id == current_festival_id:
		_update_display()


## 活动按钮点击
func _on_activity_button_pressed(activity_id: String, activity: Dictionary) -> void:
	# 检查是否有小游戏
	var minigame: String = activity.get("minigame", "")

	if not minigame.is_empty():
		_start_minigame(minigame, activity_id, activity)
	else:
		# 直接完成活动
		var result := FestivalSystem.complete_festival_activity(current_festival_id, activity_id)
		if result.get("success", false):
			_show_result_dialog("活动完成！", result.get("rewards", {}))
		else:
			_show_error_dialog(result.get("message", "无法完成活动"))


## 开始小游戏
func _start_minigame(minigame_id: String, activity_id: String, activity: Dictionary) -> void:
	# 这里应该加载并启动小游戏场景
	# 小游戏完成后调用 FestivalSystem.complete_festival_activity
	print("[FestivalUI] Starting minigame: ", minigame_id)

	# 模拟小游戏完成
	var result := FestivalSystem.complete_festival_activity(current_festival_id, activity_id)
	if result.get("success", false):
		_show_result_dialog("活动完成！", result.get("rewards", {}))


## 奖励按钮点击
func _on_reward_button_pressed(reward_id: String) -> void:
	var result := FestivalSystem.claim_festival_reward(current_festival_id, reward_id)

	if result.get("success", false):
		_show_result_dialog("奖励领取成功！", result.get("items", {}))
		reward_claimed.emit(reward_id)
	else:
		_show_error_dialog(result.get("message", "无法领取奖励"))


## 显示结果对话框
func _show_result_dialog(title: String, rewards: Dictionary) -> void:
	var reward_lines := []
	for item_id in rewards.get("items", []):
		reward_lines.append("- " + str(item_id))
	var reward_text := "\n".join(reward_lines) if reward_lines else "无"
	var dialog := AcceptDialog.new()
	dialog.dialog_text = title + "\n\n奖励:\n" + reward_text
	dialog.window_title = "节日奖励"
	dialog.ok_button_text = "确定"
	add_child(dialog)
	dialog.confirmed.connect(_on_dialog_confirmed.bind(dialog))
	dialog.popup_centered()

## 显示错误对话框
func _show_error_dialog(message: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.dialog_text = message
	dialog.window_title = "错误"
	dialog.ok_button_text = "确定"
	add_child(dialog)
	dialog.confirmed.connect(_on_dialog_confirmed.bind(dialog))
	dialog.popup_centered()

func _on_dialog_confirmed(dialog: AcceptDialog) -> void:
	dialog.queue_free()


## 关闭按钮点击
func _on_close_pressed() -> void:
	close()


## 商店按钮点击
func _on_shop_pressed() -> void:
	var vendors: Array = festival_data.get("vendors", [])
	if not vendors.is_empty():
		# 打开第一个商店
		var first_vendor: Dictionary = vendors[0]
		var shop_id: String = first_vendor.get("id", "")
		if not shop_id.is_empty() and EventBus:
			get_node("/root/EventBus").shop_opened.emit(shop_id)


## 处理输入
func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()