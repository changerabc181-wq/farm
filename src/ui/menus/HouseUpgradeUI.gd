extends Control
class_name HouseUpgradeUI

## HouseUpgradeUI - 房屋升级界面
## 显示当前房屋状态和升级选项

@onready var current_level_label: Label = $Panel/CurrentLevelLabel
@onready var description_label: Label = $Panel/DescriptionLabel
@onready var upgrade_cost_label: Label = $Panel/UpgradeCostLabel
@onready var upgrade_button: Button = $Panel/UpgradeButton
@onready var close_button: Button = $Panel/CloseButton
@onready var money_label: Label = $Panel/MoneyLabel
@onready var benefits_label: Label = $Panel/BenefitsLabel

func _ready() -> void:
	_setup_signals()
	_update_display()

func _setup_signals() -> void:
	if upgrade_button:
		upgrade_button.pressed.connect(_on_upgrade_pressed)
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

func _update_display() -> void:
	var house_system = get_node_or_null("/root/HouseUpgradeSystem")
	if not house_system:
		return
	
	# 显示当前房屋信息
	var config = house_system.get_current_config()
	var level_name = config.get("name", "未知")
	var description = config.get("description", "")
	
	if current_level_label:
		current_level_label.text = "当前房屋: " + level_name
	
	if description_label:
		description_label.text = description
	
	# 显示升级费用
	var can_upgrade = house_system.can_upgrade()
	if can_upgrade:
		var cost = house_system.get_upgrade_cost()
		if upgrade_cost_label:
			upgrade_cost_label.text = "升级费用: %dG" % cost
		if upgrade_button:
			upgrade_button.disabled = false
			upgrade_button.text = "升级房屋"
	else:
		if upgrade_cost_label:
			if house_system.get_current_level() == 3:
				upgrade_cost_label.text = "已达最高等级"
			else:
				var cost = house_system.get_upgrade_cost()
				upgrade_cost_label.text = "升级费用: %dG (金钱不足)" % cost
		if upgrade_button:
			upgrade_button.disabled = true
			upgrade_button.text = "无法升级"
	
	# 显示当前金钱
	var money_system = get_node_or_null("/root/MoneySystem")
	if money_label and money_system:
		money_label.text = "持有金钱: %dG" % money_system.get_money()
	
	# 显示房屋属性
	if benefits_label:
		var text = "房间数: %d\n" % config.get("room_count", 0)
		text += "家具槽位: %d\n" % config.get("furniture_slots", 0)
		text += "储物空间: %d\n" % config.get("storage_slots", 0)
		text += "厨房: %s\n" % ("有" if config.get("kitchen_available", false) else "无")
		text += "卧室: %d间" % config.get("bedroom_count", 0)
		benefits_label.text = text

func _on_upgrade_pressed() -> void:
	var house_system = get_node_or_null("/root/HouseUpgradeSystem")
	if house_system and house_system.upgrade_house():
		_update_display()
		_show_message("房屋升级成功！")
	else:
		_show_message("升级失败，请检查条件")

func _on_close_pressed() -> void:
	hide()

func _show_message(text: String) -> void:
	print("[HouseUpgradeUI] ", text)
	# TODO: 显示实际的消息UI

func open() -> void:
	show()
	_update_display()