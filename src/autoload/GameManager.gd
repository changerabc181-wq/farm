extends Node

## GameManager - 游戏主管理器
## 负责游戏整体状态管理和协调各个系统

signal game_started
signal game_paused
signal game_resumed
signal game_saved
signal game_loaded
signal money_changed(amount: int)
signal stamina_changed(current: float, maximum: float)

# 游戏状态
enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	DIALOGUE,
	CUTSCENE
}

var current_state: GameState = GameState.MENU
var is_game_active: bool = false

# 玩家数据
var money: int = 500
var current_stamina: float = 100.0
var max_stamina: float = 100.0
var inventory: Array[Dictionary] = []
var player: Node2D = null

# 背包配置
const MAX_INVENTORY_SLOTS: int = 36

func _ready() -> void:
	print("[GameManager] Initialized")
	_connect_signals()

func _connect_signals() -> void:
	# 连接其他系统的信号
	var time_manager = get_node_or_null("/root/TimeManager")
	if time_manager and time_manager.has_signal("day_changed"):
		time_manager.day_changed.connect(_on_day_changed)

func start_game() -> void:
	current_state = GameState.PLAYING
	is_game_active = true
	game_started.emit()
	print("[GameManager] Game started")

func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true
		game_paused.emit()
		print("[GameManager] Game paused")

func resume_game() -> void:
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false
		game_resumed.emit()
		print("[GameManager] Game resumed")

func save_game(slot: int = 0) -> void:
	var save_manager = get_node_or_null("/root/SaveManager")
	if save_manager:
		save_manager.save_game(slot)
		game_saved.emit()
		print("[GameManager] Game saved to slot ", slot)

func load_game(slot: int = 0) -> void:
	var save_manager = get_node_or_null("/root/SaveManager")
	if save_manager:
		save_manager.load_game(slot)
		game_loaded.emit()
		print("[GameManager] Game loaded from slot ", slot)

func quit_game() -> void:
	print("[GameManager] Quitting game")
	get_tree().quit()

func _on_day_changed(new_day: int) -> void:
	print("[GameManager] Day changed to: ", new_day)

func get_current_state() -> GameState:
	return current_state

func is_paused() -> bool:
	return current_state == GameState.PAUSED

## 金钱管理
func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)
	print("[GameManager] Added %d money, total: %d" % [amount, money])

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		money_changed.emit(money)
		print("[GameManager] Spent %d money, remaining: %d" % [amount, money])
		return true
	return false

## 体力管理
func use_stamina(amount: float) -> bool:
	if current_stamina >= amount:
		current_stamina -= amount
		stamina_changed.emit(current_stamina, max_stamina)
		return true
	return false

func restore_stamina(amount: float) -> void:
	current_stamina = min(current_stamina + amount, max_stamina)
	stamina_changed.emit(current_stamina, max_stamina)

## 背包管理
func add_item(item_id: String, quantity: int = 1) -> bool:
	var event_bus = get_node_or_null("/root/EventBus")
	# 检查是否已有该物品
	for slot in inventory:
		if slot.get("item_id", "") == item_id:
			var new_quantity = slot.get("quantity", 0) + quantity
			slot["quantity"] = new_quantity
			if event_bus and event_bus.has_signal("item_added"):
				event_bus.item_added.emit(item_id, quantity)
			print("[GameManager] Added %dx %s to existing stack" % [quantity, item_id])
			return true

	# 检查是否有空槽
	if inventory.size() >= MAX_INVENTORY_SLOTS:
		if event_bus and event_bus.has_signal("inventory_full"):
			event_bus.inventory_full.emit()
		print("[GameManager] Inventory full, cannot add %s" % item_id)
		return false

	# 创建新槽位
	inventory.append({"item_id": item_id, "quantity": quantity})
	if event_bus and event_bus.has_signal("item_added"):
		event_bus.item_added.emit(item_id, quantity)
	print("[GameManager] Added %dx %s as new stack" % [quantity, item_id])
	return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
	var event_bus = get_node_or_null("/root/EventBus")
	for i in range(inventory.size()):
		var slot = inventory[i]
		if slot.get("item_id", "") == item_id:
			var current_quantity = slot.get("quantity", 0)
			if current_quantity > quantity:
				slot["quantity"] = current_quantity - quantity
				if event_bus and event_bus.has_signal("item_removed"):
					event_bus.item_removed.emit(item_id, quantity)
				print("[GameManager] Removed %dx %s" % [quantity, item_id])
				return true
			elif current_quantity == quantity:
				inventory.remove_at(i)
				if event_bus and event_bus.has_signal("item_removed"):
					event_bus.item_removed.emit(item_id, quantity)
				print("[GameManager] Removed all %s" % item_id)
				return true
			else:
				print("[GameManager] Not enough %s to remove" % item_id)
				return false

	print("[GameManager] Item %s not found in inventory" % item_id)
	return false

func has_item(item_id: String, quantity: int = 1) -> bool:
	for slot in inventory:
		if slot.get("item_id", "") == item_id:
			return slot.get("quantity", 0) >= quantity
	return false

func get_item_quantity(item_id: String) -> int:
	for slot in inventory:
		if slot.get("item_id", "") == item_id:
			return slot.get("quantity", 0)
	return 0

func get_inventory() -> Array[Dictionary]:
	return inventory

## 注册玩家引用
func register_player(player_node: Node2D) -> void:
	player = player_node
	print("[GameManager] Player registered")
