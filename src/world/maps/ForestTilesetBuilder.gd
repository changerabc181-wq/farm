extends Node
class_name ForestTilesetBuilder

## ForestTilesetBuilder - 森林 TileSet 构建器
## forest_tiles.png 分析结果（2026-03-25）：
## 森林地面Tiles (dark green): atlas (0,0) = tile_id 0
## 草地Tiles (green): atlas (1,0) = tile_id 1
## 幽暗森林Tiles: atlas (28,0) = tile_id 28
## 树木Tiles: atlas (27,0) = tile_id 27

const TILESET_NAME := "forest_tiles"
const ATLAS_PATH := "res://assets/tiles/forest_tiles.png"
const TILE_SIZE := Vector2i(16, 16)
const COLUMNS := 64
const ROWS := 64

enum TileCoord {
	FOREST_FLOOR = 0,      # atlas (0,0) = tile_id 0 - 森林地面
	DIRT_PATH = 38,         # atlas (38,0) = tile_id 38 - 泥土路
	FALLEN_LEAVES = 607,   # atlas (31,9) = tile_id 607 - 落叶
	GRASS_NATURAL = 1,     # atlas (1,0) = tile_id 1 - 野草
	OAK_TREE = 0,         # atlas (0,0) = tile_id 0 - 橡树
	PINE_TREE = 27,        # atlas (27,0) = tile_id 27 - 松树
	TREE_STUMP = 38,       # atlas (38,0) = tile_id 38 - 树桩
	MUSHROOM = 1897,       # atlas (41,29) = tile_id 1897 - 蘑菇
	FALLEN_LOG = 52,       # atlas (52,0) = tile_id 52 - 倒木
	ROCK_BOULDER = 1881,   # atlas (25,29) = tile_id 1881 - 巨石
	BERRY_BUSH = 3,        # atlas (3,0) = tile_id 3 - 浆果丛
	WILD_FLOWER = 1062,    # atlas (38,16) = tile_id 1062 - 野花
	FOREST_ENTRANCE = 2,   # atlas (2,0) = tile_id 2 - 森林入口
	HOLLOW_LOG = 39,       # atlas (39,0) = tile_id 39 - 空洞木头
	TREE_ROOTS = 38,       # atlas (38,0) = tile_id 38 - 树根
	MOSS_STONE = 1321,     # atlas (41,20) = tile_id 1321 - 苔藓石
	DARK_FOREST = 28,       # atlas (28,0) = tile_id 28 - 幽暗森林
	ACORN = 108,           # atlas (44,1) = tile_id 108 - 橡子
	PINE_NEEDLES = 2,      # atlas (2,0) = tile_id 2 - 松针地面
	GRASS_SHORT = 1,       # atlas (1,0) = tile_id 1 - 短草
	ROCK_SMALL = 2766,     # atlas (14,43) = tile_id 2766 - 小石
	FERN = 3,             # atlas (3,0) = tile_id 3 - 蕨类
}

const TILE_PROPERTIES := {
	TileCoord.FOREST_FLOOR:    {"passable": true,  "layer": 0, "name": "森林地面"},
	TileCoord.DIRT_PATH:         {"passable": true,  "layer": 0, "name": "泥土路"},
	TileCoord.FALLEN_LEAVES:     {"passable": true,  "layer": 0, "name": "落叶"},
	TileCoord.GRASS_NATURAL:     {"passable": true,  "layer": 0, "name": "野草"},
	TileCoord.GRASS_SHORT:       {"passable": true,  "layer": 0, "name": "短草"},
	TileCoord.FERN:              {"passable": true,  "layer": 0, "name": "蕨类"},
	TileCoord.ROCK_SMALL:        {"passable": false, "layer": 1, "name": "小石"},
	TileCoord.OAK_TREE:          {"passable": false, "layer": 2, "name": "橡树"},
	TileCoord.PINE_TREE:         {"passable": false, "layer": 2, "name": "松树"},
	TileCoord.TREE_STUMP:        {"passable": false, "layer": 2, "name": "树桩"},
	TileCoord.MUSHROOM:          {"passable": true,  "layer": 2, "name": "蘑菇"},
	TileCoord.FALLEN_LOG:        {"passable": false, "layer": 2, "name": "倒木"},
	TileCoord.ROCK_BOULDER:      {"passable": false, "layer": 2, "name": "巨石"},
	TileCoord.BERRY_BUSH:        {"passable": false, "layer": 2, "name": "浆果丛"},
	TileCoord.WILD_FLOWER:       {"passable": true,  "layer": 2, "name": "野花"},
	TileCoord.FOREST_ENTRANCE:   {"passable": true,  "layer": 0, "name": "森林入口"},
	TileCoord.HOLLOW_LOG:        {"passable": false, "layer": 2, "name": "空洞木头"},
	TileCoord.TREE_ROOTS:         {"passable": false, "layer": 2, "name": "树根"},
	TileCoord.MOSS_STONE:         {"passable": false, "layer": 1, "name": "苔藓石"},
	TileCoord.DARK_FOREST:        {"passable": true,  "layer": 0, "name": "幽暗森林"},
	TileCoord.ACORN:              {"passable": true,  "layer": 2, "name": "橡子"},
	TileCoord.PINE_NEEDLES:       {"passable": true,  "layer": 0, "name": "松针地面"},
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
