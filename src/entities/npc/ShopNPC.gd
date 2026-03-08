extends NPC
class_name ShopNPC

## ShopNPC - 商店NPC
## 继承NPC基类，添加商店功能

# 商店配置
@export var shop_id: String = "general_store"
@export var shop_greeting: String = "欢迎光临！需要买点什么？"
@export var shop_goodbye: String = "欢迎下次光临！"

# 节点引用
@onready var shop_indicator: Sprite2D = $ShopIndicator if has_node("ShopIndicator") else null

# 状态
var shop_ui_instance: ShopUI = null

func _ready() -> void:
	super._ready()
	_setup_shop()
	print("[ShopNPC] %s shop initialized with shop_id: %s" % [npc_name, shop_id])

func _setup_shop() -> void:
	# 验证商店ID是否有效
	if ShopSystem and shop_id != "":
		var shop = ShopSystem.get_shop(shop_id)
		if shop == null:
			push_warning("[ShopNPC] Shop '%s' not found for NPC %s" % [shop_id, npc_name])

## 开始交互（重写父类方法）
func start_interaction() -> void:
	super.start_interaction()

	# 面向玩家
	if GameManager and GameManager.player:
		face_position(GameManager.player.global_position)

	# 检查商店是否营业
	if ShopSystem:
		if not ShopSystem.is_shop_open(shop_id):
			_show_closed_message()
			return

	# 打开商店UI
	_open_shop_ui()

## 结束交互（重写父类方法）
func end_interaction() -> void:
	super.end_interaction()

	# 关闭商店UI
	if shop_ui_instance:
		shop_ui_instance.close()
		shop_ui_instance = null

## 显示商店关闭消息
func _show_closed_message() -> void:
	# 检查时间
	if TimeManager and ShopSystem:
		var shop = ShopSystem.get_shop(shop_id)
		if shop:
			var current_hour: int = TimeManager.get_current_hour()
			var message: String

			if current_hour < shop.opening_hour:
				message = "抱歉，我们还没开门呢。\n营业时间: %d:00 - %d:00" % [shop.opening_hour, shop.closing_hour]
			else:
				message = "抱歉，我们已经打烊了。\n营业时间: %d:00 - %d:00" % [shop.opening_hour, shop.closing_hour]

			# 显示消息（这里可以触发对话系统）
			if EventBus:
				EventBus.notification_shown.emit(message, 0)

	end_interaction()

## 打开商店UI
func _open_shop_ui() -> void:
	# 查找或创建商店UI
	var shop_ui = _get_or_create_shop_ui()

	if shop_ui:
		shop_ui.open(shop_id)
		shop_ui_instance = shop_ui

		# 发送事件
		if EventBus:
			EventBus.shop_opened.emit(shop_id)

## 获取或创建商店UI
func _get_or_create_shop_ui() -> ShopUI:
	# 尝试在场景树中查找现有的ShopUI
	var existing_ui = get_tree().get_first_node_in_group("shop_ui")
	if existing_ui and existing_ui is ShopUI:
		return existing_ui

	# 创建新的ShopUI实例
	var shop_ui_scene = preload("res://src/ui/menus/ShopUI.tscn")
	if shop_ui_scene:
		var shop_ui = shop_ui_scene.instantiate()
		get_tree().current_scene.add_child(shop_ui)
		shop_ui.add_to_group("shop_ui")
		return shop_ui

	return null

## 检查是否可以交互
func can_interact() -> bool:
	return interactable and shop_id != ""

## 获取商店信息
func get_shop_info() -> Dictionary:
	var info := {
		"npc_id": npc_id,
		"npc_name": npc_name,
		"shop_id": shop_id,
		"is_open": false
	}

	if ShopSystem:
		info["is_open"] = ShopSystem.is_shop_open(shop_id)

		var shop = ShopSystem.get_shop(shop_id)
		if shop:
			info["shop_name"] = shop.shop_name
			info["opening_hour"] = shop.opening_hour
			info["closing_hour"] = shop.closing_hour

	return info

## 保存状态
func save_state() -> Dictionary:
	var state = super.save_state()
	state["shop_id"] = shop_id
	return state