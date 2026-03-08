extends Area2D
class_name Kitchen

## Kitchen - 厨房烹饪台
## 玩家可以在此处进行烹饪

# 信号
signal cooking_station_activated

# 配置
@export var station_name: String = "厨房"
@export var auto_open: bool = true

# 节点引用
@onready var interaction_label: Label = $InteractionLabel if has_node("InteractionLabel") else null
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null

# 状态
var _player_in_range: bool = false
var _can_interact: bool = true

func _ready() -> void:
	_connect_signals()
	_setup_interaction_label()

func _connect_signals() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _setup_interaction_label() -> void:
	if interaction_label:
		interaction_label.visible = false
		interaction_label.text = "[E] 烹饪"
		interaction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_player_in_range = true
		if interaction_label:
			interaction_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		_player_in_range = false
		if interaction_label:
			interaction_label.visible = false

func _input(event: InputEvent) -> void:
	if not _player_in_range or not _can_interact:
		return

	if event.is_action_pressed("interact"):
		activate()
		get_viewport().set_input_as_handled()

## 激活烹饪台
func activate() -> void:
	cooking_station_activated.emit()

	if auto_open:
		open_cooking_ui()

## 打开烹饪界面
func open_cooking_ui() -> void:
	var cooking_ui = _get_or_create_cooking_ui()
	if cooking_ui:
		cooking_ui.open()

## 关闭烹饪界面
func close_cooking_ui() -> void:
	var cooking_ui = _get_cooking_ui()
	if cooking_ui:
		cooking_ui.close()

## 获取或创建烹饪界面
func _get_or_create_cooking_ui() -> CookingUI:
	var cooking_ui = _get_cooking_ui()
	if cooking_ui == null:
		cooking_ui = CookingUI.new()
		cooking_ui.name = "CookingUI"
		get_tree().root.add_child(cooking_ui)
	return cooking_ui

## 获取烹饪界面
func _get_cooking_ui() -> CookingUI:
	return get_tree().root.get_node_or_null("CookingUI") as CookingUI

## 设置是否可交互
func set_can_interact(value: bool) -> void:
	_can_interact = value
	if interaction_label:
		interaction_label.visible = _player_in_range and _can_interact