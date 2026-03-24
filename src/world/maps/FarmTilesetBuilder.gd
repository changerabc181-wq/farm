extends Node
class_name FarmTilesetBuilder

## FarmTilesetBuilder - 农场 TileSet 构建器
## 将 farm_tiles.png 图集（1024x1024, 16x16 tiles, 64x64 grid）转换为可用的 TileSet

const TILESET_NAME := "farm_tiles"
const ATLAS_PATH := "res://assets/tiles/farm_tiles.png"
const TILE_SIZE := Vector2i(16, 16)
const COLUMNS := 64
const ROWS := 64

enum TileCoord {
	GRASS_PLAIN = 0,
	WATER_POND = 1,
	PATH_DIRT = 2,
	PATH_GRASS = 3,
	TILLED_SOIL = 4,
	GROWING_CROPS = 5,
	MATURE_CROPS = 6,
	FENCE_H = 7,
	FENCE_V = 8,
	FENCE_POST = 9,
	GATE_OPEN = 10,
	GATE_CLOSED = 11,
	STONE_WALL = 12,
	WOOD_WALL = 13,
	WELL = 14,
	SCARECROW = 15,
	FLOWER_PATCH = 16,
	RAISED_BED = 17,
	DENSE_CROPS = 18,
	WOOD_PLANKS = 19,
	HAYSTACK = 20,
	GRASS_2 = 21,
	WATER_EDGE_TL = 22,
	WATER_EDGE_TR = 23,
	WATER_EDGE_BL = 24,
	WATER_EDGE_BR = 25,
	FERTILE_SOIL = 26,
}

const TILE_PROPERTIES := {
	TileCoord.GRASS_PLAIN:    {"passable": true,  "layer": 0, "name": "草地"},
	TileCoord.GRASS_2:         {"passable": true,  "layer": 0, "name": "草地2"},
	TileCoord.PATH_DIRT:       {"passable": true,  "layer": 0, "name": "泥路"},
	TileCoord.PATH_GRASS:      {"passable": true,  "layer": 0, "name": "草地路"},
	TileCoord.TILLED_SOIL:     {"passable": true,  "layer": 0, "name": "耕地"},
	TileCoord.FERTILE_SOIL:    {"passable": true,  "layer": 0, "name": "肥沃土壤"},
	TileCoord.GROWING_CROPS:   {"passable": true,  "layer": 0, "name": "生长中作物"},
	TileCoord.MATURE_CROPS:    {"passable": true,  "layer": 0, "name": "成熟作物"},
	TileCoord.DENSE_CROPS:     {"passable": true,  "layer": 0, "name": "密植作物"},
	TileCoord.WATER_POND:      {"passable": false, "layer": 1, "name": "池塘"},
	TileCoord.WATER_EDGE_TL:   {"passable": false, "layer": 1, "name": "水边上"},
	TileCoord.WATER_EDGE_TR:   {"passable": false, "layer": 1, "name": "水边上"},
	TileCoord.WATER_EDGE_BL:   {"passable": false, "layer": 1, "name": "水边下"},
	TileCoord.WATER_EDGE_BR:   {"passable": false, "layer": 1, "name": "水边下"},
	TileCoord.STONE_WALL:       {"passable": false, "layer": 1, "name": "石墙"},
	TileCoord.WOOD_WALL:        {"passable": false, "layer": 1, "name": "木墙"},
	TileCoord.FENCE_H:          {"passable": false, "layer": 2, "name": "水平栅栏"},
	TileCoord.FENCE_V:          {"passable": false, "layer": 2, "name": "垂直栅栏"},
	TileCoord.FENCE_POST:       {"passable": false, "layer": 2, "name": "栅栏柱"},
	TileCoord.GATE_OPEN:        {"passable": true,  "layer": 2, "name": "开的门"},
	TileCoord.GATE_CLOSED:      {"passable": false, "layer": 2, "name": "关的门"},
	TileCoord.WELL:             {"passable": false, "layer": 2, "name": "水井"},
	TileCoord.SCARECROW:        {"passable": false, "layer": 2, "name": "稻草人"},
	TileCoord.FLOWER_PATCH:     {"passable": true,  "layer": 2, "name": "花坛"},
	TileCoord.RAISED_BED:       {"passable": false, "layer": 2, "name": "苗圃"},
	TileCoord.WOOD_PLANKS:      {"passable": true,  "layer": 0, "name": "木板地"},
	TileCoord.HAYSTACK:         {"passable": false, "layer": 2, "name": "草堆"},
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
		var coords := get_coord(tile_id)
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
