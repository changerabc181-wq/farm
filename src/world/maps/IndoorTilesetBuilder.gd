extends Node
class_name IndoorTilesetBuilder

## IndoorTilesetBuilder - 室内 TileSet 构建器
## 将 indoors_tiles.png 图集（1024x1024, 16x16 tiles, 64x64 grid）转换为可用的 TileSet

const TILESET_NAME := "indoors_tiles"
const ATLAS_PATH := "res://assets/tiles/indoors_tiles.png"
const TILE_SIZE := Vector2i(16, 16)
const COLUMNS := 64
const ROWS := 64

enum TileCoord {
	WOOD_FLOOR = 0,
	WOOD_FLOOR_V2 = 1,
	STONE_FLOOR = 2,
	CARPET_RED = 3,
	WALLPAPER_CREAM = 4,
	WALLPAPER_BLUE = 5,
	WOODEN_DOOR = 6,
	DOOR_OPEN = 7,
	WINDOW_LIGHT = 8,
	STAIRS_UP = 9,
	FIREPLACE = 10,
	FIREPLACE_ACTIVE = 11,
	BED_SINGLE = 12,
	BED_DOUBLE = 13,
	TABLE = 14,
	CHAIR = 15,
	BOOKSHELF = 16,
	KITCHEN_COUNTER = 17,
	STOVE = 18,
	CHEST = 19,
	RUG_OVAL = 20,
	PLANT_POT = 21,
	LAMP = 22,
	CLOCK = 23,
}

const TILE_PROPERTIES := {
	TileCoord.WOOD_FLOOR:     {"passable": true,  "layer": 0, "name": "木地板"},
	TileCoord.WOOD_FLOOR_V2:   {"passable": true,  "layer": 0, "name": "木地板v2"},
	TileCoord.STONE_FLOOR:     {"passable": true,  "layer": 0, "name": "石地板"},
	TileCoord.CARPET_RED:     {"passable": true,  "layer": 0, "name": "红地毯"},
	TileCoord.WALLPAPER_CREAM:{"passable": false, "layer": 1, "name": "奶油色墙纸"},
	TileCoord.WALLPAPER_BLUE: {"passable": false, "layer": 1, "name": "蓝色墙纸"},
	TileCoord.WOODEN_DOOR:    {"passable": false, "layer": 1, "name": "木门"},
	TileCoord.DOOR_OPEN:      {"passable": true,  "layer": 1, "name": "开的门"},
	TileCoord.WINDOW_LIGHT:   {"passable": false, "layer": 1, "name": "窗户"},
	TileCoord.STAIRS_UP:       {"passable": true,  "layer": 0, "name": "楼梯"},
	TileCoord.FIREPLACE:      {"passable": false, "layer": 2, "name": "壁炉"},
	TileCoord.FIREPLACE_ACTIVE:{"passable": false, "layer": 2, "name": "燃烧壁炉"},
	TileCoord.BED_SINGLE:     {"passable": false, "layer": 2, "name": "单人床"},
	TileCoord.BED_DOUBLE:     {"passable": false, "layer": 2, "name": "双人床"},
	TileCoord.TABLE:          {"passable": false, "layer": 2, "name": "桌子"},
	TileCoord.CHAIR:          {"passable": false, "layer": 2, "name": "椅子"},
	TileCoord.BOOKSHELF:      {"passable": false, "layer": 2, "name": "书架"},
	TileCoord.KITCHEN_COUNTER:{"passable": false, "layer": 2, "name": "厨房柜台"},
	TileCoord.STOVE:          {"passable": false, "layer": 2, "name": "炉灶"},
	TileCoord.CHEST:          {"passable": false, "layer": 2, "name": "箱子"},
	TileCoord.RUG_OVAL:      {"passable": true,  "layer": 0, "name": "椭圆形地毯"},
	TileCoord.PLANT_POT:    {"passable": false, "layer": 2, "name": "盆栽"},
	TileCoord.LAMP:          {"passable": false, "layer": 2, "name": "台灯"},
	TileCoord.CLOCK:         {"passable": false, "layer": 2, "name": "挂钟"},
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
