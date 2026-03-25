extends Node
class_name MineTilesetBuilder

## MineTilesetBuilder - 矿洞 TileSet 构建器
## mine_tiles.png 分析结果（2026-03-25）：
## 主要矿石分布: cols 17-63 区域
## 石砖地面: atlas (1,0) = tile_id 1
## 煤矿石: atlas (16,0) = tile_id 16
## 铁矿: atlas (19,1) = tile_id 83
## 铜矿: atlas (24,2) = tile_id 152
## 金矿: atlas (58,1) = tile_id 122
## 宝石: atlas (51,17) = tile_id 1139 (rows 17-22, cols 49-63)
## 发光矿石: atlas (56,5) = tile_id 376 (rows 5-8, cols 55-57)

const TILESET_NAME := "mine_tiles"
const ATLAS_PATH := "res://assets/tiles/mine_tiles.png"
const TILE_SIZE := Vector2i(16, 16)
const COLUMNS := 64
const ROWS := 64

enum TileCoord {
	STONE_FLOOR = 1,       # atlas (1,0) = tile_id 1 - 石砖地面
	DIRT_FLOOR = 0,         # atlas (0,0) = tile_id 0 - 泥土地面
	STONE_WALL = 1,         # atlas (1,0) = tile_id 1 - 石墙
	DARK_STONE = 16,        # atlas (16,0) = tile_id 16 - 深色石头
	CRACKED_WALL = 0,      # atlas (0,0) = tile_id 0 - 裂缝墙壁
	COPPER_ORE = 152,       # atlas (24,2) = tile_id 152 - 铜矿
	IRON_ORE = 83,          # atlas (19,1) = tile_id 83 - 铁矿
	GOLD_ORE = 122,         # atlas (58,1) = tile_id 122 - 金矿
	COAL_ORE = 16,          # atlas (16,0) = tile_id 16 - 煤矿
	GEM_ORE = 1139,         # atlas (51,17) = tile_id 1139 - 宝石矿
	GLOWING_ORE = 376,      # atlas (56,5) = tile_id 376 - 发光矿石
	WOOD_SUPPORT = 88,     # atlas (24,1) = tile_id 88 - 木支撑
	LADDER_UP = 88,        # atlas (24,1) = tile_id 88 - 向上梯子
	LADDER_DOWN = 88,      # atlas (24,1) = tile_id 88 - 向下梯子
	TORCH_BRACKET = 88,    # atlas (24,1) = tile_id 88 - 火把
	MINECART_TRACK = 4,    # atlas (4,0) = tile_id 4 - 矿车轨道
	RUBBLE = 0,            # atlas (0,0) = tile_id 0 - 碎石
	CRACKED_FLOOR = 0,     # atlas (0,0) = tile_id 0 - 裂缝地面
}

const TILE_PROPERTIES := {
	TileCoord.STONE_FLOOR:    {"passable": true,  "layer": 0, "name": "石砖地面"},
	TileCoord.DIRT_FLOOR:     {"passable": true,  "layer": 0, "name": "泥土地面"},
	TileCoord.CRACKED_FLOOR:  {"passable": true,  "layer": 0, "name": "裂缝地面"},
	TileCoord.RUBBLE:          {"passable": true,  "layer": 0, "name": "碎石"},
	TileCoord.MINECART_TRACK:  {"passable": true,  "layer": 0, "name": "矿车轨道"},
	TileCoord.STONE_WALL:      {"passable": false, "layer": 1, "name": "石墙"},
	TileCoord.CRACKED_WALL:    {"passable": false, "layer": 1, "name": "裂缝墙壁"},
	TileCoord.DARK_STONE:      {"passable": false, "layer": 1, "name": "深色石头"},
	TileCoord.COPPER_ORE:      {"passable": false, "layer": 2, "name": "铜矿"},
	TileCoord.IRON_ORE:        {"passable": false, "layer": 2, "name": "铁矿"},
	TileCoord.GOLD_ORE:        {"passable": false, "layer": 2, "name": "金矿"},
	TileCoord.COAL_ORE:        {"passable": false, "layer": 2, "name": "煤矿"},
	TileCoord.GEM_ORE:          {"passable": false, "layer": 2, "name": "宝石矿"},
	TileCoord.GLOWING_ORE:      {"passable": false, "layer": 2, "name": "发光矿石"},
	TileCoord.WOOD_SUPPORT:     {"passable": false, "layer": 1, "name": "木支撑"},
	TileCoord.LADDER_UP:       {"passable": true,  "layer": 1, "name": "向上梯子"},
	TileCoord.LADDER_DOWN:      {"passable": true,  "layer": 1, "name": "向下梯子"},
	TileCoord.TORCH_BRACKET:    {"passable": true,  "layer": 2, "name": "火把"},
}

static func get_coord(tile_id: int) -> Vector2i:
	return Vector2i(tile_id % COLUMNS, tile_id / COLUMNS)

static func build_tileset() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.name = TILESET_NAME
	tile_set.physics_layer_0.layer = 0x01

	var atlas_source := TileSetAtlasSource.new()
	atlas_source.texture = load(ATLAS_PATH)
	atlas_source.texture_region_size = TILE_SIZE

	for tile_id in TileCoord.values():
		var tile_data := TileSetCellTile.new()
		tile_data.texture_origin = Vector2i.ZERO
		var props = TILE_PROPERTIES.get(tile_id, {"passable": true, "layer": 0})
		if not props.get("passable", true):
			var physics_layer := TileSetPhysicsLayer.new()
			physics_layer.layer_mask = 1
			var shape := RectangleShape2D.new()
			shape.size = TILE_SIZE
			physics_layer.add_shape(shape)
			tile_data.add_physics_layer(physics_layer)
		atlas_source.set_tile_data(_pack_tile_data(tile_id), tile_data)

	tile_set.add_source(atlas_source)
	return tile_set

static func _pack_tile_data(tile_id: int) -> PackedInt32Array:
	var data := PackedInt32Array()
	data.append(tile_id & 0xFFFFF)
	return data

static func get_tile_name(tile_id: int) -> String:
	var props = TILE_PROPERTIES.get(tile_id, {"name": "未知"})
	return props.get("name", "未知")
