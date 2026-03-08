extends Node
class_name EventBus

## EventBus - 事件总线
## 全局事件系统，用于解耦各个模块之间的通信

# 游戏状态事件
signal game_started
signal game_paused
signal game_resumed
signal game_saved
signal game_loaded

# 时间事件
signal day_started
signal day_ended
signal hour_changed(hour: int)
signal season_changed(season: int, season_name: String)

# 玩家事件
signal player_moved(position: Vector2)
signal player_interacted(target: Node)
signal energy_changed(current: int, maximum: int)
signal money_changed(amount: int, delta: int)

# 农场事件
signal crop_planted(crop_type: String, position: Vector2)
signal crop_grew(crop_type: String, stage: int)
signal crop_harvested(crop_type: String, quality: int, quantity: int)
signal soil_watered(position: Vector2)
signal soil_dried(position: Vector2)

# 背包事件
signal item_added(item_id: String, quantity: int)
signal item_removed(item_id: String, quantity: int)
signal inventory_full

# 社交事件
signal npc_interacted(npc: Node)
signal dialogue_started(npc_id: String)
signal dialogue_ended(npc_id: String)
signal friendship_changed(npc_id: String, hearts: int)
signal gift_given(npc_id: String, item_id: String, reaction: int)

# NPC日程事件
signal npc_activity_changed(npc_id: String, activity: Dictionary)
signal npc_location_changed(npc_id: String, location_id: String)
signal npc_spawned(npc_id: String, npc: Node)

# 商店事件
signal shop_opened(shop_id: String)
signal shop_closed
signal item_bought(item_id: String, price: int)
signal item_sold(item_id: String, price: int)

# 市场价格事件
signal price_updated(item_id: String, new_price: int, base_price: int)
signal market_event_triggered(event_name: String, affected_items: Array)
signal prices_changed

# 出货箱事件
signal shipping_bin_opened
signal shipping_bin_closed
signal shipping_item_added(item_id: String, quantity: int)
signal shipping_item_removed(item_id: String, quantity: int)
signal shipment_processed(total_money: int, items_count: int)

# 制作事件
signal crafting_ui_opened(workbench_type: String)
signal crafting_ui_closed
signal recipe_unlocked(recipe_id: String)
signal item_crafted(recipe_id: String, result_item: String, quantity: int)
signal crafting_failed(recipe_id: String, reason: String)

# UI事件
signal ui_opened(ui_name: String)
signal ui_closed(ui_name: String)
signal notification_shown(message: String, type: int)

# 工具升级事件
signal tool_upgraded(tool_type: int, old_tier: int, new_tier: int)
signal upgrade_started(tool_type: int)
signal upgrade_failed(tool_type: int, reason: String)

# 任务事件
signal quest_accepted(quest_id: String)
signal quest_completed(quest_id: String)
signal quest_turned_in(quest_id: String, rewards: Dictionary)
signal quest_progress_updated(quest_id: String, objective_index: int, current: int, required: int)
signal quest_failed(quest_id: String, reason: String)

# 场景切换事件
signal scene_transition_started(target_scene: String)
signal scene_transition_completed
signal spawn_point_changed(spawn_point: String)

# 战斗事件
signal enemy_spawned(enemy: Node)
signal enemy_damaged(enemy: Node, damage: int)
signal enemy_died(enemy: Node, loot: Dictionary)
signal player_damaged(damage: int, source: Node)
signal player_attacked(weapon: String, damage: int)
signal health_changed(current: int, maximum: int)
signal combat_started
signal combat_ended

# 矿洞事件
signal mine_entered(floor: int)
signal mine_exited
signal mine_floor_changed(old_floor: int, new_floor: int)
signal ore_mined(ore_type: String, quantity: int, quality: int)
signal ore_depleted(ore_id: String)
signal ore_respawned(ore_id: String)
signal ladder_used(direction: int)  # -1: up, 1: down

# 烹饪事件
signal recipe_learned(recipe_id: String)
signal recipe_cooked(recipe_id: String, quantity: int)
signal cooking_started(recipe_id: String)
signal cooking_completed(recipe_id: String, result_item: String)
signal cooking_failed(recipe_id: String, reason: String)

# 节日事件
signal festival_started(festival_id: String, festival_data: Dictionary)
signal festival_ended(festival_id: String, festival_data: Dictionary)
signal festival_upcoming(festival_id: String, days_until: int)
signal festival_activity_completed(festival_id: String, activity_id: String, rewards: Dictionary)
signal festival_reward_claimed(festival_id: String, reward_id: String)
signal festival_notification(message: String, festival_id: String)

# 动物事件
signal animal_purchased(animal_type: String, animal_name: String, price: int)
signal animal_fed(animal_id: String, animal_name: String, food_item: String)
signal animal_product_ready(animal_id: String, product_id: String)
signal animal_product_collected(animal_id: String, product_id: String, quality: int)
signal animal_friendship_changed(animal_id: String, friendship: int, hearts: int)
signal animal_building_placed(building_type: String, building_name: String)
signal animal_building_upgraded(building_type: String, new_level: int)

# 钓鱼事件
signal fishing_started(location: String)
signal fishing_ended(success: bool, fish_id: String, fish_size: int)
signal fish_hooked(fish_id: String, fish_name: String)
signal fish_caught(fish_id: String, fish_size: int, quality: int)

func _ready() -> void:
	print("[EventBus] Initialized")

# 辅助函数：安全发射信号（带错误处理）
func emit(event_name: String, args: Array = []) -> void:
	if has_signal(event_name):
		emit_signal(event_name, args)
	else:
		push_warning("[EventBus] Signal not found: " + event_name)
