extends Node2D
class_name VillageBuilder

## VillageBuilder - Village 地图构建器
## 使用真实 tile 资源构建可玩的村庄地图

# ===== 地图尺寸 =====
const MAP_WIDTH: int = 1280
const MAP_HEIGHT: int = 960
const TILE_SIZE: int = 64
const MAP_TILES_X: int = 20  # 1280 / 64
const MAP_TILES_Y: int = 15  # 960 / 64

# ===== 图块 ID =====
# Layer 0: 地面
const TID_GRASS: int = 2        # 纯草地 (可通行)
const TID_PATH: int = 11        # 泥路 (可通行)
const TID_PATH_GRASS: int = 1   # 泥路草边 (可通行)

# Layer 1: 建筑/墙体
const TID_STONE_WALL: int = 0   # 石墙
const TID_WOOD_WALL: int = 10   # 木板墙
const TID_BRICK_WALL: int = 4   # 红砖墙
const TID_DOOR: int = 22        # 石门
const TID_ROOF_DARK: int = 3    # 深色瓦顶
const TID_ROOF_RED: int = 14    # 红色瓦顶

# Layer 2: 装饰/物品
const TID_TREE: int = 21        # 树丛
const TID_WELL: int = 30        # 水井
const TID_SIGN: int = 31        # 告示牌
const TID_BENCH: int = 44       # 长凳
const TID_FLOWER: int = 32      # 盆栽
const TID_FENCE: int = 42       # 栅栏

# ===== 颜色定义（用于占位块） =====
const COLOR_EXIT: Color = Color(0.85, 0.25, 0.20, 0.7)
const COLOR_HIGHLIGHT: Color = Color(1.0, 0.9, 0.2, 0.5)

# ===== 节点引用 =====
var tilemap: TileMap
var placeholder_layer: Node2D  # 用于不在 tile 里的占位元素

# ===== 出口定义 =====
const TRANSITIONS := {
	"to_farm": {
		"position": Vector2(60, 300),
		"target": "res://src/world/maps/Farm.tscn",
		"spawn": "village_exit"
	},
	"to_player_house": {
		"position": Vector2(400, 580),
		"target": "res://src/world/maps/PlayerHouse.tscn",
		"spawn": "village_exit"
	},
	"to_beach": {
		"position": Vector2(1100, 700),
		"target": "res://src/world/maps/Beach.tscn",
		"spawn": "village_exit"
	},
	"to_forest": {
		"position": Vector2(640, 60),
		"target": "res://src/world/maps/Forest.tscn",
		"spawn": "village_exit"
	},
	"to_mine": {
		"position": Vector2(180, 820),
		"target": "res://src/world/maps/Mine.tscn",
		"spawn": "village_exit"
	}
}

func _ready() -> void:
	print("========== VillageBuilder 开始构建 ==========")
	
	var village = get_parent()
	if village == null or not "add_child" in village:
		push_error("[VillageBuilder] 需要作为 Village 子节点运行！")
		return
	
	# 获取 TileMap
	tilemap = village.get_node_or_null("TileMap")
	if tilemap == null:
		push_error("[VillageBuilder] 找不到 TileMap 节点！")
		return
	
	# 构建 TileSet 并填充地图
	_setup_tileset()
	_fill_ground_layer()
	_fill_roads()
	_fill_buildings()
	_fill_trees_boundaries()
	_add_decoration_tiles()
	_add_transition_zones(village)
	
	# 清理占位块图层
	_clean_placeholder_layer()
	
	print("========== VillageBuilder 构建完成 ==========")

func _setup_tileset() -> void:
	"""构建并应 TileSet"""
	# 使用 VillageTilesetBuilder 创建 TileSet
	var tile_set = VillageTilesetBuilder.build_tileset()
	tilemap.tile_set = tile_set
	print("[VillageBuilder] TileSet 构建完成")

func _fill_ground_layer() -> void:
	"""填充地面层 - 草地 + 道路"""
	# 整个地图先铺草地
	for y in range(MAP_TILES_Y):
		for x in range(MAP_TILES_X):
			tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(2, 0))  # 草地
	
	# 铺主道路（东西向）- y = 4 (第5行)
	for x in range(MAP_TILES_X):
		_set_tile_safe(0, Vector2i(x, 4), TID_PATH)
		# 草边
		_set_tile_safe(0, Vector2i(x, 3), TID_PATH_GRASS)
		_set_tile_safe(0, Vector2i(x, 5), TID_PATH_GRASS)
	
	# 铺主道路（南北向）- x = 5-7 (第6-8列)
	for y in range(MAP_TILES_Y):
		_set_tile_safe(0, Vector2i(6, y), TID_PATH)
		_set_tile_safe(0, Vector2i(5, y), TID_PATH_GRASS)
		_set_tile_safe(0, Vector2i(7, y), TID_PATH_GRASS)
	
	# 支路 - 通往北方森林出口 (x = 10)
	for y in range(2):
		_set_tile_safe(0, Vector2i(10, y), TID_PATH)
	
	# 支路 - 通往南方玩家家 (x = 6, y = 7-9)
	for y in range(7, 10):
		_set_tile_safe(0, Vector2i(6, y), TID_PATH)
	
	# 支路 - 通往东方海滩 (y = 7, x = 8-17)
	for x in range(8, 18):
		_set_tile_safe(0, Vector2i(x, 7), TID_PATH)
	
	# 支路 - 通往西南矿洞 (y = 9-12, x = 3)
	for y in range(9, 13):
		_set_tile_safe(0, Vector2i(3, y), TID_PATH)
	
	print("[VillageBuilder] 地面层填充完成")

func _fill_roads() -> void:
	"""补充道路细节"""
	# 村中心广场 - 以 (6,4) 为中心的一片空地
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			_set_tile_safe(0, Vector2i(6+dx, 4+dy), TID_PATH)

func _fill_buildings() -> void:
	"""填充建筑物 - 使用墙体 tile"""
	# ===== 村中心/广场 (Vector2i(8, 2) 为中心) =====
	# 建筑基底 - 一片草地先清空作为广场
	for dx in range(-2, 3):
		for dy in range(-1, 2):
			_set_tile_safe(0, Vector2i(8+dx, 2+dy), TID_PATH)
	
	# 公告板位置 (8, 2) - 用告示牌 tile
	_set_tile_safe(2, Vector2i(8, 2), TID_SIGN)
	
	# ===== 玛丽亚商店 (中心 x=11, y=3) =====
	# 商店基底 - 清空
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			_set_tile_safe(0, Vector2i(11+dx, 3+dy), TID_PATH)
	# 商店屋顶
	tilemap.set_cell(1, Vector2i(11, 2), 0, Vector2i(14, 0))  # 红色瓦顶
	# 商店墙体
	tilemap.set_cell(1, Vector2i(10, 3), 0, Vector2i(4, 0))   # 左墙
	tilemap.set_cell(1, Vector2i(12, 3), 0, Vector2i(4, 0))   # 右墙
	tilemap.set_cell(1, Vector2i(11, 4), 0, Vector2i(22, 0))   # 门
	
	# ===== 托马斯镇长家 (x=6, y=1) =====
	for dx in range(-1, 2):
		for dy in range(-1, 1):
			_set_tile_safe(0, Vector2i(6+dx, 1+dy), TID_PATH)
	tilemap.set_cell(1, Vector2i(6, 0), 0, Vector2i(13, 0))  # 灰色屋顶
	tilemap.set_cell(1, Vector2i(5, 1), 0, Vector2i(0, 0))   # 石墙
	tilemap.set_cell(1, Vector2i(7, 1), 0, Vector2i(0, 0))   # 石墙
	
	# ===== 老约翰家 (x=2, y=5) =====
	for dx in range(-1, 2):
		for dy in range(-1, 1):
			_set_tile_safe(0, Vector2i(2+dx, 5+dy), TID_PATH)
	tilemap.set_cell(1, Vector2i(2, 4), 0, Vector2i(3, 0))   # 深色屋顶
	tilemap.set_cell(1, Vector2i(1, 5), 0, Vector2i(10, 0))  # 木墙
	tilemap.set_cell(1, Vector2i(3, 5), 0, Vector2i(10, 0))  # 木墙
	
	# ===== 铁锤工匠铺 (x=13, y=6) =====
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			_set_tile_safe(0, Vector2i(13+dx, 6+dy), TID_PATH)
	tilemap.set_cell(1, Vector2i(13, 5), 0, Vector2i(14, 0)) # 红屋顶
	tilemap.set_cell(1, Vector2i(12, 6), 0, Vector2i(0, 0))  # 石墙
	tilemap.set_cell(1, Vector2i(14, 6), 0, Vector2i(0, 0))  # 石墙
	
	# ===== 莉莉医生诊所 (x=9, y=1) =====
	for dx in range(-1, 1):
		for dy in range(-1, 1):
			_set_tile_safe(0, Vector2i(9+dx, 1+dy), TID_PATH)
	tilemap.set_cell(1, Vector2i(9, 0), 0, Vector2i(13, 0)) # 灰屋顶
	tilemap.set_cell(1, Vector2i(10, 1), 0, Vector2i(10, 0)) # 木墙
	
	# ===== 玩家家外部 (x=6, y=9) =====
	for dx in range(-1, 2):
		for dy in range(-1, 1):
			_set_tile_safe(0, Vector2i(6+dx, 9+dy), TID_PATH)
	tilemap.set_cell(1, Vector2i(6, 8), 0, Vector2i(3, 0))   # 深色屋顶
	tilemap.set_cell(1, Vector2i(5, 9), 0, Vector2i(4, 0))   # 红砖墙
	tilemap.set_cell(1, Vector2i(7, 9), 0, Vector2i(4, 0))   # 红砖墙
	tilemap.set_cell(1, Vector2i(6, 10), 0, Vector2i(22, 0))  # 门
	
	print("[VillageBuilder] 建筑物填充完成")

func _fill_trees_boundaries() -> void:
	"""填充边界装饰 - 树丛/树林"""
	# ===== 北方森林边界 (y = 0) =====
	for x in range(MAP_TILES_X):
		_set_tile_safe(2, Vector2i(x, 0), TID_TREE)
	
	# ===== 左边树林 (x = 0-1) =====
	for y in range(1, 6):
		_set_tile_safe(2, Vector2i(0, y), TID_TREE)
		_set_tile_safe(2, Vector2i(1, y), TID_TREE)
	
	# ===== 右边上边树林 (x = 15-19, y = 0-3) =====
	for x in range(15, MAP_TILES_X):
		for y in range(1, 4):
			_set_tile_safe(2, Vector2i(x, y), TID_TREE)
	
	# ===== 右下角小丛林 (x = 16-18, y = 9-11) =====
	for x in range(16, 19):
		for y in range(9, 12):
			_set_tile_safe(2, Vector2i(x, y), TID_TREE)
	
	# ===== 左下角矿洞入口区域 (x = 2, y = 12-13) =====
	for x in range(1, 3):
		_set_tile_safe(2, Vector2i(x, 12), TID_TREE)
		_set_tile_safe(2, Vector2i(x, 13), TID_TREE)
	
	print("[VillageBuilder] 边界树丛填充完成")

func _add_decoration_tiles() -> void:
	"""添加装饰性 tile"""
	# 广场水井 (8, 3)
	_set_tile_safe(2, Vector2i(8, 3), TID_WELL)
	
	# 广场长凳 (10, 4)
	_set_tile_safe(2, Vector2i(10, 4), TID_BENCH)
	
	# 商店前盆栽 (13, 4)
	_set_tile_safe(2, Vector2i(13, 4), TID_FLOWER)
	_set_tile_safe(2, Vector2i(14, 3), TID_FLOWER)
	
	# 入口栅栏 (通往 Farm 的路上)
	_set_tile_safe(2, Vector2i(1, 4), TID_FENCE)
	_set_tile_safe(2, Vector2i(2, 4), TID_FENCE)

func _add_transition_zones(village: Node) -> void:
	"""添加场景过渡区"""
	var existing = village.get_node_or_null("TransitionAreas")
	if existing == null:
		existing = Node2D.new()
		existing.name = "TransitionAreas"
		village.add_child(existing)
	
	var new_transitions = [
		{"name": "ToPlayerHouseArea", "pos": TRANSITIONS["to_player_house"]["position"]},
		{"name": "ToBeachArea", "pos": TRANSITIONS["to_beach"]["position"]},
		{"name": "ToForestArea", "pos": TRANSITIONS["to_forest"]["position"]},
		{"name": "ToMineArea", "pos": TRANSITIONS["to_mine"]["position"]},
	]
	
	for t in new_transitions:
		if existing.has_node(t["name"]):
			print("[VillageBuilder] 跳过已存在: ", t["name"])
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
		
		# 视觉占位
		var vis = ColorRect.new()
		vis.name = "Visual"
		vis.size = Vector2(48, 48)
		vis.position = Vector2(-24, -24)
		vis.color = COLOR_EXIT
		vis.z_index = 10
		area.add_child(vis)
		
		area.body_entered.connect(_on_transition_body_entered.bind(t["name"]))
	
	print("[VillageBuilder] 过渡区完成")

func _on_transition_body_entered(body: Node, area_name: String) -> void:
	if body is Player:
		print("[VillageBuilder] 玩家进入: ", area_name)
		var target = ""
		match area_name:
			"ToPlayerHouseArea": target = TRANSITIONS["to_player_house"]["target"]
			"ToBeachArea": target = TRANSITIONS["to_beach"]["target"]
			"ToForestArea": target = TRANSITIONS["to_forest"]["target"]
			"ToMineArea": target = TRANSITIONS["to_mine"]["target"]
			"ToFarmArea": target = TRANSITIONS["to_farm"]["target"]
		if target:
			SceneTransition.transition_to(target)

func _set_tile_safe(layer: int, coord: Vector2i, tile_id: int) -> void:
	"""安全设置 tile（跳过已存在的）"""
	var existing = tilemap.get_cell_source_id(layer, coord)
	if existing == -1:
		tilemap.set_cell(layer, coord, 0, VillageTilesetBuilder.get_coord(tile_id))

func _clean_placeholder_layer() -> void:
	"""清理旧的占位块图层"""
	var village = get_parent()
	if village == null:
		return
	
	var old_layers = ["GroundLayer", "RoadLayer", "BuildingLayer", "DecorationLayer"]
	for layer_name in old_layers:
		var layer = village.get_node_or_null(layer_name)
		if layer:
			village.remove_child(layer)
			layer.queue_free()
			print("[VillageBuilder] 清理旧图层: ", layer_name)
	
	# 保留 ExitLayer 和新建的过渡区
	print("[VillageBuilder] 占位图层清理完成")
