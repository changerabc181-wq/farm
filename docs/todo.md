# 📋 田园物语 - 开发任务规划（2026-03-24 修订版）

## ⚠️ 代码审查发现的问题

### 🔴 严重问题

1. **`Player.tscn` 引用了不存在的 `player_walk.png`**  
   - 新精灵为 `player_down/left/right/up.png`，需更新场景引用

2. **`assets/sprites/animals/` 完全空白** — AnimalSystem 代码已存在，但无动物精灵图
3. **`assets/sprites/portraits/` 完全空白** — NPC 头像数据已配置，但无图片
4. **`assets/sprites/ui/achievements/` 完全空白** — 16 个成就已注册，无成就图标
5. **`CookingSystem.gd` 第 245、290 行** — 烹饪时体力检查和消耗未实现

### 🟡 功能残缺（代码存在，需完善）

| 系统 | 文件 | 问题 |
|------|------|------|
| 烹饪 | CookingSystem.gd:245,290 | 体力检查和消耗 TODO |
| 对话 | DialogueManager.gd:197,205,337,342 | 体力检测、天气/任务/商店集成 TODO |
| 房屋 | PlayerHouse.gd:74,85; CarpenterNPC.gd:41 | 睡眠对话框、木匠菜单 TODO |
| 节日UI | FestivalUI.gd:253,259 | 对话框显示、错误对话框 TODO |
| 背包 | InventoryUI.gd:277 | 物品使用逻辑 TODO |
| 钓鱼 | FishingSpot.gd | 渔点交互 TODO |
| 工具 | FishingRod.gd | 鱼竿使用 TODO |
| NPC | NPCSchedule.gd | 日程 TODO |

---

## ✅ 已完成（审查确认）

- Phase 1-6 所有核心系统代码框架
- 节日数据（4个节日）、食谱（20个食谱）、作物（20种）、NPC（6个）
- 11 个数据文件 JSON 全部有效
- 集成测试通过

---

## 🔴 高优先级任务

### T1: 修复 `player_walk.png` 引用错误 ⚡ 快速
**文件**: `src/entities/player/Player.tscn`
**操作**: 将 `res://assets/sprites/characters/player_walk.png` 替换为新的 directional sprite paths
**验收**: Godot 启动无报错

### T2: 烹饪体力系统完善 🔥 核心
**文件**: `src/core/crafting/CookingSystem.gd`
**操作**: 实现第 245、290 行 TODO — 烹饪前检查体力、烹饪后扣减体力
**验收**: 体力不足时提示、足够时正常烹饪扣体力

### T3: 对话系统集成 🗣️ 核心
**文件**: `src/core/relationship/DialogueManager.gd`
**操作**: 实现第 197/205/337/342 行 TODO — 能量检测、天气/任务/商店集成
**验收**: 对话选项正确调用各子系统

### T4: 节日UI完善 🎪 核心
**文件**: `src/ui/festival/FestivalUI.gd`
**操作**: 实现第 253、259 行 TODO — 实际对话框显示
**验收**: 节日期间 UI 正确显示

### T5: 成就系统接入 🏆 UI连接
**文件**: `src/core/achievement/AchievementSystem.gd`
**操作**: 生成 16 个成就图标；接入成就通知 UI
**验收**: 达成条件时弹出成就通知

---

## 🟡 中优先级任务

### T6: 动物系统完善 🐄
**文件**: `src/entities/animals/Animal.gd`, `src/world/objects/AnimalBuilding.gd`
**依赖**: `assets/sprites/animals/`（需先生成精灵）
**操作**: 补全动物精灵图（鸡、奶牛、猪、羊），接入 Cooop/Barn 场景

### T7: NPC 头像系统 🖼️
**文件**: `data/npcs.json` portrait paths
**操作**: 生成 6 个 NPC 头像（portraits/）
**依赖**: MiniMax 图片生成（已可用）

### T8: 房屋睡眠系统 🛏️
**文件**: `src/world/maps/PlayerHouse.gd`, `src/entities/npc/CarpenterNPC.gd`
**操作**: 实现睡眠对话框（第 74、85 行）和木匠菜单（第 41 行）

### T9: 背包物品使用 🔧
**文件**: `src/ui/menus/InventoryUI.gd`
**操作**: 实现物品使用逻辑（第 277 行 TODO）

---

## 🟢 低优先级（可跳过）

### T10: 成就图标生成（16个）
**依赖**: MiniMax 图片 API

### T11: 动物精灵生成
**依赖**: MiniMax 图片 API

### T12: NPC 头像生成（6个）
**依赖**: MiniMax 图片 API

---

## ❌ 受限：需外部资源

以下任务等待 API/资源就绪后推进：

| 任务 | 阻塞原因 |
|------|----------|
| BGM 生成 | 需升级 MiniMax Max 套餐 |
| 地图瓦片接入 Godot | 需手动验证 |
| 角色精灵接入 Godot | 需手动验证 |
| 物品图标接入 Godot | 需手动验证 |

---

## 📊 当前进度（修订）

| Phase | 内容 | 状态 |
|-------|------|------|
| Phase 1 | 核心框架 | ✅ 100% |
| Phase 2 | 农场系统 | ✅ 100% |
| Phase 3 | 经济系统 | ✅ 100% |
| Phase 4 | 社交系统 | ✅ 100% |
| Phase 5 | 探索系统 | ✅ 100% |
| Phase 6 | 进阶功能 | 🔄 60% （代码框架完成，UI/集成未完成）|

---

## 📅 建议执行顺序

1. **立即** → T1（5分钟，解除报错）
2. **今日** → T2、T3、T4（核心功能完成）
3. **明日** → T5、T8、T9（UI/交互完善）
4. **资源就绪后** → T6、T7、T10-T12（批量生成精灵）

---

## 🗺️ 地图系统问题（补充审查）

### 🔴 核心问题：TileSet 尺寸完全不匹配

**`VillageTilesetBuilder.gd` 设计 vs 实际生成的图片：**

| 属性 | Builder 设计值 | 实际生成的 PNG |
|------|-------------|--------------|
| 瓦片尺寸 | **64×64** px | **16×16** px |
| 网格 | **5×5 = 25 tiles** | **8×8 = 64 tiles** |
| 图片总尺寸 | **320×320** px | **1024×1024** px |

→ **VillageBuilder 调用的 TileSet 会全部显示为空白**（因为读取的 atlas 区域完全错误）

**根本原因：** 生成的是 16×16 像素风格游戏瓦片（星露谷标准），Builder 代码用的是 64×64 设计。两者完全不兼容。

### 🟡 各地图状态

| 地图 | TileSet 状态 | Builder | 问题 |
|------|------------|--------|------|
| Village | 使用 Builder | ✅ 存在 | ❌ 尺寸不匹配 64px vs 16px |
| Farm | 空白 SubResource | ❌ 不存在 | ❌ 需要新建 Builder |
| Forest | 空 TileSet | ❌ 不存在 | ❌ 需要新建 Builder |
| Beach | 空白 SubResource | ❌ 不存在 | ❌ 需要新建 Builder |
| Mine | 空 TileSet | ❌ 不存在 | ❌ 需要新建 Builder |
| PlayerHouse | 空白 SubResource | ❌ 不存在 | ❌ 需要新建 Builder |

### ✅ Village NPC 头像问题（已发现）
- Village.tscn 引用 `npc_mayor.png` 等 5 个占位符（213 字节）
- 替换为新生成的 `portraits/mayor.png` 等即可

---

## 🗺️ 地图任务优先级

### T13: 修复 Village TileSet Builder 🔥 最高优先级
**文件**: `src/world/maps/VillageTilesetBuilder.gd`
**问题**: TILE_SIZE = 64 应该是 **16**，COLUMNS/ROWS = 5 应该是 **8**，ATLAS_PATH 正确
**操作**: 修改常量后 `VillageBuilder` 重新构建即可验证
**验收**: Village 地图有正确的地面、建筑瓦片显示

### T14: 创建 Farm TileSet Builder 🟡
**文件**: 需新建 `src/world/maps/FarmTilesetBuilder.gd`
**操作**: 参考 VillageTilesetBuilder 格式，创建使用 `farm_tiles.png` 的 Builder
**ATLAS**: `res://assets/tiles/farm_tiles.png`，TILE_SIZE = 16，8×8 网格

### T15: 创建 Forest TileSet Builder 🟡
**文件**: 需新建 `src/world/maps/ForestTilesetBuilder.gd`
**操作**: 使用 `forest_tiles.png`

### T16: 创建 Beach TileSet Builder 🟡
**文件**: 需新建 `src/world/maps/BeachTilesetBuilder.gd`
**操作**: 使用 `beach_tiles.png`

### T17: 创建 Mine TileSet Builder 🟡
**文件**: 需新建 `src/world/maps/MineTilesetBuilder.gd`
**操作**: 使用 `mine_tiles.png`

### T18: 创建 Indoor TileSet Builder 🟡
**文件**: 需新建 `src/world/maps/IndoorTilesetBuilder.gd`
**操作**: 使用 `indoors_tiles.png`，用于 PlayerHouse

### T19: Village NPC 头像替换 🟢
**操作**: 将 Village.tscn 中的 `npc_mayor.png` → `portraits/mayor.png` 等 5 个

### T20: Nature Elements 精灵接入 🟢
**文件**: `nature_elements.png`（橡树、松树、矿石等）
**操作**: 创建 NatureTilesetBuilder 接入 Forest/Beach 地图

---

## 📊 修复后的验证步骤

1. 启动 Godot，打开 Village.tscn
2. 确认地面瓦片（草地、道路）正确显示
3. 确认建筑墙体（石头墙、木板墙）正确显示
4. 确认装饰物（水井、长凳、栅栏）正确显示
5. 对其他地图重复上述验证

