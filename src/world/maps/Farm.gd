extends Node2D
class_name Farm

## Farm - 农场场景
## 游戏主场景，玩家农场所在地

const TimeDisplayScene = preload("res://src/ui/hud/TimeDisplay.tscn")
const ToolDisplayScene = preload("res://src/ui/hud/ToolDisplay.tscn")
const HoeScene = preload("res://src/entities/tools/Hoe.tscn")
const FARM_LAYOUT_PATH := "res://data/farm_layout.json"
const LAYOUT_SCENES := {
	"shipping_bin": preload("res://src/world/objects/ShippingBin.tscn"),
	"workbench": preload("res://src/world/objects/Workbench.tscn"),
	"fishing_spot": preload("res://src/world/objects/FishingSpot.tscn"),
	"coop": preload("res://src/world/objects/Coop.tscn"),
	"barn": preload("res://src/world/objects/Barn.tscn"),
	"ore": preload("res://src/world/objects/Ore.tscn")
}

@onready var tile_map: TileMap = $TileMap
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var tilled_area: Node2D = $TilledArea

var time_display: Control
var ui_canvas: CanvasLayer
var hoe_tool: Hoe
var soil_plots: Array[Soil] = []
var planting_manager: PlantingManager = null
var layout_root: Node2D

func _ready() -> void:
	print("[Farm] Scene loaded")
	_setup_tilemap()
	_setup_layout_root()
	_apply_layout_from_file()
	_setup_ui()
	_setup_tools()
	_setup_soil_plots()
	_setup_planting_manager()
	_connect_time_signals()
	_connect_event_signals()
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		game_manager.start_game()

func _setup_tilemap() -> void:
	# 设置TileSet（如果没有的话）
	if tile_map.tile_set == null:
		var tile_set: TileSet = TileSet.new()
		tile_map.tile_set = tile_set

	print("[Farm] TileMap setup complete")

func _setup_layout_root() -> void:
	layout_root = get_node_or_null("LayoutRoot")
	if layout_root == null:
		layout_root = Node2D.new()
		layout_root.name = "LayoutRoot"
		add_child(layout_root)

func _apply_layout_from_file() -> void:
	if layout_root == null:
		return
	for child in layout_root.get_children():
		child.queue_free()

	var file := FileAccess.open(FARM_LAYOUT_PATH, FileAccess.READ)
	if file == null:
		print("[Farm] No farm layout file found, using empty layout")
		return

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_warning("[Farm] Failed to parse farm_layout.json")
		return

	var data: Dictionary = json.data
	for object_data in data.get("objects", []):
		var node := _build_layout_node(object_data)
		if node:
			layout_root.add_child(node)
	print("[Farm] Loaded layout objects: ", layout_root.get_child_count())

func _build_layout_node(object_data: Dictionary) -> Node2D:
	var kind := object_data.get("kind", "")
	if kind == "rect":
		return _build_rect_node(object_data)
	if kind == "scene":
		return _build_scene_node(object_data)
	return null

func _build_rect_node(object_data: Dictionary) -> Node2D:
	var node := Node2D.new()
	node.name = object_data.get("name", "RectObject")
	var size_dict: Dictionary = object_data.get("size", {})
	var color_dict: Dictionary = object_data.get("color", {})
	var rect := ColorRect.new()
	rect.size = Vector2(size_dict.get("x", 32.0), size_dict.get("y", 32.0))
	rect.position = -rect.size / 2.0
	rect.color = Color(
		color_dict.get("r", 1.0),
		color_dict.get("g", 1.0),
		color_dict.get("b", 1.0),
		color_dict.get("a", 1.0)
	)
	node.add_child(rect)
	var pos_dict: Dictionary = object_data.get("position", {})
	node.position = Vector2(pos_dict.get("x", 0.0), pos_dict.get("y", 0.0))
	return node

func _build_scene_node(object_data: Dictionary) -> Node2D:
	var scene_key: String = object_data.get("scene_key", "")
	var packed: PackedScene = LAYOUT_SCENES.get(scene_key)
	if packed == null:
		push_warning("[Farm] Unknown scene key: " + scene_key)
		return null
	var node := packed.instantiate()
	node.name = object_data.get("name", scene_key)
	var pos_dict: Dictionary = object_data.get("position", {})
	node.position = Vector2(pos_dict.get("x", 0.0), pos_dict.get("y", 0.0))
	var properties: Dictionary = object_data.get("properties", {})
	for key in properties.keys():
		node.set(key, properties[key])
	return node

func _setup_ui() -> void:
	# 创建UI画布层
	ui_canvas = CanvasLayer.new()
	ui_canvas.layer = 10  # UI层
	add_child(ui_canvas)

	# 添加时间显示
	time_display = TimeDisplayScene.instantiate()
	ui_canvas.add_child(time_display)
	print("[Farm] TimeDisplay added to UI canvas")
	
	# 添加工具显示
	var tool_display = ToolDisplayScene.instantiate()
	ui_canvas.add_child(tool_display)
	print("[Farm] ToolDisplay added to UI canvas")

func _setup_tools() -> void:
	# 创建锄头工具实例
	hoe_tool = HoeScene.instantiate()
	add_child(hoe_tool)
	print("[Farm] Hoe tool initialized")

func _setup_soil_plots() -> void:
	# 收集所有土壤地块
	if tilled_area:
		for child in tilled_area.get_children():
			if child is Soil:
				soil_plots.append(child)
		print("[Farm] Found ", soil_plots.size(), " soil plots")

func _setup_planting_manager() -> void:
	var PlantingManagerScript = load("res://src/core/farming/PlantingManager.gd")
	planting_manager = PlantingManagerScript.new()
	planting_manager.name = "PlantingManager"
	add_child(planting_manager)
	print("[Farm] Planting manager initialized")

func _connect_time_signals() -> void:
	var time_manager = get_node_or_null("/root/TimeManager")
	if time_manager:
		time_manager.hour_changed.connect(_on_hour_changed)
		time_manager.day_changed.connect(_on_day_changed)
		time_manager.season_changed.connect(_on_season_changed)
		print("[Farm] Connected to TimeManager signals")

func _connect_event_signals() -> void:
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus:
		# 连接交互信号
		event_bus.player_interacted.connect(_on_player_interacted)
		# 连接收获信号
		event_bus.crop_harvested.connect(_on_crop_harvested)
		print("[Farm] Connected to EventBus signals")

func _on_hour_changed(new_hour: int) -> void:
	print("[Farm] Hour changed to: ", new_hour)

func _on_day_changed(new_day: int) -> void:
	print("[Farm] Day changed to: ", new_day)
	# 新的一天开始，干燥所有土壤
	_dry_all_soil()

func _on_season_changed(new_season: int, season_name: String) -> void:
	print("[Farm] Season changed to: ", season_name)

func _on_player_interacted(target: Node) -> void:
	# 处理玩家与土壤的交互
	if target is Soil:
		var soil := target as Soil
		
		# 如果土壤未耕地，使用锄头
		if soil.can_till():
			if hoe_tool:
				hoe_tool.use(soil)
		return
	
	# 其他交互由各自的系统处理


func _on_crop_harvested(crop_type: String, quality: int, quantity: int) -> void:
	# 收获作物后自动出售获得金钱
	# 获取作物的基础价格（从配置中获取或使用默认值）
	var base_price: int = _get_crop_base_price(crop_type)

	var money_system = get_node_or_null("/root/MoneySystem")
	if base_price > 0 and money_system:
		var total_earned: int = money_system.sell_crop(
			crop_type,
			crop_type.capitalize(),
			quality,
			base_price,
			quantity
		)
		print("[Farm] Earned $", total_earned, " from selling ", quantity, " ", crop_type)


func _get_crop_base_price(crop_id: String) -> int:
	# 临时价格表（实际应该从配置文件加载）
	var crop_prices: Dictionary = {
		"parsnip": 35,
		"potato": 80,
		"cauliflower": 175,
		"bean": 40,
		"tomato": 60,
		"corn": 50,
		"melon": 250,
		"wheat": 25,
		"strawberry": 120,
		"pumpkin": 320,
		"eggplant": 60,
		"carrot": 35,
		"radish": 35,
		"blueberry": 50
	}

	return crop_prices.get(crop_id.to_lower(), 25)  # 默认价格25

func _dry_all_soil() -> void:
	for soil in soil_plots:
		soil.dry()
	print("[Farm] All soil plots dried for new day")

func get_player_spawn_position() -> Vector2:
	return player_spawn.global_position

## 获取指定位置的土壤地块
func get_soil_at_position(pos: Vector2) -> Soil:
	for soil in soil_plots:
		if soil.global_position.distance_to(pos) < 16.0:
			return soil
	return null

## 获取所有可种植的土壤
func get_plantable_soils() -> Array[Soil]:
	var result: Array[Soil] = []
	for soil in soil_plots:
		if soil.can_plant():
			result.append(soil)
	return result
