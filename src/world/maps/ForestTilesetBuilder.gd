extends Node
class_name ForestTilesetBuilder

## ForestTilesetBuilder - 森林 TileSet 构建器
## 将 forest_tiles.png 图集（1024x1024, 16x16 tiles, 64x64 grid）转换为可用的 TileSet

const TILESET_NAME := "forest_tiles"
const ATLAS_PATH := "res://assets/tiles/forest_tiles.png"
const TILE_SIZE := Vector2i(16, 16)
const COLUMNS := 64
const ROWS := 64

enum TileCoord {
	FOREST_FLOOR = 0,
	DIRT_PATH = 1,
	FALLEN_LEAVES = 2,
	GRASS_NATURAL = 3,
	OAK_TREE = 4,
	PINE_TREE = 5,
	TREE_STUMP = 6,
	MUSHROOM = 7,
	FALLEN_LOG = 8,
	ROCK_BOULDER = 9,
	BERRY_BUSH = 10,
	WILD_FLOWER = 11,
	FOREST_ENTRANCE = 12,
	HOLLOW_LOG = 13,
	TREE_ROOTS = 14,
	MOSS_STONE = 15,
	DARK_FOREST = 16,
	ACORN = 17,
	PINE_NEEDLES = 18,
	GRASS_SHORT = 19,
	ROCK_SMALL = 20,
	FERN = 21,
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
