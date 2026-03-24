# 📋 田园物语 - 开发任务规划（2026-03-24 最终修订版）

---

## ⚠️ 代码审查完整问题清单

---

## 🔴 代码问题（必须修复）

### C1: Player.tscn — 精灵引用错误
**文件**: `src/entities/player/Player.tscn`
**问题**: 引用了不存在的 `res://assets/sprites/characters/player_walk.png`
**修复**: 替换为新的 directional sprites（`player_down/left/right/up.png`）

---

### C2: CookingSystem.gd — 烹饪体力未实现
**文件**: `src/core/crafting/CookingSystem.gd`
- 第 245 行: `TODO: 检查玩家体力是否足够`
- 第 290 行: `TODO: 减少玩家体力`
**影响**: 体力不足时仍可烹饪，体力无消耗

---

### C3: DialogueManager.gd — 4个集成未完成
**文件**: `src/core/relationship/DialogueManager.gd`
- 第 197 行: 玩家能量检测未实现
- 第 205 行: 天气系统集成未实现
- 第 337 行: 任务系统集成未实现
- 第 342 行: 商店系统集成未实现
**影响**: 对话选项无法调用天气/任务/商店

---

### C4: FestivalUI.gd — 节日对话框未实现
**文件**: `src/ui/festival/FestivalUI.gd`
- 第 253 行: 实际对话框显示 TODO
- 第 259 行: 错误对话框显示 TODO
**影响**: 节日 UI 点击无反应

---

### C5: PlayerHouse.gd — 睡眠系统未实现
**文件**: `src/world/maps/PlayerHouse.gd`
- 第 74 行: 显示睡眠对话框 TODO
- 第 85 行: 创建睡眠对话框 TODO
**影响**: 在家无法睡觉推进时间

---

### C6: CarpenterNPC.gd — 木匠菜单未实现
**文件**: `src/entities/npc/CarpenterNPC.gd`
- 第 41 行: 显示木匠菜单 TODO
**影响**: 房屋升级入口无法使用

---

### C7: InventoryUI.gd — 物品使用逻辑未实现
**文件**: `src/ui/menus/InventoryUI.gd`
- 第 277 行: 物品使用 TODO
**影响**: 背包选中物品后无法使用

---

### C8: FishingSpot.gd — 渔点交互提示未实现
**文件**: `src/world/objects/FishingSpot.gd`
- 第 41 行: 显示 UI 提示 TODO
**影响**: 钓鱼点无交互提示

---

### C9: FishingRod.gd — 鱼竿使用逻辑未完成
**文件**: `src/entities/tools/FishingRod.gd`
**影响**: 钓鱼功能流程不完整

---

### C10: NPCSchedule.gd — NPC日程系统待完善
**文件**: `src/entities/npc/NPCSchedule.gd`
**影响**: NPC 日常行为调度可能不完整

---

## 🗺️ 地图系统问题

### M1: Village TileSet Builder 尺寸写错 🔥 最优先
**文件**: `src/world/maps/VillageTilesetBuilder.gd`

| 属性 | 当前错误值 | 应改为 |
|------|-----------|--------|
| `TILE_SIZE` | `Vector2i(64, 64)` | `Vector2i(16, 16)` |
| `COLUMNS` | `5` | `8` |
| `ROWS` | `5` | `8` |

**影响**: Village 地图 TileSet 全空白
**验证**: 改完后 Godot 启动 Village.tscn 应看到地面和建筑瓦片

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

### S1: 角色精灵占位符（需替换）

| 文件（当前） | 实际大小 | 问题 |
|------------|---------|------|
| `npc_mayor.png` | 213B | 占位符 |
| `npc_doctor.png` | 213B | 占位符 |
| `npc_farmer.png` | 213B | 占位符 |
| `npc_blacksmith.png` | 213B | 占位符 |
| `npc_shopkeeper.png` | 213B | 占位符 |
| `player.png` | 420B | 占位符 |
| `npc_default.png` | 213B | 占位符 |

**修复**: 替换为新生成的 directional NPC sprites
**依赖**: 新精灵已生成（`mayor_down/left/right/up.png` 等）

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
**修复**: 生成 16 个成就图标（可用 nature_elements 风格）

---

## ✅ 已确认正常的部分

- 11 个 JSON 数据文件全部有效，无解析错误
- Phase 1-6 代码框架全部存在
- 集成测试 13/13 通过（2026-03-10）
- EventBus / AutoLoad 静态引用已修复
- 节日数据（4个）、食谱（20个）、作物（20种）数据完整
- 节日 JSON（4个）、鱼类（15+）、矿洞配置数据完整
- 成就系统代码存在，16个成就已注册

---

## 📊 执行优先级

### 第一梯队（立即可做，不依赖外部）

| # | 任务 | 预估 | 原因 |
|---|------|------|------|
| 1 | M1: VillageTileSize 改1行 | 5分钟 | 解除地图报错 |
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
| 15 | M2-M6 Builder 接入真实瓦片 | 精灵就绪后 |

---

## 受限任务（需外部资源）

| 任务 | 阻塞原因 |
|------|---------|
| BGM 生成 | 需 MiniMax Max 套餐（¥1,990/年） |
| 头像/动物/成就精灵生成 | MiniMax 图片 API（已可用，需等待额度刷新） |
| Godot 运行时验证 | 需本地启动 Godot 验证 |
