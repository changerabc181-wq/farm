extends Node
class_name IndoorTilesetBuilder

## IndoorTilesetBuilder - 室内 TileSet 构建器
## indoors_tiles.png 分析结果（2026-03-25）：
## 木地板: atlas (1,0) = tile_id 1
## 石头地板: atlas (57,3) = tile_id 249
## 墙壁: atlas (18,0) = tile_id 18, (22,0) = tile_id 22 (蓝色壁纸)
## 门/桌子: atlas (44,1) = tile_id 108
## 壁炉: atlas (32,1) = tile_id 96
## 床: atlas (54,2) = tile_id 182

const TILESET_NAME := "indoors_tiles"
const ATLAS_PATH := "res://assets/tiles/indoors_tiles.png"
const TILE_SIZE := Vector2i(16, 16)
const COLUMNS := 64
const ROWS := 64

enum TileCoord {
	WOOD_FLOOR = 1,          # atlas (1,0) = tile_id 1 - 木地板
	WOOD_FLOOR_V2 = 1,       # atlas (1,0) = tile_id 1 - 木地板变体
	STONE_FLOOR = 249,       # atlas (57,3) = tile_id 249 - 石地板
	WALLPAPER_CREAM = 18,    # atlas (18,0) = tile_id 18 - 奶油色壁纸
	WALLPAPER_BLUE = 22,     # atlas (22,0) = tile_id 22 - 蓝色壁纸
	WOODEN_DOOR = 108,       # atlas (44,1) = tile_id 108 - 木门
	DOOR_OPEN = 108,         # atlas (44,1) = tile_id 108 - 开门状态
	WINDOW_LIGHT = 312,      # atlas (56,4) = tile_id 312 - 窗户
	STAIRS_UP = 439,         # atlas (55,6) = tile_id 439 - 楼梯向上
	FIREPLACE = 96,          # atlas (32,1) = tile_id 96 - 壁炉
	FIREPLACE_ACTIVE = 100,  # atlas (36,1) = tile_id 100 - 燃烧壁炉
	BED_SINGLE = 182,         # atlas (54,2) = tile_id 182 - 单人床
	BED_DOUBLE = 182,       # atlas (54,2) = tile_id 182 - 双人床
	TABLE = 108,            # atlas (44,1) = tile_id 108 - 桌子
	CHAIR = 108,            # atlas (44,1) = tile_id 108 - 椅子
	BOOKSHELF = 246,        # atlas (54,3) = tile_id 246 - 书架
	KITCHEN_COUNTER = 108,  # atlas (44,1) = tile_id 108 - 厨房台面
	STOVE = 743,            # atlas (39,11) = tile_id 743 - 炉子
	CHEST = 150,            # atlas (22,2) = tile_id 150 - 箱子
	RUG_OVAL = 96,          # atlas (32,1) = tile_id 96 - 椭圆形地毯
	PLANT_POT = 246,        # atlas (54,3) = tile_id 246 - 花盆
	LAMP = 106,              # atlas (42,1) = tile_id 106 - 灯
	CLOCK = 108,            # atlas (44,1) = tile_id 108 - 时钟
	CARPET_RED = 982,       # atlas (22,15) = tile_id 982 - 红色地毯
}

const TILE_PROPERTIES := {
	TileCoord.WOOD_FLOOR:       {"passable": true,  "layer": 0, "name": "木地板"},
	TileCoord.WOOD_FLOOR_V2:    {"passable": true,  "layer": 0, "name": "木地板"},
	TileCoord.STONE_FLOOR:      {"passable": true,  "layer": 0, "name": "石地板"},
	TileCoord.CARPET_RED:       {"passable": true,  "layer": 0, "name": "红色地毯"},
	TileCoord.RUG_OVAL:          {"passable": true,  "layer": 0, "name": "椭圆形地毯"},
	TileCoord.WALLPAPER_CREAM:  {"passable": false, "layer": 1, "name": "奶油色壁纸"},
	TileCoord.WALLPAPER_BLUE:   {"passable": false, "layer": 1, "name": "蓝色壁纸"},
	TileCoord.WOODEN_DOOR:       {"passable": false, "layer": 2, "name": "木门"},
	TileCoord.DOOR_OPEN:         {"passable": true,  "layer": 2, "name": "开着的门"},
	TileCoord.WINDOW_LIGHT:      {"passable": false, "layer": 1, "name": "窗户"},
	TileCoord.STAIRS_UP:         {"passable": true,  "layer": 0, "name": "楼梯"},
	TileCoord.FIREPLACE:          {"passable": false, "layer": 2, "name": "壁炉"},
	TileCoord.FIREPLACE_ACTIVE:  {"passable": false, "layer": 2, "name": "燃烧的壁炉"},
	TileCoord.BED_SINGLE:        {"passable": false, "layer": 2, "name": "单人床"},
	TileCoord.BED_DOUBLE:        {"passable": false, "layer": 2, "name": "双人床"},
	TileCoord.TABLE:             {"passable": false, "layer": 2, "name": "桌子"},
	TileCoord.CHAIR:             {"passable": true,  "layer": 2, "name": "椅子"},
	TileCoord.BOOKSHELF:         {"passable": false, "layer": 2, "name": "书架"},
	TileCoord.KITCHEN_COUNTER:   {"passable": false, "layer": 2, "name": "厨房台面"},
	TileCoord.STOVE:             {"passable": false, "layer": 2, "name": "炉子"},
	TileCoord.CHEST:             {"passable": false, "layer": 2, "name": "箱子"},
	TileCoord.PLANT_POT:         {"passable": false, "layer": 2, "name": "花盆"},
	TileCoord.LAMP:              {"passable": true,  "layer": 2, "name": "灯"},
	TileCoord.CLOCK:             {"passable": false, "layer": 2, "name": "时钟"},
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
