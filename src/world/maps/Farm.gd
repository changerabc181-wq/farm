extends Node2D
class_name Farm

## Farm - 农场场景
## 游戏主场景，玩家农场所在地

const TimeDisplayScene = preload("res://src/ui/hud/TimeDisplay.tscn")
const ToolDisplayScene = preload("res://src/ui/hud/ToolDisplay.tscn")
const HoeScene = preload("res://src/entities/tools/Hoe.tscn")

@onready var tile_map: TileMap = $TileMap
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var tilled_area: Node2D = $TilledArea

var time_display: Control
var ui_canvas: CanvasLayer
var hoe_tool: Hoe
var soil_plots: Array[Soil] = []
var planting_manager: PlantingManager = null

func _ready() -> void:
	print("[Farm] Scene loaded")
	_setup_tilemap()
	_setup_ui()
	_setup_tools()
	_setup_soil_plots()
	_setup_planting_manager()
	_connect_time_signals()
	_connect_event_signals()
	GameManager.start_game()

func _setup_tilemap() -> void:
	# 设置TileSet（如果没有的话）
	if tile_map.tile_set == null:
		var tile_set: TileSet = TileSet.new()
		tile_map.tile_set = tile_set

	print("[Farm] TileMap setup complete")

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
	planting_manager = PlantingManager.new()
	planting_manager.name = "PlantingManager"
	add_child(planting_manager)
	print("[Farm] Planting manager initialized")

func _connect_time_signals() -> void:
	if TimeManager:
		get_node("/root/TimeManager").hour_changed.connect(_on_hour_changed)
		TimeManager.day_changed.connect(_on_day_changed)
		TimeManager.season_changed.connect(_on_season_changed)
		print("[Farm] Connected to TimeManager signals")

func _connect_event_signals() -> void:
	# 连接交互信号
	get_node("/root/EventBus").player_interacted.connect(_on_player_interacted)
	# 连接收获信号
	get_node("/root/EventBus").crop_harvested.connect(_on_crop_harvested)
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
	
	# 尝试种植（通过事件系统）
	get_node("/root/EventBus").player_interacted.emit(target)


func _on_crop_harvested(crop_type: String, quality: int, quantity: int) -> void:
	# 收获作物后自动出售获得金钱
	# 获取作物的基础价格（从配置中获取或使用默认值）
	var base_price: int = _get_crop_base_price(crop_type)

	if base_price > 0 and MoneySystem:
		var total_earned: int = MoneySystem.sell_crop(
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
