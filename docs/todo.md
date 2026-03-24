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
