# 📋 田园物语 - 开发任务规划（2026-03-24 最终修订版）

---

## ⚠️ 代码审查完整问题清单

---

## 🔴 代码问题（必须修复）

### C1: Player.tscn — 精灵引用错误 ✅ 已修复
**文件**: `src/entities/player/Player.tscn`
**问题**: 引用了不存在的 `res://assets/sprites/characters/player_walk.png`
**修复**: 替换为 `player_spritesheet.png`（由 player_down/left/right/up 组合），并创建 `player_spritesheet.png`
**提交**: `adb2d6d`

---

### C2: CookingSystem.gd — 烹饪体力未实现 ✅ 已修复
**文件**: `src/core/crafting/CookingSystem.gd`
- 第 245 行: 连接 GameManager 检查体力 ✅
- 第 290 行: 调用 GameManager.use_stamina() 消耗体力 ✅
- 提交: `e2e0818`
**文件**: `src/core/crafting/CookingSystem.gd`
- 第 245 行: `TODO: 检查玩家体力是否足够`
- 第 290 行: `TODO: 减少玩家体力`
**影响**: 体力不足时仍可烹饪，体力无消耗

---

### C3: DialogueManager.gd — 4个集成未完成 ✅ 已修复
**文件**: `src/core/relationship/DialogueManager.gd`
- 第 197 行: 玩家能量检测未实现
- 第 205 行: 天气系统集成未实现
- 第 337 行: 任务系统集成未实现
- 第 342 行: 商店系统集成未实现
**影响**: 对话选项无法调用天气/任务/商店

---

### C4: FestivalUI.gd — 节日对话框未实现 ✅ 已修复
**文件**: `src/ui/festival/FestivalUI.gd`
- 第 253 行: 实际对话框显示 TODO
- 第 259 行: 错误对话框显示 TODO
**影响**: 节日 UI 点击无反应

---

### C5: PlayerHouse.gd — 睡眠系统未实现 ✅ 已修复
**文件**: `src/world/maps/PlayerHouse.gd`
- 第 74 行: 显示睡眠对话框 TODO
- 第 85 行: 创建睡眠对话框 TODO
**影响**: 在家无法睡觉推进时间

---

### C6: CarpenterNPC.gd — 木匠菜单未实现 ✅ 已修复
**文件**: `src/entities/npc/CarpenterNPC.gd`
- 第 41 行: 显示木匠菜单 TODO
**影响**: 房屋升级入口无法使用

---

### C7: InventoryUI.gd — 物品使用逻辑未实现 ✅ 已修复
**文件**: `src/ui/menus/InventoryUI.gd`
- 第 277 行: 物品使用 TODO
**影响**: 背包选中物品后无法使用

---

### C8: FishingSpot.gd — 渔点交互提示未实现 ✅ 已修复
**文件**: `src/world/objects/FishingSpot.gd`
- 第 41 行: 显示 UI 提示 TODO
**影响**: 钓鱼点无交互提示

---

### C9: FishingRod.gd — 鱼竿使用逻辑未完成 ✅ 已修复
**文件**: `src/entities/tools/FishingRod.gd`
**影响**: 钓鱼功能流程不完整

---

### C10: NPCSchedule.gd — NPC日程系统待完善 ✅ 已修复
**文件**: `src/entities/npc/NPCSchedule.gd`
**影响**: NPC 日常行为调度可能不完整

---

## 🗺️ 地图系统问题

### M1: Village TileSet Builder 尺寸写错 ✅ 已修复
**文件**: `src/world/maps/VillageTilesetBuilder.gd`

| 属性 | 旧值 | 新值 |
|------|------|------|
| `TILE_SIZE` | `Vector2i(64, 64)` | `Vector2i(16, 16)` ✅ |
| `COLUMNS` | `5` | `8` ✅ |
| `ROWS` | `5` | `8` ✅ |

**验证**: 改完后 Godot 启动 Village.tscn 应看到地面和建筑瓦片
**提交**: `adb2d6d`

---

### M2-M6: 其余5个地图没有 TileSet Builder

| 地图 | Builder 文件 | 使用图集 |
|------|------------|---------|
| M2: Farm | 需新建 `FarmTilesetBuilder.gd` | `farm_tiles.png` |
| M3: Forest | 需新建 `ForestTilesetBuilder.gd` | `forest_tiles.png` |
| M4: Beach | 需新建 `BeachTilesetBuilder.gd` | `beach_tiles.png` |
| M5: Mine | 需新建 `MineTilesetBuilder.gd` | `mine_tiles.png` |
| M6: PlayerHouse | 需新建 `IndoorTilesetBuilder.gd` | `indoors_tiles.png` |

每个 Builder 参考 `VillageTilesetBuilder.gd` 格式创建，使用正确瓦片尺寸 `16×16`。

---

## 🖼️ 精灵资源问题

### S1: 角色精灵占位符 ✅ 部分完成
玩家方向精灵已修复（player_spritesheet.png）。NPC 占位符待替换（mayor/farmer/shopkeeper/blacksmith/doctor/down.png → 新生成 directional sprites）

---

### S2: sprites/portraits/ 完全空白
**目录**: `assets/sprites/portraits/`
**问题**: NPC 头像数据在 `npcs.json` 中有配置，但无图片文件
**影响**: NPC 对话无头像显示
**修复**: 生成 6 个 NPC 头像（portraits/mayor.png 等）

---

### S3: sprites/animals/ 完全空白
**目录**: `assets/sprites/animals/`
**问题**: `Animal.gd` 和 `AnimalBuilding.gd` 代码存在，但无动物精灵
**影响**: 鸡舍/牛棚无动物显示
**需要**: 鸡、奶牛、猪、羊的精灵图

---

### S4: sprites/ui/achievements/ 完全空白
**目录**: `assets/sprites/ui/achievements/`
**问题**: 16 个成就已注册，无成就图标
**影响**: 成就解锁无图标显示
**修复**: 生成 16 个成就图标

---

## ✅ 已确认正常的部分

- **Godot 运行时验证通过**（2026-03-24）— 无脚本错误
- 11 个 JSON 数据文件全部有效，无解析错误
- Phase 1-6 代码框架全部存在
- 集成测试通过（2026-03-10）
- EventBus / AutoLoad 静态引用已修复
- 节日数据（4个）、食谱（20个）、作物（20种）数据完整
- 节日 JSON（4个）、鱼类（15+）、矿洞配置数据完整
- 成就系统代码存在，16个成就已注册
- Godot 4.6.1 已安装：`/home/admin/tools/bin/godot`

---

## 📊 Godot 运行时验证（2026-03-24）

运行 `/home/admin/tools/bin/godot --headless --path .` 结果：

```
✅ GameManager Initialized
✅ TimeManager Initialized (6:00 AM)
✅ SaveManager Initialized
✅ EventBus Initialized
✅ AudioManager Initialized
✅ InputManager Initialized
✅ MoneySystem Initialized ($500)
✅ ShippingSystem Initialized
✅ SceneTransition Initialized
✅ ItemDatabase Loaded (121 items)
✅ GrowthSystem Initialized (20 crop types)
✅ GiftSystem Initialized
✅ ForagingSystem Initialized (17 forage types)
✅ QuestSystem Loaded (15 quests)
✅ PlantingManager Registered seeds
✅ NPCManager Loaded (6 NPCs)
✅ HouseUpgradeSystem Initialized
✅ FurnitureDatabase Loaded (14 furniture)
✅ FestivalSystem Initialized (春花祭)
✅ AchievementSystem Initialized (15 achievements)
✅ No script errors
✅ Exit code 0
```

---

## 📊 执行优先级

### 第一梯队（立即可做，不依赖外部）

| # | 任务 | 预估 | 原因 |
|---|------|------|------|
| 1 | M1: VillageTileSize 改3常量 | 5分钟 | 解除地图报错 |
| 2 | C1: player_walk.png 引用 | 5分钟 | 解除精灵报错 |
| 3 | C2: 烹饪体力系统 | 30分钟 | 核心玩法 |
| 4 | C3: 对话系统集成 | 1小时 | 核心玩法 |
| 5 | C4: 节日UI对话框 | 30分钟 | 核心玩法 |
| 6 | C5: 睡眠系统 | 30分钟 | 核心玩法 |

### 第二梯队（可做，稍后推进）

| # | 任务 | 预估 |
|---|------|------|
| 7 | C6: 木匠菜单 | 30分钟 |
| 8 | C7: 背包物品使用 | 1小时 |
| 9 | C8-C10: 钓鱼/日程 | 1-2小时 |
| 10 | M2-M6: 5个地图 Builder | 各30分钟 |

### 第三梯队（需生成资源）

| # | 任务 | 依赖 |
|---|------|------|
| 11 | S1: NPC精灵替换 | 新精灵已就绪 |
| 12 | S2: 头像生成（6个） | MiniMax图片API |
| 13 | S3: 动物精灵生成 | MiniMax图片API |
| 14 | S4: 成就图标（16个） | MiniMax图片API |

---

## 受限任务（需外部资源）

| 任务 | 阻塞原因 |
|------|---------|
| BGM 生成 | 需 MiniMax Max 套餐（¥1,990/年） |
| 头像/动物/成就精灵生成 | MiniMax 图片 API 额度已恢复 |
| Godot 运行时画面验证 | 需有显示器或 VNC |

---

## 代码审查发现的问题
### 🔴 严重（阻断）
- Farm.tscn 没有 TileMap 节点，无法渲染农场地面 → `src/world/maps/Farm.tscn`（需新建 FarmTilesetBuilder.gd 并在 Farm.tscn 中添加 TileMap 子节点，参见 todo M2）
- `start_game()` 不会初始化玩家到 Farm 场景 → `src/autoload/GameManager.gd:46`（函数体仅设置状态和发信号，未调用 `SceneTransition.change_scene_to_file()` 加载 Farm 场景）

### 🟡 中等
- FestivalMinigame.gd 有 9 个未实现的空函数（仅 `pass`）→ `src/minigames/FestivalMinigame.gd:37,42,113,118,123,128,133,138,143`
- DialogueManager.gd 有 2 个未实现的空函数（仅 `pass`）→ `src/core/relationship/DialogueManager.gd:422,426`
- NPC.gd 有 2 个未实现的空函数（仅 `pass`）→ `src/entities/npc/NPC.gd:218,367`
- Player.gd 有 2 个未实现的空函数（仅 `pass`）→ `src/entities/player/Player.gd:229,233`
- NPCSchedule.gd 有 1 个未实现的空函数（仅 `pass`）→ `src/entities/npc/NPCSchedule.gd:216`
- Barn.gd 有 1 个未实现的空函数（仅 `pass`）→ `src/world/objects/Barn.gd:27`
- Kitchen.gd 有 1 个未实现的空函数（仅 `pass`）→ `src/world/objects/Kitchen.gd:36`
- Coop.gd 有 2 个未实现的空函数（仅 `pass`）→ `src/world/objects/Coop.gd:27,31`
- PlayerHouse.gd 有 1 个未实现的空函数（仅 `pass`）→ `src/world/maps/PlayerHouse.gd:126`
- Forest.gd 有 1 个未实现的空函数（仅 `pass`）→ `src/world/maps/Forest.gd:130`
- DamageNumber.gd 有 1 个未实现的空函数（仅 `pass`）→ `src/ui/effects/DamageNumber.gd:24`
- FestivalUI.gd 有 1 个未实现的空函数（仅 `pass`）→ `src/ui/festival/FestivalUI.gd:189`
- QuestSystem.gd 有 2 处 TODO 注释（经验系统、NPC数据库） → `src/core/quest/QuestSystem.gd:433,567`
- MainMenu.gd 有 2 处 TODO 注释（加载存档界面、设置菜单） → `src/ui/menus/MainMenu.gd:176,185`
- HouseUpgradeUI.gd 有 1 处 TODO 注释（消息UI） → `src/ui/menus/HouseUpgradeUI.gd:88`

### 🟢 轻微
- `assets/sprites/animals/` 下 5 个动物精灵文件均为占位符（562~566 字节，< 5KB） → `assets/sprites/animals/`（已在 todo S3 记录）
- NPC 精灵 `npc_default.png` 引用正确但为通用占位符，6 个具名 NPC 精灵（mayor/farmer_joe 等）已存在
- check.sh 18/18 全部通过，ExtResource 引用路径全部正确（无 ExtResource 指向不存在的文件）

**审查时间**: 2026-03-24
