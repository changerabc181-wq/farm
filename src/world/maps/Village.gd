extends Node2D
class_name Village

## Village - 村庄场景
## 玩家与NPC交互、购物的主要场所

@onready var tile_map: TileMap = $TileMap
@onready var player_spawn: Marker2D = $PlayerSpawn

# 场景切换目标
const FARM_SCENE = "res://src/world/maps/Farm.tscn"

# NPC管理器
var npc_manager: NPCManager = null

func _ready() -> void:
	print("[Village] Scene loaded")
	_setup_tilemap()
	_setup_npc_manager()
	_setup_ui()
	_connect_transition_areas()

func _setup_tilemap() -> void:
	if tile_map.tile_set == null:
		var tile_set: TileSet = TileSet.new()
		tile_map.tile_set = tile_set
	print("[Village] TileMap setup complete")

func _setup_npc_manager() -> void:
	npc_manager = NPCManager.new()
	npc_manager.name = "NPCManager"
	add_child(npc_manager)
	npc_manager.set_current_scene(self)
	print("[Village] NPC Manager initialized")

func _setup_ui() -> void:
	# 创建UI画布层
	var ui_canvas = CanvasLayer.new()
	ui_canvas.layer = 10
	add_child(ui_canvas)
	
	# 添加时间显示
	var time_display = preload("res://src/ui/hud/TimeDisplay.tscn").instantiate()
	ui_canvas.add_child(time_display)
	print("[Village] UI setup complete")

func _connect_transition_areas() -> void:
	var to_farm_area = $TransitionAreas/ToFarmArea
	if to_farm_area:
		to_farm_area.body_entered.connect(_on_to_farm_area_body_entered)

func _on_to_farm_area_body_entered(body: Node2D) -> void:
	if body is Player:
		SceneTransition.transition_to(FARM_SCENE)

func get_player_spawn_position() -> Vector2:
	return player_spawn.global_position
