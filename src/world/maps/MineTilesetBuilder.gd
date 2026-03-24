extends Node
class_name MineTilesetBuilder

## MineTilesetBuilder - 矿洞 TileSet 构建器
## 将 mine_tiles.png 图集（1024x1024, 16x16 tiles, 64x64 grid）转换为可用的 TileSet

const TILESET_NAME := "mine_tiles"
const ATLAS_PATH := "res://assets/tiles/mine_tiles.png"
const TILE_SIZE := Vector2i(16, 16)
const COLUMNS := 64
const ROWS := 64

enum TileCoord {
	STONE_FLOOR = 0,
	DIRT_FLOOR = 1,
	STONE_WALL = 2,
	CRACKED_WALL = 3,
	COPPER_ORE = 4,
	IRON_ORE = 5,
	GOLD_ORE = 6,
	COAL_ORE = 7,
	GEM_ORE = 8,
	LADDER_UP = 9,
	LADDER_DOWN = 10,
	TORCH_BRACKET = 11,
	WOOD_SUPPORT = 12,
	MINECART_TRACK = 13,
	RUBBLE = 14,
	CRACKED_FLOOR = 15,
	DARK_STONE = 16,
	GLOWING_ORE = 17,
}

const TILE_PROPERTIES := {
	TileCoord.STONE_FLOOR:   {"passable": true,  "layer": 0, "name": "石地板"},
	TileCoord.DIRT_FLOOR:     {"passable": true,  "layer": 0, "name": "泥地板"},
	TileCoord.STONE_WALL:      {"passable": false, "layer": 1, "name": "石墙"},
	TileCoord.CRACKED_WALL:    {"passable": false, "layer": 1, "name": "裂隙墙"},
	TileCoord.CRACKED_FLOOR:   {"passable": true,  "layer": 0, "name": "裂隙地板"},
	TileCoord.DARK_STONE:      {"passable": false, "layer": 1, "name": "黑曜石"},
	TileCoord.COPPER_ORE:     {"passable": false, "layer": 2, "name": "铜矿石"},
	TileCoord.IRON_ORE:        {"passable": false, "layer": 2, "name": "铁矿石"},
	TileCoord.GOLD_ORE:        {"passable": false, "layer": 2, "name": "金矿石"},
	TileCoord.COAL_ORE:        {"passable": false, "layer": 2, "name": "煤矿石"},
	TileCoord.GEM_ORE:         {"passable": false, "layer": 2, "name": "宝石矿石"},
	TileCoord.GLOWING_ORE:     {"passable": false, "layer": 2, "name": "发光矿石"},
	TileCoord.LADDER_UP:       {"passable": true,  "layer": 2, "name": "向上梯子"},
	TileCoord.LADDER_DOWN:     {"passable": true,  "layer": 2, "name": "向下梯子"},
	TileCoord.TORCH_BRACKET:   {"passable": false, "layer": 2, "name": "火把"},
	TileCoord.WOOD_SUPPORT:    {"passable": false, "layer": 2, "name": "木支撑"},
	TileCoord.MINECART_TRACK:  {"passable": true,  "layer": 0, "name": "矿车轨道"},
	TileCoord.RUBBLE:          {"passable": false, "layer": 1, "name": "碎石堆"},
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
