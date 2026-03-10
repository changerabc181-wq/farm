extends Node

## FestivalSystem - 节日系统
## 管理游戏中的季节性节日活动

# 节日类型
enum FestivalType {
	SPRING_FLOWER,   # 春花祭
	SUMMER_NIGHT,    # 夏夜祭
	FALL_HARVEST,    # 丰收祭
	WINTER_SNOW      # 冬雪祭
}

# 节日配置
const FESTIVALS = {
	FestivalType.SPRING_FLOWER: {
		"id": "spring_flower",
		"name": "春花祭",
		"description": "春天的花之庆典，展示最美的花朵",
		"season": "Spring",
		"day": 14,
		"start_hour": 9,
		"end_hour": 18,
		"location": "village",
		"rewards": {
			"participation": {"money": 500, "items": {"flower_seed": 5}},
			"winner": {"money": 2000, "items": {"golden_flower": 1}},
		},
		"mini_game": "flower_arrangement",
		"npc_participants": ["mayor", "farmer", "shopkeeper"]
	},
	FestivalType.SUMMER_NIGHT: {
		"id": "summer_night",
		"name": "夏夜祭",
		"description": "夏日夜晚的烟火大会",
		"season": "Summer",
		"day": 21,
		"start_hour": 18,
		"end_hour": 24,
		"location": "beach",
		"rewards": {
			"participation": {"money": 300, "items": {"firework": 3}},
			"winner": {"money": 1500, "items": {"golden_firework": 1}},
		},
		"mini_game": "firework_show",
		"npc_participants": ["blacksmith", "doctor"]
	},
	FestivalType.FALL_HARVEST: {
		"id": "fall_harvest",
		"name": "丰收祭",
		"description": "秋季的丰收庆典，展示最佳作物",
		"season": "Fall",
		"day": 16,
		"start_hour": 10,
		"end_hour": 20,
		"location": "village",
		"rewards": {
			"participation": {"money": 800, "items": {"quality_fertilizer": 10}},
			"winner": {"money": 5000, "items": {"golden_scythe": 1}},
		},
		"mini_game": "crop_show",
		"npc_participants": ["mayor", "farmer", "shopkeeper", "blacksmith"]
	},
	FestivalType.WINTER_SNOW: {
		"id": "winter_snow",
		"name": "冬雪祭",
		"description": "冬季的冰雪嘉年华",
		"season": "Winter",
		"day": 25,
		"start_hour": 12,
		"end_hour": 22,
		"location": "village",
		"rewards": {
			"participation": {"money": 400, "items": {"hot_cocoa": 5}},
			"winner": {"money": 3000, "items": {"winter_star": 1}},
		},
		"mini_game": "ice_sculpture",
		"npc_participants": ["doctor", "shopkeeper"]
	}
}

# 信号
signal festival_started(festival_type: int, festival_data: Dictionary)
signal festival_ended(festival_type: int)
signal festival_reward_given(rewards: Dictionary)

# 当前节日状态
var current_festival: int = -1
var is_festival_active: bool = false
var festival_participation: Dictionary = {}
var festival_scores: Dictionary = {}

func _ready() -> void:
	print("[FestivalSystem] Initialized")
	_connect_time_signals()

func _connect_time_signals() -> void:
	var time_manager = get_node_or_null("/root/TimeManager")
	if time_manager:
		time_manager.hour_changed.connect(_on_hour_changed)
		time_manager.day_changed.connect(_on_day_changed)

## 检查当前是否有节日
func check_current_festival() -> int:
	var time_manager = get_node_or_null("/root/TimeManager")
	if not time_manager:
		return -1
	
	var current_season = time_manager.get_season_name()
	var current_day = time_manager.current_day
	var current_hour = int(time_manager.current_time)
	
	for festival_type in FESTIVALS.keys():
		var festival = FESTIVALS[festival_type]
		if festival.season == current_season and festival.day == current_day:
			if current_hour >= festival.start_hour and current_hour < festival.end_hour:
				return festival_type
	
	return -1

## 小时变化回调
func _on_hour_changed(new_hour: int) -> void:
	if is_festival_active:
		# 检查节日是否结束
		if current_festival >= 0:
			var festival = FESTIVALS[current_festival]
			if new_hour >= festival.end_hour:
				end_festival()
	else:
		# 检查是否有节日开始
		var festival_type = check_current_festival()
		if festival_type >= 0:
			start_festival(festival_type)

## 天数变化回调
func _on_day_changed(new_day: int) -> void:
	# 重置节日参与状态
	festival_participation.clear()
	festival_scores.clear()

## 开始节日
func start_festival(festival_type: int) -> void:
	if is_festival_active:
		return
	
	current_festival = festival_type
	is_festival_active = true
	
	var festival = FESTIVALS[festival_type]
	festival_started.emit(festival_type, festival)
	
	print("[FestivalSystem] 节日开始: ", festival.name)
	
	# 通知玩家
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus:
		event_bus.notification_shown.emit(festival.name + " 开始了！", 2)

## 结束节日
func end_festival() -> void:
	if not is_festival_active:
		return
	
	var festival = FESTIVALS[current_festival]
	
	# 发放参与奖励
	_give_participation_rewards()
	
	# 确定获胜者
	_determine_winner()
	
	is_festival_active = false
	festival_ended.emit(current_festival)
	
	print("[FestivalSystem] 节日结束: ", festival.name)
	
	current_festival = -1

## 参与节日
func participate_in_festival() -> void:
	if not is_festival_active:
		return
	
	var player_id = "player"
	festival_participation[player_id] = true
	print("[FestivalSystem] 玩家参与节日")

## 增加节日分数
func add_festival_score(score: int) -> void:
	if not is_festival_active:
		return
	
	var player_id = "player"
	if not festival_scores.has(player_id):
		festival_scores[player_id] = 0
	festival_scores[player_id] += score
	print("[FestivalSystem] 节日分数 +", score, " 总分: ", festival_scores[player_id])

## 获取玩家节日分数
func get_player_festival_score() -> int:
	return festival_scores.get("player", 0)

## 发放参与奖励
func _give_participation_rewards() -> void:
	if current_festival < 0:
		return
	
	var festival = FESTIVALS[current_festival]
	var rewards = festival.rewards.get("participation", {})
	
	_give_rewards(rewards)

## 确定获胜者
func _determine_winner() -> void:
	if current_festival < 0:
		return
	
	var festival = FESTIVALS[current_festival]
	var winner = "player"
	var max_score = 0
	
	for participant in festival_scores.keys():
		if festival_scores[participant] > max_score:
			max_score = festival_scores[participant]
			winner = participant
	
	if winner == "player" and max_score > 0:
		var rewards = festival.rewards.get("winner", {})
		_give_rewards(rewards)
		print("[FestivalSystem] 玩家获得节日冠军！")

## 发放奖励
func _give_rewards(rewards: Dictionary) -> void:
	var money_system = get_node_or_null("/root/MoneySystem")
	var inventory = get_node_or_null("/root/Inventory")
	
	if rewards.has("money") and money_system:
		money_system.add_money(rewards.money)
		print("[FestivalSystem] 获得金钱: ", rewards.money)
	
	if rewards.has("items") and inventory:
		for item_id in rewards.items.keys():
			var quantity = rewards.items[item_id]
			inventory.add_item(item_id, quantity)
			print("[FestivalSystem] 获得物品: ", item_id, " x", quantity)
	
	festival_reward_given.emit(rewards)

## 获取当前节日名称
func get_current_festival_name() -> String:
	if current_festival < 0:
		return ""
	return FESTIVALS[current_festival].name

## 获取当前节日描述
func get_current_festival_description() -> String:
	if current_festival < 0:
		return ""
	return FESTIVALS[current_festival].description

## 检查是否在节日中
func is_in_festival() -> bool:
	return is_festival_active

## 获取下一个节日
func get_next_festival() -> Dictionary:
	var time_manager = get_node_or_null("/root/TimeManager")
	if not time_manager:
		return {}
	
	var current_season = time_manager.get_season_name()
	var current_day = time_manager.current_day
	
	# 检查当前季节的节日
	for festival_type in FESTIVALS.keys():
		var festival = FESTIVALS[festival_type]
		if festival.season == current_season and festival.day > current_day:
			return {"type": festival_type, "data": festival}
	
	# 如果当前季节没有节日，返回下一个季节的第一个节日
	return {}

## 获取所有节日
func get_all_festivals() -> Dictionary:
	return FESTIVALS.duplicate()

## 保存状态
func save_state() -> Dictionary:
	return {
		"current_festival": current_festival,
		"is_festival_active": is_festival_active,
		"festival_participation": festival_participation.duplicate(),
		"festival_scores": festival_scores.duplicate()
	}

## 加载状态
func load_state(data: Dictionary) -> void:
	if data.has("current_festival"):
		current_festival = data.current_festival
	if data.has("is_festival_active"):
		is_festival_active = data.is_festival_active
	if data.has("festival_participation"):
		festival_participation = data.festival_participation.duplicate()
	if data.has("festival_scores"):
		festival_scores = data.festival_scores.duplicate()
	
	print("[FestivalSystem] State loaded")