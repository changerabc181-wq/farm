extends Node
class_name VillageTilesetBuilder

## VillageTilesetBuilder - Village TileSet 构建器
## 将 village_tiles.png 图集转换为可用的 TileSet

# tile 图集信息（来自分析）
const TILESET_NAME := "village_tiles"
const ATLAS_PATH := "res://assets/tiles/village_tiles.png"
const TILE_SIZE := Vector2i(16, 16)
const COLUMNS := 64
const ROWS := 64

# Tile ID 映射 (基于 5x5 网格，x + y*10 的格式用于 Godot TileMap)
# 注意：Godot 4 使用 coords = Vector2i(x, y) 在 atlas 中定位 tile
enum TileCoord {
	# Row 0
	STONE_WALL = 0,        # 0,0 - 石墙
	PATH_GRASS_BORDER = 1,  # 1,0 - 泥路草边
	GRASS_PLAIN = 2,       # 2,0 - 纯草地
	TILE_ROOF_DARK = 3,    # 3,0 - 深色瓦顶
	BRICK_WALL = 4,        # 4,0 - 红砖墙
	
	# Row 1
	WOOD_WALL = 10,        # 0,1 - 木板墙
	PATH_PLAIN = 11,       # 1,1 - 纯泥路
	STONE_WALL_CLEAN = 12, # 2,1 - 精修石墙
	ROOF_GRAY = 13,        # 3,1 - 灰色瓦顶
	ROOF_RED = 14,         # 4,1 - 红色瓦顶
	
	# Row 2
	WOOD_WALL_V2 = 20,     # 0,2 - 木板墙v2
	TREE_WALL = 21,        # 1,2 - 树丛/绿墙
	STONE_DOOR = 22,       # 2,2 - 带门石墙
	WINDOW_A = 23,         # 3,2 - 窗户A
	WINDOW_B = 24,         # 4,2 - 窗户B
	
	# Row 3
	WELL = 30,             # 0,3 - 水井
	VILLAGE_SIGN = 31,     # 1,3 - 村庄告示牌
	POTTED_FLOWER = 32,    # 2,3 - 盆栽花
	BARREL = 33,           # 3,3 - 木桶
	CRATE = 34,            # 4,3 - 木箱
	
	# Row 4
	BARREL_TOP = 40,       # 0,4 - 木桶俯视
	BARREL_V2 = 41,        # 1,4 - 木桶v2
	FENCE = 42,            # 2,4 - 木栅栏
	CHEST_LOCKED = 43,     # 3,4 - 宝箱
	BENCH = 44,            # 4,4 - 长凳
}

# Tile 属性定义
const TILE_PROPERTIES := {
	TileCoord.GRASS_PLAIN: {"passable": true, "layer": 0, "name": "草地"},
	TileCoord.PATH_PLAIN: {"passable": true, "layer": 0, "name": "泥路"},
	TileCoord.PATH_GRASS_BORDER: {"passable": true, "layer": 0, "name": "泥路草边"},
	
	TileCoord.STONE_WALL: {"passable": false, "layer": 1, "name": "石墙"},
	TileCoord.WOOD_WALL: {"passable": false, "layer": 1, "name": "木板墙"},
	TileCoord.WOOD_WALL_V2: {"passable": false, "layer": 1, "name": "木板墙v2"},
	TileCoord.BRICK_WALL: {"passable": false, "layer": 1, "name": "红砖墙"},
	TileCoord.STONE_WALL_CLEAN: {"passable": false, "layer": 1, "name": "精修石墙"},
	
	TileCoord.TILE_ROOF_DARK: {"passable": false, "layer": 1, "name": "深色瓦顶"},
	TileCoord.ROOF_GRAY: {"passable": false, "layer": 1, "name": "灰色瓦顶"},
	TileCoord.ROOF_RED: {"passable": false, "layer": 1, "name": "红色瓦顶"},
	
	TileCoord.TREE_WALL: {"passable": false, "layer": 2, "name": "树丛"},
	
	TileCoord.WELL: {"passable": false, "layer": 2, "name": "水井"},
	TileCoord.VILLAGE_SIGN: {"passable": false, "layer": 2, "name": "告示牌"},
	TileCoord.POTTED_FLOWER: {"passable": true, "layer": 2, "name": "盆栽"},
	TileCoord.BARREL: {"passable": false, "layer": 2, "name": "木桶"},
	TileCoord.BARREL_TOP: {"passable": false, "layer": 2, "name": "木桶顶"},
	TileCoord.BARREL_V2: {"passable": false, "layer": 2, "name": "木桶v2"},
	TileCoord.CRATE: {"passable": false, "layer": 2, "name": "木箱"},
	TileCoord.CHEST_LOCKED: {"passable": false, "layer": 2, "name": "宝箱"},
	TileCoord.BENCH: {"passable": false, "layer": 2, "name": "长凳"},
	
	TileCoord.STONE_DOOR: {"passable": false, "layer": 1, "name": "石门"},
	TileCoord.WINDOW_A: {"passable": false, "layer": 1, "name": "窗户A"},
	TileCoord.WINDOW_B: {"passable": false, "layer": 1, "name": "窗户B"},
	
	TileCoord.FENCE: {"passable": false, "layer": 2, "name": "栅栏"},
}

static func get_coord(tile_id: int) -> Vector2i:
	"""将 tile_id 转换为 atlas 坐标"""
	return Vector2i(tile_id % 10, tile_id / 10)

static func build_tileset() -> TileSet:
	"""构建完整的 Village TileSet"""
	var tile_set := TileSet.new()
	tile_set.name = TILESET_NAME
	
	# 创建 atlas source
	var atlas_source := TileSetAtlasSource.new()
	atlas_source.texture = load(ATLAS_PATH)
	atlas_source.texture_region_size = TILE_SIZE
	
	# 遍历所有 tile 设置属性
	for tile_id in TileCoord.values():
		var coords := get_coord(tile_id)
		
		# 创建 tile
		var tile_data := TileSetCellTile.new()
		tile_data.texture_origin = Vector2i.ZERO
		
		# 设置碰撞（如果不可通行）
		var props = TILE_PROPERTIES.get(tile_id, {"passable": true, "layer": 0})
		if not props.get("passable", true):
			# 添加物理层碰撞
			var physics_layer := TileSetPhysicsLayer.new()
			physics_layer.layer_mask = 1
			var shape := RectangleShape2D.new()
			shape.size = TILE_SIZE
			physics_layer.add_shape(shape)
			tile_data.add_physics_layer(physics_layer)
		
		# 设置为可通行
		if props.get("passable", true):
			tile_data.modulate = Color(1, 1, 1, 1)
		
		atlas_source.set_tile_data(_pack_tile_data(tile_id, coords), tile_data)
	
	tile_set.add_source(atlas_source)
	
	# 设置碰壁层
	tile_set.physics_layer_0.layer = 0x01
	
	return tile_set

static func _pack_tile_data(tile_id: int, coords: Vector2i) -> PackedInt32Array:
	"""打包 tile data"""
	var data := PackedInt32Array()
	# tile_id 存入 bits 0-19, 其他 bits 用于 flip/rotation
	data.append(tile_id & 0xFFFFF)
	return data

static func get_tile_name(tile_id: int) -> String:
	"""获取 tile 名称"""
	var props = TILE_PROPERTIES.get(tile_id, {"name": "未知"})
	return props.get("name", "未知")

static func print_tileset_info() -> void:
	print("========== Village TileSet 信息 ==========")
	print("图集路径: ", ATLAS_PATH)
	print("Tile 尺寸: ", TILE_SIZE)
	print("网格: ", COLUMNS, "x", ROWS, " = ", COLUMNS * ROWS, " tiles")
	print("")
	print("Tile 列表:")
	for tile_id in TileCoord.values():
		var coords = get_coord(tile_id)
		var name = get_tile_name(tile_id)
		var props = TILE_PROPERTIES.get(tile_id, {"passable": true, "layer": 0})
		var passable = "✓ 可通行" if props.get("passable") else "✗ 障碍"
		print("  [%2d] (%d,%d) %s - %s" % [tile_id, coords.x, coords.y, name, passable])
	print("=========================================")
