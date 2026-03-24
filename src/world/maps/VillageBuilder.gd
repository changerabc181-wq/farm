extends Node2D
class_name VillageBuilder

## VillageBuilder - Village 白模地图构建器
## 运行此脚本自动生成 Village 的占位块结构

# ===== 地图尺寸 =====
const MAP_WIDTH: int = 1280
const MAP_HEIGHT: int = 960
const TILE_SIZE: int = 32

# ===== 颜色定义 =====
const COLOR_GROUND: Color = Color(0.35, 0.65, 0.25, 1.0)       # 草地绿
const COLOR_ROAD: Color = Color(0.75, 0.70, 0.55, 1.0)        # 土路米色
const COLOR_BUILDING: Color = Color(0.55, 0.35, 0.20, 1.0)    # 建筑棕色
const COLOR_BUILDING_DIM: Color = Color(0.45, 0.28, 0.15, 1.0) # 建筑深棕
const COLOR_WATER: Color = Color(0.25, 0.45, 0.75, 1.0)       # 水体蓝
const COLOR_TREE: Color = Color(0.15, 0.45, 0.15, 1.0)        # 树木深绿
const COLOR_EXIT: Color = Color(0.85, 0.25, 0.20, 0.7)        # 出口红
const COLOR_NPC_HOUSE: Color = Color(0.65, 0.45, 0.30, 1.0)   # NPC住宅橙棕
const COLOR_SHOP: Color = Color(0.70, 0.50, 0.25, 1.0)        # 商店
const COLOR_NOTICE_BOARD: Color = Color(0.80, 0.65, 0.30, 1.0) # 公告板

# ===== 节点引用 =====
var ground_layer: Node2D
var road_layer: Node2D
var building_layer: Node2D
var decoration_layer: Node2D
var exit_layer: Node2D
var tilemap: TileMap

# ===== 出口位置定义 =====
# 这些是世界坐标，连接到其他场景
const TRANSITIONS := {
	"to_farm": {
		"position": Vector2(60, 300),
		"target": "res://src/world/maps/Farm.tscn",
		"spawn_point": "village_exit"
	},
	"to_player_house": {
		"position": Vector2(400, 580),
		"target": "res://src/world/maps/PlayerHouse.tscn",
		"spawn_point": "village_exit"
	},
	"to_beach": {
		"position": Vector2(1100, 700),
		"target": "res://src/world/maps/Beach.tscn",
		"spawn_point": "village_exit"
	},
	"to_forest": {
		"position": Vector2(640, 60),
		"target": "res://src/world/maps/Forest.tscn",
		"spawn_point": "village_exit"
	},
	"to_mine": {
		"position": Vector2(180, 820),
		"target": "res://src/world/maps/Mine.tscn",
		"spawn_point": "village_exit"
	}
}

func _ready() -> void:
	print("========== VillageBuilder 开始构建 ==========")
	
	# 获取 Village 场景根节点
	var village = get_parent()
	if village == null or not village.has_method("add_child"):
		push_error("[VillageBuilder] 需要作为 Village 子节点运行！")
		return
	
	# 初始化各层
	_setup_layers(village)
	
	# 1. 创建地面
	_create_ground()
	
	# 2. 创建道路网络
	_create_roads()
	
	# 3. 创建建筑物占位块
	_create_buildings()
	
	# 4. 创建边界装饰（树/水）
	_create_boundaries()
	
	# 5. 添加缺失的过渡区
	_add_transition_zones(village)
	
	print("========== VillageBuilder 构建完成 ==========")
	print("提示：运行游戏后，按 F1 切换到调试模式查看占位块")

func _setup_layers(village: Node) -> void:
	"""创建地图各层的父节点"""
	ground_layer = Node2D.new()
	ground_layer.name = "GroundLayer"
	village.add_child(ground_layer)
	
	road_layer = Node2D.new()
	road_layer.name = "RoadLayer"
	village.add_child(road_layer)
	
	building_layer = Node2D.new()
	building_layer.name = "BuildingLayer"
	village.add_child(building_layer)
	
	decoration_layer = Node2D.new()
	decoration_layer.name = "DecorationLayer"
	village.add_child(decoration_layer)
	
	exit_layer = Node2D.new()
	exit_layer.name = "ExitLayer"
	village.add_child(exit_layer)
	
	# 获取 TileMap 引用
	tilemap = village.get_node_or_null("TileMap")
	print("[VillageBuilder] 层初始化完成")

func _create_ground() -> void:
	"""创建整张地图的地面底色"""
	var ground = ColorRect.new()
	ground.name = "GroundBase"
	ground.size = Vector2(MAP_WIDTH, MAP_HEIGHT)
	ground.position = Vector2(MAP_WIDTH / 2, MAP_HEIGHT / 2)  # 左上角
	ground.color = COLOR_GROUND
	ground.z_index = -10
	ground_layer.add_child(ground)
	print("[VillageBuilder] 地面底色创建完成: ", ground.size)

func _create_roads() -> void:
	"""创建道路网络"""
	var roads = [
		# 主路 - 东西向（连接农场和商店）
		{"name": "MainRoadEastWest", "pos": Vector2(300, 300), "size": Vector2(700, 48)},
		# 主路 - 南北向（连接中心和南边）
		{"name": "MainRoadNorthSouth", "pos": Vector2(400, 250), "size": Vector2(48, 200)},
		# 支路 - 通向北方出口
		{"name": "RoadToForest", "pos": Vector2(640, 150), "size": Vector2(32, 120)},
		# 支路 - 通向南方玩家家
		{"name": "RoadToPlayerHouse", "pos": Vector2(400, 450), "size": Vector2(48, 160)},
		# 支路 - 通向东北海滩
		{"name": "RoadToBeach", "pos": Vector2(900, 450), "size": Vector2(280, 48)},
		# 支路 - 通向西南方矿洞
		{"name": "RoadToMine", "pos": Vector2(300, 600), "size": Vector2(200, 48)},
	]
	
	for road_data in roads:
		var road = ColorRect.new()
		road.name = road_data["name"]
		road.size = road_data["size"]
		road.position = road_data["pos"] - road_data["size"] / 2
		road.color = COLOR_ROAD
		road.z_index = -5
		road_layer.add_child(road)
	
	print("[VillageBuilder] 道路网络创建完成: ", roads.size(), " 条道路")

func _create_buildings() -> void:
	"""创建建筑物占位块"""
	var buildings = [
		# 村中心广场
		{
			"name": "VillageCenter",
			"pos": Vector2(400, 200),
			"size": Vector2(160, 120),
			"color": COLOR_BUILDING,
			"label": "村中心"
		},
		# 公告板
		{
			"name": "NoticeBoard",
			"pos": Vector2(480, 180),
			"size": Vector2(48, 48),
			"color": COLOR_NOTICE_BOARD,
			"label": "公告板"
		},
		# 玛丽亚商店
		{
			"name": "MariaShop",
			"pos": Vector2(600, 250),
			"size": Vector2(128, 96),
			"color": COLOR_SHOP,
			"label": "杂货店"
		},
		# 托马斯镇长家
		{
			"name": "MayorHouse",
			"pos": Vector2(400, 120),
			"size": Vector2(96, 80),
			"color": COLOR_NPC_HOUSE,
			"label": "镇长家"
		},
		# 老约翰家（农场主）
		{
			"name": "JohnHouse",
			"pos": Vector2(200, 350),
			"size": Vector2(96, 80),
			"color": COLOR_NPC_HOUSE,
			"label": "老约翰家"
		},
		# 铁锤工匠铺
		{
			"name": "BlacksmithShop",
			"pos": Vector2(700, 400),
			"size": Vector2(112, 96),
			"color": COLOR_BUILDING_DIM,
			"label": "工匠铺"
		},
		# 莉莉医生诊所
		{
			"name": "Clinic",
			"pos": Vector2(500, 150),
			"size": Vector2(80, 64),
			"color": Color(0.80, 0.85, 0.80, 1.0),
			"label": "诊所"
		},
		# 玩家之家
		{
			"name": "PlayerHouseExterior",
			"pos": Vector2(400, 520),
			"size": Vector2(128, 96),
			"color": COLOR_BUILDING,
			"label": "玩家家"
		},
	]
	
	for b in buildings:
		_createsingle_building(b)
	
	print("[VillageBuilder] 建筑物创建完成: ", buildings.size(), " 个")

func _createsingle_building(data: Dictionary) -> void:
	"""创建单个建筑占位块"""
	var bldg = Node2D.new()
	bldg.name = data["name"]
	bldg.position = data["pos"]
	building_layer.add_child(bldg)
	
	var rect = ColorRect.new()
	rect.name = "Footprint"
	rect.size = data["size"]
	rect.position = -data["size"] / 2
	rect.color = data["color"]
	bldg.add_child(rect)
	
	# 添加简单标签（使用 TextEdit 临时方案）
	var label = Label.new()
	label.name = "Label"
	label.text = data.get("label", data["name"])
	label.position = Vector2(-data["size"].x / 2, -data["size"].y / 2 - 20)
	label.add_theme_font_size_override("font_size", 10)
	bldg.add_child(label)

func _create_boundaries() -> void:
	"""创建边界装饰（树、水体等）"""
	# 北方森林边界
	for i in range(20):
		var tree = _make_tree(Vector2(64 + i * 64, 32))
		decoration_layer.add_child(tree)
	
	# 左边部分树林
	for i in range(8):
		var tree = _make_tree(Vector2(32, 64 + i * 64))
		decoration_layer.add_child(tree)
	
	# 右边远端树丛
	for i in range(6):
		var tree = _make_tree(Vector2(1200, 64 + i * 80))
		decoration_layer.add_child(tree)
	
	# 右下角小池塘
	var pond = ColorRect.new()
	pond.name = "Pond"
	pond.size = Vector2(96, 64)
	pond.position = Vector2(1100, 600)
	pond.color = COLOR_WATER
	decoration_layer.add_child(pond)
	
	# 左下角岩石/矿洞入口
	var cave = ColorRect.new()
	cave.name = "MineEntrance"
	cave.size = Vector2(80, 64)
	cave.position = Vector2(140, 780)
	cave.color = Color(0.4, 0.35, 0.3, 1.0)
	decoration_layer.add_child(cave)
	
	# 东南海滩入口
	var beach = ColorRect.new()
	beach.name = "BeachEntrance"
	beach.size = Vector2(120, 80)
	beach.position = Vector2(1040, 660)
	beach.color = Color(0.9, 0.85, 0.6, 1.0)
	decoration_layer.add_child(beach)
	
	print("[VillageBuilder] 边界装饰创建完成")

func _make_tree(pos: Vector2) -> Node2D:
	"""创建单棵树占位"""
	var tree = Node2D.new()
	tree.name = "Tree"
	tree.position = pos
	
	var trunk = ColorRect.new()
	trunk.name = "Trunk"
	trunk.size = Vector2(16, 16)
	trunk.position = Vector2(-8, -8)
	trunk.color = Color(0.4, 0.25, 0.1, 1.0)
	tree.add_child(trunk)
	
	var crown = ColorRect.new()
	crown.name = "Crown"
	crown.size = Vector2(28, 28)
	crown.position = Vector2(-14, -20)
	crown.color = COLOR_TREE
	tree.add_child(crown)
	
	return tree

func _add_transition_zones(village: Node) -> void:
	"""添加所有缺失的过渡区"""
	var existing = village.get_node_or_null("TransitionAreas")
	if existing == null:
		existing = Node2D.new()
		existing.name = "TransitionAreas"
		village.add_child(existing)
	
	# 创建其他过渡区（ToFarm 已存在于 Village.tscn）
	var new_transitions = [
		{"name": "ToPlayerHouseArea", "pos": TRANSITIONS["to_player_house"]["position"]},
		{"name": "ToBeachArea", "pos": TRANSITIONS["to_beach"]["position"]},
		{"name": "ToForestArea", "pos": TRANSITIONS["to_forest"]["position"]},
		{"name": "ToMineArea", "pos": TRANSITIONS["to_mine"]["position"]},
	]
	
	for t in new_transitions:
		# 检查是否已存在
		if existing.has_node(t["name"]):
			print("[VillageBuilder] 跳过已存在过渡区: ", t["name"])
			continue
		
		var area = Area2D.new()
		area.name = t["name"]
		area.position = t["pos"]
		existing.add_child(area)
		
		var shape = CollisionShape2D.new()
		shape.name = "CollisionShape2D"
		shape.shape = RectangleShape2D.new()
		shape.shape.size = Vector2(48, 48)
		area.add_child(shape)
		
		# 添加可视化占位
		var vis = ColorRect.new()
		vis.name = "Visual"
		vis.size = Vector2(48, 48)
		vis.position = Vector2(-24, -24)
		vis.color = COLOR_EXIT
		vis.z_index = 10
		area.add_child(vis)
		
		# 连接信号
		area.body_entered.connect(_on_transition_body_entered.bind(t["name"]))
		
		# 添加标签
		var label = Label.new()
		label.name = "Label"
		label.text = t["name"].replace("Area", "")
		label.position = Vector2(-30, -50)
		label.add_theme_font_size_override("font_size", 8)
		area.add_child(label)
	
	print("[VillageBuilder] 过渡区创建完成，已存在: ToFarm, 新增: ", new_transitions.size())

func _on_transition_body_entered(body: Node, area_name: String) -> void:
	"""过渡区碰撞检测"""
	if body is Player:
		print("[VillageBuilder] 玩家进入过渡区: ", area_name)
		var target_path = ""
		match area_name:
			"ToPlayerHouseArea":
				target_path = TRANSITIONS["to_player_house"]["target"]
			"ToBeachArea":
				target_path = TRANSITIONS["to_beach"]["target"]
			"ToForestArea":
				target_path = TRANSITIONS["to_forest"]["target"]
			"ToMineArea":
				target_path = TRANSITIONS["to_mine"]["target"]
			"ToFarmArea":
				target_path = TRANSITIONS["to_farm"]["target"]
		
		if target_path:
			print("[VillageBuilder] 切换场景到: ", target_path)
			SceneTransition.transition_to(target_path)
