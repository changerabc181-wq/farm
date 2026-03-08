extends Area2D
class_name FishingSpot

## FishingSpot - 钓鱼点
## 玩家可以在此使用鱼竿钓鱼

# 信号
signal fishing_started(spot: FishingSpot)
signal fishing_ended(spot: FishingSpot, success: bool, fish_id: String)
signal interaction_available(spot: FishingSpot)
signal interaction_unavailable(spot: FishingSpot)

# 配置
@export var spot_name: String = "钓鱼点"
@export var fishing_location: String = "lake"  # lake, river, beach, pond
@export var interaction_radius: float = 40.0

# 状态
var is_player_nearby: bool = false
var is_fishing: bool = false

# 节点引用
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var interaction_area: CollisionShape2D = $InteractionArea if has_node("InteractionArea") else null
@onready var hint_label: Label = $HintLabel if has_node("HintLabel") else null

# 鱼竿引用
var fishing_rod: FishingRod = null

func _ready() -> void:
	_setup_interaction()
	_setup_hint()
	print("[FishingSpot] Initialized: ", spot_name)

func _setup_interaction() -> void:
	# 创建交互区域
	if not interaction_area:
		interaction_area = CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = interaction_radius
		interaction_area.shape = shape
		add_child(interaction_area)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _setup_hint() -> void:
	if hint_label:
		hint_label.text = "[按E键钓鱼]"
		hint_label.visible = false

func _input(event: InputEvent) -> void:
	if not is_player_nearby or is_fishing:
		return

	# 检测交互输入
	if event.is_action_pressed("ui_interact") or event.is_action_pressed("ui_accept"):
		_start_fishing()
		get_viewport().set_input_as_handled()

## 玩家进入范围
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		is_player_nearby = true
		interaction_available.emit(self)

		if hint_label:
			hint_label.visible = true

		print("[FishingSpot] Player entered: ", spot_name)

## 玩家离开范围
func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		is_player_nearby = false
		interaction_unavailable.emit(self)

		if hint_label:
			hint_label.visible = false

		# 如果正在钓鱼，取消钓鱼
		if is_fishing and fishing_rod:
			fishing_rod.cancel_fishing()

		print("[FishingSpot] Player exited: ", spot_name)

## 开始钓鱼
func _start_fishing() -> void:
	if is_fishing:
		return

	# 创建或获取鱼竿
	fishing_rod = _get_or_create_fishing_rod()
	if not fishing_rod:
		push_error("[FishingSpot] Failed to get fishing rod")
		return

	# 连接信号
	fishing_rod.fishing_started.connect(_on_fishing_started)
	fishing_rod.fishing_ended.connect(_on_fishing_ended)
	fishing_rod.energy_consumed.connect(_on_energy_consumed)

	# 开始钓鱼
	is_fishing = true
	var success := fishing_rod.use(global_position, fishing_location)

	if not success:
		is_fishing = false
		_cleanup_fishing_rod()

## 获取或创建鱼竿
func _get_or_create_fishing_rod() -> FishingRod:
	# TODO: 从玩家背包获取鱼竿
	# 暂时创建一个新的
	var rod := FishingRod.new()
	get_tree().current_scene.add_child(rod)
	return rod

## 钓鱼开始回调
func _on_fishing_started() -> void:
	fishing_started.emit(self)

	# 隐藏提示
	if hint_label:
		hint_label.visible = false

## 钓鱼结束回调
func _on_fishing_ended(success: bool, fish_id: String, _size: int) -> void:
	is_fishing = false
	fishing_ended.emit(self, success, fish_id)

	_cleanup_fishing_rod()

	# 重新显示提示
	if is_player_nearby and hint_label:
		hint_label.visible = true

## 体力消耗回调
func _on_energy_consumed(amount: int) -> void:
	EventBus.energy_changed.emit(-amount, 0)

## 清理鱼竿
func _cleanup_fishing_rod() -> void:
	if fishing_rod:
		fishing_rod.fishing_started.disconnect(_on_fishing_started)
		fishing_rod.fishing_ended.disconnect(_on_fishing_ended)
		fishing_rod.energy_consumed.disconnect(_on_energy_consumed)
		fishing_rod.queue_free()
		fishing_rod = null

## 获取钓鱼点信息
func get_spot_info() -> Dictionary:
	return {
		"name": spot_name,
		"location_type": fishing_location,
		"can_fish": is_player_nearby and not is_fishing
	}