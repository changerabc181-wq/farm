extends CanvasLayer
class_name FestivalNotification

## FestivalNotification - 节日通知系统
## 显示节日开始、结束、即将到来的通知

# 通知场景
const NOTIFICATION_SCENE = preload("res://src/ui/festival/FestivalNotificationPopup.tscn")

# 通知队列
var _notification_queue: Array = []
var _is_showing: bool = false

# 通知显示时间（秒）
const NOTIFICATION_DURATION: float = 5.0

# 当前通知节点
var _current_notification: Control = null


func _ready() -> void:
	_connect_signals()
	print("[FestivalNotification] Initialized")


func _connect_signals() -> void:
	if EventBus:
		get_node("/root/EventBus").festival_started.connect(_on_festival_started)
		get_node("/root/EventBus").festival_ended.connect(_on_festival_ended)
		get_node("/root/EventBus").festival_upcoming.connect(_on_festival_upcoming)


## 显示节日通知
func show_notification(festival_id: String, notification_type: String, days_until: int = 0) -> void:
	var festival_data = FestivalSystem.get_festival_data(festival_id)

	if festival_data.is_empty():
		return

	var notification_data := {
		"festival_id": festival_id,
		"festival_name": festival_data.get("name", "未知节日"),
		"type": notification_type,
		"days_until": days_until,
		"icon": festival_data.get("icon", ""),
		"description": _get_notification_description(notification_type, days_until)
	}

	_notification_queue.append(notification_data)

	if not _is_showing:
		_show_next_notification()


## 获取通知描述
func _get_notification_description(notification_type: String, days_until: int) -> String:
	match notification_type:
		"started":
			return "节日已开始！快去参加活动吧！"
		"ended":
			return "节日已结束，感谢参与！"
		"upcoming":
			if days_until == 1:
				return "明天就是节日了，做好准备！"
			else:
				return "%d天后是节日！" % days_until
		_:
			return ""


## 显示下一个通知
func _show_next_notification() -> void:
	if _notification_queue.is_empty():
		_is_showing = false
		return

	_is_showing = true
	var notification_data: Dictionary = _notification_queue.pop_front()

	_create_notification_popup(notification_data)


## 创建通知弹窗
func _create_notification_popup(data: Dictionary) -> void:
	# 创建通知面板
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	panel.position = Vector2(0, 100)

	# 创建内容容器
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	# 标题
	var title := Label.new()
	title.text = data.get("festival_name", "")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# 描述
	var desc := Label.new()
	desc.text = data.get("description", "")
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc)

	# 添加到场景
	get_tree().current_scene.add_child(panel)
	_current_notification = panel

	# 设置自动关闭
	get_tree().create_timer(NOTIFICATION_DURATION).timeout.connect(
		func(): _close_notification(panel)
	)

	# 添加入场动画
	panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)


## 关闭通知
func _close_notification(panel: Control) -> void:
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		panel.queue_free()
		_show_next_notification()
	)


## 信号回调：节日开始
func _on_festival_started(festival_id: String, _data: Dictionary) -> void:
	show_notification(festival_id, "started")


## 信号回调：节日结束
func _on_festival_ended(festival_id: String, _data: Dictionary) -> void:
	show_notification(festival_id, "ended")


## 信号回调：节日即将到来
func _on_festival_upcoming(festival_id: String, days_until: int) -> void:
	show_notification(festival_id, "upcoming", days_until)