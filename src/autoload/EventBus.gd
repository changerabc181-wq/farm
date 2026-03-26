extends Node
class_name EventBus

## EventBus - 统一事件总线（兼容层）
## 
## 已拆分为领域子 EventBus：
## - EventBusGame     : 游戏状态
## - EventBusTime     : 时间系统
## - EventBusPlayer   : 玩家
## - EventBusFarm     : 农场
## - EventBusInventory: 背包
## - EventBusSocial   : 社交/NPC
## - EventBusShop     : 商店/经济
## - EventBusCraft    : 制作/加工
## - EventBusUI       : UI
## - EventBusQuest     : 任务
## - EventBusMine      : 矿洞
## - EventBusFestival  : 节日
## - EventBusAnimal    : 动物
## - EventBusFishing   : 钓鱼
## - EventBusCombat    : 战斗
## - EventBusShipping  : 出货
## - EventBusTool      : 工具升级

# 单例
static var instance: EventBus

# 子领域 EventBus
var game: EventBusGame
var time: EventBusTime
var player: EventBusPlayer
var farm: EventBusFarm
var inventory: EventBusInventory
var social: EventBusSocial
var shop: EventBusShop
var craft: EventBusCraft
var ui: EventBusUI
var quest: EventBusQuest
var mine: EventBusMine
var festival: EventBusFestival
var animal: EventBusAnimal
var fishing: EventBusFishing
var combat: EventBusCombat
var shipping: EventBusShipping
var tool: EventBusTool

func _ready() -> void:
	instance = self
	
	# 初始化所有子 EventBus
	game = EventBusGame.new()
	game.name = "EventBusGame"
	add_child(game)
	
	time = EventBusTime.new()
	time.name = "EventBusTime"
	add_child(time)
	
	player = EventBusPlayer.new()
	player.name = "EventBusPlayer"
	add_child(player)
	
	farm = EventBusFarm.new()
	farm.name = "EventBusFarm"
	add_child(farm)
	
	inventory = EventBusInventory.new()
	inventory.name = "EventBusInventory"
	add_child(inventory)
	
	social = EventBusSocial.new()
	social.name = "EventBusSocial"
	add_child(social)
	
	shop = EventBusShop.new()
	shop.name = "EventBusShop"
	add_child(shop)
	
	craft = EventBusCraft.new()
	craft.name = "EventBusCraft"
	add_child(craft)
	
	ui = EventBusUI.new()
	ui.name = "EventBusUI"
	add_child(ui)
	
	quest = EventBusQuest.new()
	quest.name = "EventBusQuest"
	add_child(quest)
	
	mine = EventBusMine.new()
	mine.name = "EventBusMine"
	add_child(mine)
	
	festival = EventBusFestival.new()
	festival.name = "EventBusFestival"
	add_child(festival)
	
	animal = EventBusAnimal.new()
	animal.name = "EventBusAnimal"
	add_child(animal)
	
	fishing = EventBusFishing.new()
	fishing.name = "EventBusFishing"
	add_child(fishing)
	
	combat = EventBusCombat.new()
	combat.name = "EventBusCombat"
	add_child(combat)
	
	shipping = EventBusShipping.new()
	shipping.name = "EventBusShipping"
	add_child(shipping)
	
	tool = EventBusTool.new()
	tool.name = "EventBusTool"
	add_child(tool)
	
	print("[EventBus] Initialized with 16 domain EventBus")

static func get_instance() -> EventBus:
	return instance

# ===== 向后兼容信号转发 =====
# 以下信号直接从对应子 EventBus 转发，保持向后兼容

# 游戏状态事件 (EventBusGame)
signal game_started:
	if instance and instance.game:
		instance.game.game_started.connect(game_started.emit)
signal game_paused:
	if instance and instance.game:
		instance.game.game_paused.connect(game_paused.emit)
signal game_resumed:
	if instance and instance.game:
		instance.game.game_resumed.connect(game_resumed.emit)
signal game_saved:
	if instance and instance.game:
		instance.game.game_saved.connect(game_saved.emit)
signal game_loaded:
	if instance and instance.game:
		instance.game.game_loaded.connect(game_loaded.emit)

# 时间事件 (EventBusTime)
signal day_started:
	if instance and instance.time:
		instance.time.day_started.connect(day_started.emit)
signal day_ended:
	if instance and instance.time:
		instance.time.day_ended.connect(day_ended.emit)
signal hour_changed(hour: int):
	if instance and instance.time:
		instance.time.hour_changed.connect(hour_changed.emit)
signal season_changed(season: int, season_name: String):
	if instance and instance.time:
		instance.time.season_changed.connect(season_changed.emit)

# 玩家事件 (EventBusPlayer)
signal player_moved(position: Vector2):
	if instance and instance.player:
		instance.player.player_moved.connect(player_moved.emit)
signal player_interacted(target: Node):
	if instance and instance.player:
		instance.player.player_interacted.connect(player_interacted.emit)
signal energy_changed(current: int, maximum: int):
	if instance and instance.player:
		instance.player.energy_changed.connect(energy_changed.emit)
signal health_changed(current: int, maximum: int):
	if instance and instance.player:
		instance.player.health_changed.connect(health_changed.emit)
signal combat_started:
	if instance and instance.player:
		instance.player.combat_started.connect(combat_started.emit)
signal combat_ended:
	if instance and instance.player:
		instance.player.combat_ended.connect(combat_ended.emit)

# 农场事件 (EventBusFarm)
signal crop_planted(crop_type: String, position: Vector2):
	if instance and instance.farm:
		instance.farm.crop_planted.connect(crop_planted.emit)
signal crop_grew(crop_type: String, stage: int):
	if instance and instance.farm:
		instance.farm.crop_grew.connect(crop_grew.emit)
signal crop_harvested(crop_type: String, quality: int, quantity: int):
	if instance and instance.farm:
		instance.farm.crop_harvested.connect(crop_harvested.emit)
signal soil_watered(position: Vector2):
	if instance and instance.farm:
		instance.farm.soil_watered.connect(soil_watered.emit)
signal soil_dried(position: Vector2):
	if instance and instance.farm:
		instance.farm.soil_dried.connect(soil_dried.emit)

# 背包事件 (EventBusInventory)
signal item_added(item_id: String, quantity: int):
	if instance and instance.inventory:
		instance.inventory.item_added.connect(item_added.emit)
signal item_removed(item_id: String, quantity: int):
	if instance and instance.inventory:
		instance.inventory.item_removed.connect(item_removed.emit)
signal inventory_full:
	if instance and instance.inventory:
		instance.inventory.inventory_full.connect(inventory_full.emit)

# 社交事件 (EventBusSocial)
signal npc_interacted(npc: Node):
	if instance and instance.social:
		instance.social.npc_interacted.connect(npc_interacted.emit)
signal dialogue_started(npc_id: String):
	if instance and instance.social:
		instance.social.dialogue_started.connect(dialogue_started.emit)
signal dialogue_ended(npc_id: String):
	if instance and instance.social:
		instance.social.dialogue_ended.connect(dialogue_ended.emit)
signal friendship_changed(npc_id: String, hearts: int):
	if instance and instance.social:
		instance.social.friendship_changed.connect(friendship_changed.emit)
signal gift_given(npc_id: String, item_id: String, reaction: int):
	if instance and instance.social:
		instance.social.gift_given.connect(gift_given.emit)
signal npc_activity_changed(npc_id: String, activity: Dictionary):
	if instance and instance.social:
		instance.social.npc_activity_changed.connect(npc_activity_changed.emit)
signal npc_location_changed(npc_id: String, location_id: String):
	if instance and instance.social:
		instance.social.npc_location_changed.connect(npc_location_changed.emit)
signal npc_spawned(npc_id: String, npc: Node):
	if instance and instance.social:
		instance.social.npc_spawned.connect(npc_spawned.emit)

# 商店事件 (EventBusShop)
signal shop_opened(shop_id: String):
	if instance and instance.shop:
		instance.shop.shop_opened.connect(shop_opened.emit)
signal shop_closed:
	if instance and instance.shop:
		instance.shop.shop_closed.connect(shop_closed.emit)
signal item_bought(item_id: String, price: int):
	if instance and instance.shop:
		instance.shop.item_bought.connect(item_bought.emit)
signal item_sold(item_id: String, price: int):
	if instance and instance.shop:
		instance.shop.item_sold.connect(item_sold.emit)
signal money_changed(amount: int, delta: int):
	if instance and instance.shop:
		instance.shop.money_changed.connect(money_changed.emit)
signal price_updated(item_id: String, new_price: int, base_price: int):
	if instance and instance.shop:
		instance.shop.price_updated.connect(price_updated.emit)

# 制作事件 (EventBusCraft)
signal crafting_ui_opened(workbench_type: String):
	if instance and instance.craft:
		instance.craft.crafting_ui_opened.connect(crafting_ui_opened.emit)
signal crafting_ui_closed:
	if instance and instance.craft:
		instance.craft.crafting_ui_closed.connect(crafting_ui_closed.emit)
signal recipe_unlocked(recipe_id: String):
	if instance and instance.craft:
		instance.craft.recipe_unlocked.connect(recipe_unlocked.emit)
signal item_crafted(recipe_id: String, result_item: String, quantity: int):
	if instance and instance.craft:
		instance.craft.item_crafted.connect(item_crafted.emit)
signal crafting_failed(recipe_id: String, reason: String):
	if instance and instance.craft:
		instance.craft.crafting_failed.connect(crafting_failed.emit)
signal recipe_learned(recipe_id: String):
	if instance and instance.craft:
		instance.craft.recipe_learned.connect(recipe_learned.emit)
signal recipe_cooked(recipe_id: String, quantity: int):
	if instance and instance.craft:
		instance.craft.recipe_cooked.connect(recipe_cooked.emit)
signal cooking_started(recipe_id: String):
	if instance and instance.craft:
		instance.craft.cooking_started.connect(cooking_started.emit)
signal cooking_completed(recipe_id: String, result_item: String):
	if instance and instance.craft:
		instance.craft.cooking_completed.connect(cooking_completed.emit)
signal cooking_failed(recipe_id: String, reason: String):
	if instance and instance.craft:
		instance.craft.cooking_failed.connect(cooking_failed.emit)

# UI事件 (EventBusUI)
signal ui_opened(ui_name: String):
	if instance and instance.ui:
		instance.ui.ui_opened.connect(ui_opened.emit)
signal ui_closed(ui_name: String):
	if instance and instance.ui:
		instance.ui.ui_closed.connect(ui_closed.emit)
signal notification_shown(message: String, type: int):
	if instance and instance.ui:
		instance.ui.notification_shown.connect(notification_shown.emit)

# 任务事件 (EventBusQuest)
signal quest_accepted(quest_id: String):
	if instance and instance.quest:
		instance.quest.quest_accepted.connect(quest_accepted.emit)
signal quest_completed(quest_id: String):
	if instance and instance.quest:
		instance.quest.quest_completed.connect(quest_completed.emit)
signal quest_turned_in(quest_id: String, rewards: Dictionary):
	if instance and instance.quest:
		instance.quest.quest_turned_in.connect(quest_turned_in.emit)
signal quest_progress_updated(quest_id: String, objective_index: int, current: int, required: int):
	if instance and instance.quest:
		instance.quest.quest_progress_updated.connect(quest_progress_updated.emit)
signal quest_failed(quest_id: String, reason: String):
	if instance and instance.quest:
		instance.quest.quest_failed.connect(quest_failed.emit)

# 矿洞事件 (EventBusMine)
signal mine_entered(floor: int):
	if instance and instance.mine:
		instance.mine.mine_entered.connect(mine_entered.emit)
signal mine_exited:
	if instance and instance.mine:
		instance.mine.mine_exited.connect(mine_exited.emit)
signal mine_floor_changed(old_floor: int, new_floor: int):
	if instance and instance.mine:
		instance.mine.mine_floor_changed.connect(mine_floor_changed.emit)
signal ore_mined(ore_type: String, quantity: int, quality: int):
	if instance and instance.mine:
		instance.mine.ore_mined.connect(ore_mined.emit)
signal ore_depleted(ore_id: String):
	if instance and instance.mine:
		instance.mine.ore_depleted.connect(ore_depleted.emit)
signal ore_respawned(ore_id: String):
	if instance and instance.mine:
		instance.mine.ore_respawned.connect(ore_respawned.emit)
signal ladder_used(direction: int):
	if instance and instance.mine:
		instance.mine.ladder_used.connect(ladder_used.emit)

# 节日事件 (EventBusFestival)
signal festival_started(festival_id: String, festival_data: Dictionary):
	if instance and instance.festival:
		instance.festival.festival_started.connect(festival_started.emit)
signal festival_ended(festival_id: String, festival_data: Dictionary):
	if instance and instance.festival:
		instance.festival.festival_ended.connect(festival_ended.emit)
signal festival_upcoming(festival_id: String, days_until: int):
	if instance and instance.festival:
		instance.festival.festival_upcoming.connect(festival_upcoming.emit)
signal festival_activity_completed(festival_id: String, activity_id: String, rewards: Dictionary):
	if instance and instance.festival:
		instance.festival.festival_activity_completed.connect(festival_activity_completed.emit)
signal festival_reward_claimed(festival_id: String, reward_id: String):
	if instance and instance.festival:
		instance.festival.festival_reward_claimed.connect(festival_reward_claimed.emit)
signal festival_notification(message: String, festival_id: String):
	if instance and instance.festival:
		instance.festival.festival_notification.connect(festival_notification.emit)

# 动物事件 (EventBusAnimal)
signal animal_purchased(animal_type: String, animal_name: String, price: int):
	if instance and instance.animal:
		instance.animal.animal_purchased.connect(animal_purchased.emit)
signal animal_fed(animal_id: String, animal_name: String, food_item: String):
	if instance and instance.animal:
		instance.animal.animal_fed.connect(animal_fed.emit)
signal animal_product_ready(animal_id: String, product_id: String):
	if instance and instance.animal:
		instance.animal.animal_product_ready.connect(animal_product_ready.emit)
signal animal_product_collected(animal_id: String, product_id: String, quality: int):
	if instance and instance.animal:
		instance.animal.animal_product_collected.connect(animal_product_collected.emit)
signal animal_friendship_changed(animal_id: String, friendship: int, hearts: int):
	if instance and instance.animal:
		instance.animal.animal_friendship_changed.connect(animal_friendship_changed.emit)
signal animal_building_placed(building_type: String, building_name: String):
	if instance and instance.animal:
		instance.animal.animal_building_placed.connect(animal_building_placed.emit)
signal animal_building_upgraded(building_type: String, new_level: int):
	if instance and instance.animal:
		instance.animal.animal_building_upgraded.connect(animal_building_upgraded.emit)

# 钓鱼事件 (EventBusFishing)
signal fishing_started(location: String):
	if instance and instance.fishing:
		instance.fishing.fishing_started.connect(fishing_started.emit)
signal fishing_ended(success: bool, fish_id: String, fish_size: int):
	if instance and instance.fishing:
		instance.fishing.fishing_ended.connect(fishing_ended.emit)
signal fish_hooked(fish_id: String, fish_name: String):
	if instance and instance.fishing:
		instance.fishing.fish_hooked.connect(fish_hooked.emit)
signal fish_caught(fish_id: String, fish_size: int, quality: int):
	if instance and instance.fishing:
		instance.fishing.fish_caught.connect(fish_caught.emit)

# 战斗事件 (EventBusCombat)
signal enemy_spawned(enemy: Node):
	if instance and instance.combat:
		instance.combat.enemy_spawned.connect(enemy_spawned.emit)
signal enemy_damaged(enemy: Node, damage: int):
	if instance and instance.combat:
		instance.combat.enemy_damaged.connect(enemy_damaged.emit)
signal enemy_died(enemy: Node, loot: Dictionary):
	if instance and instance.combat:
		instance.combat.enemy_died.connect(enemy_died.emit)
signal player_damaged(damage: int, source: Node):
	if instance and instance.combat:
		instance.combat.player_damaged.connect(player_damaged.emit)
signal player_attacked(weapon: String, damage: int):
	if instance and instance.combat:
		instance.combat.player_attacked.connect(player_attacked.emit)

# 出货事件 (EventBusShipping)
signal shipping_bin_opened:
	if instance and instance.shipping:
		instance.shipping.shipping_bin_opened.connect(shipping_bin_opened.emit)
signal shipping_bin_closed:
	if instance and instance.shipping:
		instance.shipping.shipping_bin_closed.connect(shipping_bin_closed.emit)
signal shipping_item_added(item_id: String, quantity: int):
	if instance and instance.shipping:
		instance.shipping.shipping_item_added.connect(shipping_item_added.emit)
signal shipping_item_removed(item_id: String, quantity: int):
	if instance and instance.shipping:
		instance.shipping.shipping_item_removed.connect(shipping_item_removed.emit)
signal shipment_processed(total_money: int, items_count: int):
	if instance and instance.shipping:
		instance.shipping.shipment_processed.connect(shipment_processed.emit)

# 工具升级事件 (EventBusTool)
signal tool_upgraded(tool_type: int, old_tier: int, new_tier: int):
	if instance and instance.tool:
		instance.tool.tool_upgraded.connect(tool_upgraded.emit)
signal upgrade_started(tool_type: int):
	if instance and instance.tool:
		instance.tool.upgrade_started.connect(upgrade_started.emit)
signal upgrade_failed(tool_type: int, reason: String):
	if instance and instance.tool:
		instance.tool.upgrade_failed.connect(upgrade_failed.emit)

# 场景切换事件 (保留在主 EventBus)
signal scene_transition_started(target_scene: String)
signal scene_transition_completed
signal spawn_point_changed(spawn_point: String)
