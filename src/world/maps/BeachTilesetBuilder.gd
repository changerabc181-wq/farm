extends Node
class_name BeachTilesetBuilder

## BeachTilesetBuilder - 海滩 TileSet 构建器
## 将 beach_tiles.png 图集（1024x1024, 16x16 tiles, 64x64 grid）转换为可用的 TileSet

const TILESET_NAME := "beach_tiles"
const ATLAS_PATH := "res://assets/tiles/beach_tiles.png"
const TILE_SIZE := Vector2i(16, 16)
const COLUMNS := 64
const ROWS := 64

enum TileCoord {
	SAND_PLAIN = 0,
	SAND_WET = 1,
	SHALLOW_WATER = 2,
	DEEP_WATER = 3,
	WATER_SURFACE = 4,
	SEASHELL = 5,
	STARFISH = 6,
	DRIFTWOOD = 7,
	BEACH_GRASS = 8,
	PIER_WOOD = 9,
	ROCK_POOL = 10,
	CORAL = 11,
	SEAWEED = 12,
	BEACH_PATH = 13,
	SANDCASTLE = 14,
	WATER_EDGE_SAND_L = 15,
	WATER_EDGE_SAND_R = 16,
	PEBBLES = 17,
	WATER_EDGE_SAND_T = 18,
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
