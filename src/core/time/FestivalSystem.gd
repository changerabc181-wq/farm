extends Node
class_name FestivalSystem

## FestivalSystem - 节日系统
## 管理游戏内节日、特殊活动、节日奖励

# 节日状态
enum FestivalState {
	INACTIVE,       # 未开始
	UPCOMING,       # 即将开始（前一天）
	ACTIVE,         # 进行中
	ENDED           # 已结束
}

# 信号
signal festival_started(festival_id: String, festival_data: Dictionary)
signal festival_ended(festival_id: String, festival_data: Dictionary)
signal festival_upcoming(festival_id: String, days_until: int)
signal festival_activity_completed(festival_id: String, activity_id: String, rewards: Dictionary)
signal festival_reward_claimed(festival_id: String, reward_id: String)

# 节日数据缓存
var _festivals_data: Dictionary = {}
var _active_festivals: Dictionary = {}
var _completed_activities: Dictionary = {}
var _claimed_rewards: Dictionary = {}

# 当前节日状态
var current_festival_state: FestivalState = FestivalState.INACTIVE
var current_active_festival: String = ""

# 节日通知时间（小时）
const FESTIVAL_ANNOUNCEMENT_HOUR: int = 8
const FESTIVAL_START_HOUR: int = 10
const FESTIVAL_END_HOUR: int = 22

# 配置
const DATA_PATH: String = "res://data/festivals.json"


func _ready() -> void:
	print("[FestivalSystem] Initialized")
	_load_festival_data()
	_connect_signals()


func _connect_signals() -> void:
	if TimeManager:
		TimeManager.day_changed.connect(_on_day_changed)
		TimeManager.hour_changed.connect(_on_hour_changed)
		TimeManager.season_changed.connect(_on_season_changed)


## 加载节日数据
func _load_festival_data() -> void:
	if not ResourceLoader.exists(DATA_PATH):
		push_warning("[FestivalSystem] Festival data file not found: " + DATA_PATH)
		return

	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("[FestivalSystem] Failed to open festival data file")
		return

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(json_text)
	if error != OK:
		push_error("[FestivalSystem] Failed to parse festival data: " + json.get_error_message())
		return

	var data := json.data as Dictionary
	for festival in data.get("festivals", []):
		var festival_id := festival.get("id", "")
		if not festival_id.is_empty():
			_festivals_data[festival_id] = festival

	print("[FestivalSystem] Loaded ", _festivals_data.size(), " festivals")


## 获取节日数据
func get_festival_data(festival_id: String) -> Dictionary:
	return _festivals_data.get(festival_id, {})


## 获取所有节日
func get_all_festivals() -> Dictionary:
	return _festivals_data.duplicate()


## 获取指定季节的节日
func get_festivals_by_season(season: int) -> Array:
	var result := []
	var season_names := ["spring", "summer", "fall", "winter"]
	var target_season := season_names[season]

	for festival_id in _festivals_data:
		var festival := _festivals_data[festival_id] as Dictionary
		if festival.get("season", "").to_lower() == target_season:
			result.append(festival)

	return result


## 检查今天是否有节日
func check_festival_today(season: int, day: int) -> Dictionary:
	var season_names := ["spring", "summer", "fall", "winter"]
	var target_season := season_names[season]

	for festival_id in _festivals_data:
		var festival := _festivals_data[festival_id] as Dictionary
		if festival.get("season", "").to_lower() == target_season:
			var festival_day := festival.get("day", 0)
			if festival_day == day:
				return {"found": true, "festival_id": festival_id, "festival_data": festival}

	return {"found": false}


## 检查明天是否有节日
func check_festival_tomorrow(season: int, day: int) -> Dictionary:
	var season_names := ["spring", "summer", "fall", "winter"]
	var target_season := season_names[season]
	var tomorrow_day := day + 1
	var check_season := season

	# 处理跨季情况
	if tomorrow_day > TimeManager.DAYS_PER_SEASON:
		tomorrow_day = 1
		check_season = (season + 1) % 4

	var check_season_name := season_names[check_season]

	for festival_id in _festivals_data:
		var festival := _festivals_data[festival_id] as Dictionary
		if festival.get("season", "").to_lower() == check_season_name:
			var festival_day := festival.get("day", 0)
			if festival_day == tomorrow_day:
				return {"found": true, "festival_id": festival_id, "festival_data": festival}

	return {"found": false}


## 开始节日
func start_festival(festival_id: String) -> void:
	if not _festivals_data.has(festival_id):
		push_warning("[FestivalSystem] Festival not found: " + festival_id)
		return

	var festival_data := _festivals_data[festival_id] as Dictionary
	_active_festivals[festival_id] = {
		"data": festival_data,
		"start_time": TimeManager.current_time,
		"activities_completed": [],
		"rewards_claimed": []
	}

	current_active_festival = festival_id
	current_festival_state = FestivalState.ACTIVE

	festival_started.emit(festival_id, festival_data)
	print("[FestivalSystem] Festival started: ", festival_data.get("name", festival_id))

	# 显示节日开始通知
	_show_festival_notification(festival_id, "started")


## 结束节日
func end_festival(festival_id: String) -> void:
	if not _active_festivals.has(festival_id):
		return

	var festival_info := _active_festivals[festival_id] as Dictionary
	var festival_data := festival_info.get("data", {}) as Dictionary

	# 保存完成的活动和奖励到历史记录
	_completed_activities[festival_id] = festival_info.get("activities_completed", [])
	_claimed_rewards[festival_id] = festival_info.get("rewards_claimed", [])

	_active_festivals.erase(festival_id)

	if current_active_festival == festival_id:
		current_active_festival = ""
		current_festival_state = FestivalState.INACTIVE

	festival_ended.emit(festival_id, festival_data)
	print("[FestivalSystem] Festival ended: ", festival_data.get("name", festival_id))

	# 显示节日结束通知
	_show_festival_notification(festival_id, "ended")


## 检查节日是否活跃
func is_festival_active(festival_id: String = "") -> bool:
	if festival_id.is_empty():
		return not _active_festivals.is_empty()
	return _active_festivals.has(festival_id)


## 获取当前活跃节日
func get_active_festival() -> String:
	return current_active_festival


## 获取当前活跃节日数据
func get_active_festival_data() -> Dictionary:
	if current_active_festival.is_empty():
		return {}
	return _festivals_data.get(current_active_festival, {})


## 完成节日活动
func complete_festival_activity(festival_id: String, activity_id: String) -> Dictionary:
	if not _active_festivals.has(festival_id):
		push_warning("[FestivalSystem] Festival not active: " + festival_id)
		return {"success": false, "message": "Festival not active"}

	var festival_info := _active_festivals[festival_id] as Dictionary
	var activities_completed: Array = festival_info.get("activities_completed", [])

	if activities_completed.has(activity_id):
		return {"success": false, "message": "Activity already completed"}

	# 获取活动数据
	var festival_data := festival_info.get("data", {}) as Dictionary
	var activity_data := _get_activity_data(festival_data, activity_id)

	if activity_data.is_empty():
		return {"success": false, "message": "Activity not found"}

	# 标记活动完成
	activities_completed.append(activity_id)
	festival_info["activities_completed"] = activities_completed

	# 发放奖励
	var rewards := activity_data.get("rewards", {}) as Dictionary
	_grant_rewards(rewards)

	festival_activity_completed.emit(festival_id, activity_id, rewards)
	print("[FestivalSystem] Activity completed: ", activity_id, " in festival: ", festival_id)

	return {
		"success": true,
		"message": "Activity completed!",
		"rewards": rewards
	}


## 获取活动数据
func _get_activity_data(festival_data: Dictionary, activity_id: String) -> Dictionary:
	var activities: Array = festival_data.get("activities", [])
	for activity in activities:
		if activity.get("id", "") == activity_id:
			return activity
	return {}


## 领取节日奖励
func claim_festival_reward(festival_id: String, reward_id: String) -> Dictionary:
	if not _active_festivals.has(festival_id):
		# 检查是否是已结束节日的奖励
		if _claimed_rewards.has(festival_id):
			var claimed: Array = _claimed_rewards[festival_id]
			if claimed.has(reward_id):
				return {"success": false, "message": "Reward already claimed"}
		else:
			return {"success": false, "message": "Festival not active"}

	var festival_info: Dictionary = _active_festivals.get(festival_id, {})
	if festival_info.is_empty():
		# 从历史记录中获取
		festival_info = {"data": _festivals_data.get(festival_id, {})}

	var rewards_claimed: Array = festival_info.get("rewards_claimed", [])
	if rewards_claimed.has(reward_id):
		return {"success": false, "message": "Reward already claimed"}

	# 获取奖励数据
	var festival_data := festival_info.get("data", {}) as Dictionary
	var reward_data := _get_reward_data(festival_data, reward_id)

	if reward_data.is_empty():
		return {"success": false, "message": "Reward not found"}

	# 检查领取条件
	var requirements := reward_data.get("requirements", {}) as Dictionary
	if not _check_reward_requirements(festival_id, requirements):
		return {"success": false, "message": "Requirements not met"}

	# 发放奖励
	var reward_items := reward_data.get("items", {}) as Dictionary
	_grant_rewards(reward_items)

	rewards_claimed.append(reward_id)
	festival_info["rewards_claimed"] = rewards_claimed

	festival_reward_claimed.emit(festival_id, reward_id)
	print("[FestivalSystem] Reward claimed: ", reward_id, " in festival: ", festival_id)

	return {
		"success": true,
		"message": "Reward claimed!",
		"items": reward_items
	}


## 获取奖励数据
func _get_reward_data(festival_data: Dictionary, reward_id: String) -> Dictionary:
	var rewards: Array = festival_data.get("rewards", [])
	for reward in rewards:
		if reward.get("id", "") == reward_id:
			return reward
	return {}


## 检查奖励领取条件
func _check_reward_requirements(festival_id: String, requirements: Dictionary) -> bool:
	# 检查活动完成数量
	var required_activities: int = requirements.get("activities_completed", 0)
	var completed_count := 0

	if _active_festivals.has(festival_id):
		var festival_info := _active_festivals[festival_id] as Dictionary
		var activities: Array = festival_info.get("activities_completed", [])
		completed_count = activities.size()
	elif _completed_activities.has(festival_id):
		var activities: Array = _completed_activities[festival_id]
		completed_count = activities.size()

	if completed_count < required_activities:
		return false

	return true


## 发放奖励
func _grant_rewards(rewards: Dictionary) -> void:
	# 发放金币
	var gold: int = rewards.get("gold", 0)
	if gold > 0:
		GameManager.money += gold
		EventBus.money_changed.emit(gold)

	# 发放物品
	var items: Dictionary = rewards.get("items", {})
	for item_id in items:
		var quantity: int = items[item_id]
		# 这里应该调用物品系统添加物品
		print("[FestivalSystem] Granting item: ", item_id, " x", quantity)

	# 发放体力
	var energy: int = rewards.get("energy", 0)
	if energy > 0:
		GameManager.current_stamina = min(GameManager.current_stamina + energy, GameManager.max_stamina)
		GameManager.stamina_changed.emit(GameManager.current_stamina, GameManager.max_stamina)


## 显示节日通知
func _show_festival_notification(festival_id: String, notification_type: String) -> void:
	var festival_data := _festivals_data.get(festival_id, {}) as Dictionary
	var festival_name := festival_data.get("name", festival_id)

	var message := ""
	match notification_type:
		"started":
			message = festival_name + " 开始了！"
		"ended":
			message = festival_name + " 结束了，感谢参与！"
		"upcoming":
			message = "明天是 " + festival_name + "！"

	if EventBus:
		EventBus.notification_shown.emit(message, 2)  # type 2 = festival notification


## 获取节日进度
func get_festival_progress(festival_id: String) -> Dictionary:
	var result := {
		"total_activities": 0,
		"completed_activities": 0,
		"available_rewards": 0,
		"claimed_rewards": 0
	}

	var festival_data := _festivals_data.get(festival_id, {}) as Dictionary
	if festival_data.is_empty():
		return result

	# 计算活动进度
	var activities: Array = festival_data.get("activities", [])
	result["total_activities"] = activities.size()

	if _active_festivals.has(festival_id):
		var festival_info := _active_festivals[festival_id] as Dictionary
		var completed: Array = festival_info.get("activities_completed", [])
		result["completed_activities"] = completed.size()

		var claimed: Array = festival_info.get("rewards_claimed", [])
		result["claimed_rewards"] = claimed.size()

	# 计算奖励进度
	var rewards: Array = festival_data.get("rewards", [])
	result["available_rewards"] = rewards.size()

	return result


## 获取可参与的活动列表
func get_available_activities(festival_id: String) -> Array:
	var result := []

	var festival_data := _festivals_data.get(festival_id, {}) as Dictionary
	if festival_data.is_empty():
		return result

	var activities: Array = festival_data.get("activities", [])
	var completed_activities: Array = []

	if _active_festivals.has(festival_id):
		var festival_info := _active_festivals[festival_id] as Dictionary
		completed_activities = festival_info.get("activities_completed", [])

	for activity in activities:
		var activity_id: String = activity.get("id", "")
		var is_completed := completed_activities.has(activity_id)
		result.append({
			"id": activity_id,
			"name": activity.get("name", ""),
			"description": activity.get("description", ""),
			"type": activity.get("type", ""),
			"completed": is_completed,
			"rewards": activity.get("rewards", {})
		})

	return result


## 信号回调：日期变化
func _on_day_changed(new_day: int) -> void:
	var season := TimeManager.current_season

	# 检查今天是否有节日
	var today_check := check_festival_today(season, new_day)
	if today_check.get("found", false):
		var festival_id: String = today_check.get("festival_id", "")
		current_festival_state = FestivalState.UPCOMING
		current_active_festival = festival_id

	# 检查明天是否有节日
	var tomorrow_check := check_festival_tomorrow(season, new_day)
	if tomorrow_check.get("found", false):
		var festival_id: String = tomorrow_check.get("festival_id", "")
		festival_upcoming.emit(festival_id, 1)
		_show_festival_notification(festival_id, "upcoming")


## 信号回调：小时变化
func _on_hour_changed(new_hour: int) -> void:
	# 在节日开始时间启动节日
	if new_hour == FESTIVAL_START_HOUR:
		if current_festival_state == FestivalState.UPCOMING and not current_active_festival.is_empty():
			start_festival(current_active_festival)

	# 在节日结束时间结束节日
	if new_hour == FESTIVAL_END_HOUR:
		if current_festival_state == FestivalState.ACTIVE and not current_active_festival.is_empty():
			end_festival(current_active_festival)


## 信号回调：季节变化
func _on_season_changed(new_season: int, season_name: String) -> void:
	# 清理上个季节的节日状态
	for festival_id in _active_festivals.keys():
		end_festival(festival_id)

	# 检查新季节第一天的节日
	var first_day_check := check_festival_today(new_season, 1)
	if first_day_check.get("found", false):
		var festival_id: String = first_day_check.get("festival_id", "")
		current_festival_state = FestivalState.UPCOMING
		current_active_festival = festival_id


## 存档数据
func save_state() -> Dictionary:
	return {
		"active_festivals": _active_festivals.duplicate(),
		"completed_activities": _completed_activities.duplicate(),
		"claimed_rewards": _claimed_rewards.duplicate(),
		"current_festival_state": current_festival_state,
		"current_active_festival": current_active_festival
	}


## 加载存档
func load_state(data: Dictionary) -> void:
	_active_festivals = data.get("active_festivals", {})
	_completed_activities = data.get("completed_activities", {})
	_claimed_rewards = data.get("claimed_rewards", {})
	current_festival_state = data.get("current_festival_state", FestivalState.INACTIVE)
	current_active_festival = data.get("current_active_festival", "")

	print("[FestivalSystem] State loaded, active festival: ", current_active_festival)