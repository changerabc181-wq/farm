extends Node
class_name BeachTilesetBuilder

## BeachTilesetBuilder - 海滩 TileSet 构建器
## beach_tiles.png 分析结果（2026-03-25）：
## 水体主要区域: rows 2-63, cols 32-63 (tile_id ~185-4095)
## 沙滩/草地区域: rows 3-14, cols 0-32
## 沙质Tiles (row 0): tile_ids 0-20
## 水边缘Tiles (row 3): tile_ids 246-255

const TILESET_NAME := "beach_tiles"
const ATLAS_PATH := "res://assets/tiles/beach_tiles.png"
const TILE_SIZE := Vector2i(16, 16)
const COLUMNS := 64
const ROWS := 64

enum TileCoord {
	SAND_PLAIN = 0,          # atlas (0,0) - 沙滩主色
	SAND_WET = 1,            # atlas (1,0) - 湿沙
	SHALLOW_WATER = 319,     # atlas (63,4) - 浅水
	DEEP_WATER = 185,        # atlas (57,2) - 深水
	WATER_SURFACE = 246,     # atlas (54,3) - 水面
	SEASHELL = 297,          # atlas (41,4) - 贝壳
	STARFISH = 2371,         # atlas (3,37) - 海星
	DRIFTWOOD = 602,         # atlas (26,9) - 浮木
	BEACH_GRASS = 160,       # atlas (32,2) - 海滩草
	PIER_WOOD = 21,          # atlas (21,0) - 码头木头
	ROCK_POOL = 298,         # atlas (42,4) - 岩石池
	CORAL = 225,             # atlas (33,3) - 珊瑚
	SEAWEED = 693,           # atlas (53,10) - 海草
	BEACH_PATH = 287,        # atlas (31,4) - 沙滩路
	SANDCASTLE = 288,        # atlas (32,4) - 沙堡
	WATER_EDGE_SAND_L = 246, # atlas (54,3) - 水边左
	WATER_EDGE_SAND_R = 255, # atlas (63,3) - 水边右
	PEBBLES = 298,           # atlas (42,4) - 鹅卵石
	WATER_EDGE_SAND_T = 185, # atlas (57,2) - 水边上
}

const TILE_PROPERTIES := {
	TileCoord.SAND_PLAIN:      {"passable": true,  "layer": 0, "name": "沙滩"},
	TileCoord.SAND_WET:         {"passable": true,  "layer": 0, "name": "湿沙滩"},
	TileCoord.BEACH_PATH:       {"passable": true,  "layer": 0, "name": "沙滩路"},
	TileCoord.PEBBLES:          {"passable": true,  "layer": 0, "name": "鹅卵石"},
	TileCoord.SHALLOW_WATER:   {"passable": false, "layer": 1, "name": "浅水"},
	TileCoord.DEEP_WATER:      {"passable": false, "layer": 1, "name": "深水"},
	TileCoord.WATER_SURFACE:   {"passable": false, "layer": 1, "name": "水面"},
	TileCoord.WATER_EDGE_SAND_L: {"passable": false, "layer": 1, "name": "水边左"},
	TileCoord.WATER_EDGE_SAND_R: {"passable": false, "layer": 1, "name": "水边右"},
	TileCoord.WATER_EDGE_SAND_T: {"passable": false, "layer": 1, "name": "水边上"},
	TileCoord.PIER_WOOD:        {"passable": true,  "layer": 1, "name": "码头木板"},
	TileCoord.SEASHELL:         {"passable": true,  "layer": 2, "name": "贝壳"},
	TileCoord.STARFISH:         {"passable": true,  "layer": 2, "name": "海星"},
	TileCoord.DRIFTWOOD:        {"passable": false, "layer": 2, "name": "浮木"},
	TileCoord.BEACH_GRASS:     {"passable": false, "layer": 2, "name": "海滩草"},
	TileCoord.ROCK_POOL:       {"passable": false, "layer": 2, "name": "岩石池"},
	TileCoord.CORAL:            {"passable": true,  "layer": 2, "name": "珊瑚"},
	TileCoord.SEAWEED:          {"passable": false, "layer": 2, "name": "海草"},
	TileCoord.SANDCASTLE:      {"passable": false, "layer": 2, "name": "沙堡"},
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
