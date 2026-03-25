# 田园物语 - 开发任务清单

> 更新时间：2026-03-25

## ✅ 已完成

### TileSet Builder 修正 (M1-M6)
- ✅ M1: VillageTileSize 修复
- ✅ M2: FarmTilesetBuilder tile ID（修正 WATER/FENCE/WOOD 等）
- ✅ M3: BeachTilesetBuilder tile ID（修正 WATER/SHELL/PIER 等）
- ✅ M4: ForestTilesetBuilder tile ID（修正 TREE/MUSHROOM/ROCK 等）
- ✅ M5: MineTilesetBuilder tile ID（修正 ORE/WOOD/GEM 等）
- ✅ M6: IndoorTilesetBuilder tile ID（修正 FLOOR/DOOR/BED 等）

### 核心玩法 (C1-C10)
- ✅ C1: Player精灵引用修复
- ✅ C2: 烹饪体力消耗系统
- ✅ C3: 对话系统（DialogueManager）
- ✅ C4: 节日 UI（FestivalSystem）
- ✅ C5: 睡眠系统存根
- ✅ C6: 木匠菜单（CarpenterNPC）
- ✅ C7: 背包物品使用（InventoryUI）
- ✅ C8: 钓鱼系统存根
- ✅ C9: 钓鱼小游戏（FishingTournamentMinigame）
- ✅ C10: NPC 日程（NPCSchedule）

### 资源生成 (S1-S4)
- ✅ S2: NPC头像（6个，64x64 PNG）
- ✅ S3: 动物精灵（5个，64x64 PNG）
- ✅ S4: 成就图标（15个，64x64 PNG）
- ⬜ S1: BGM（需 Max 套餐，¥1,990/年）

---

## 🚨 剩余待处理

### 🔴 高优先级（阻塞/影响核心体验）

**R1: WeatherSystem 未创建**
- NPCSchedule.gd:215 引用 WeatherSystem（天气条件检查）
- DialogueManager.gd:205 引用 WeatherSystem（对话影响）
- FishingRod.gd:151 默认晴天
- **需要实现**: 天气枚举(晴/雨/雪/风暴)、天气切换、天气对游戏行为的影响

**R2: FestivalSystem 未触发 Minigame**
- FestivalSystem.start_festival() 只发信号，不打开 minigame
- 4个 minigame 已完整实现（EggHunt/FishingTournament/PumpkinCarving/SnowballFight）
- **需要实现**: 节日时自动弹出 minigame 场景，整合到 FestivalSystem

**R3: SleepSystem 未创建**
- 睡眠系统存根，无实际功能
- **需要实现**: 睡眠恢复体力/能量、时间推进到第二天

**R4: FishingSystem 未创建**
- 钓鱼竿(FishingRod)存在但无钓鱼系统
- **需要实现**: 鱼种刷新逻辑、钓鱼成功判定、钓鱼小游戏入口

### 🟡 中优先级

**R5: FestivalMinigame 基类存根（9个 pass 回调）**
- `_on_game_started`, `_on_game_paused`, `_on_game_resumed`, `_on_game_ended`, `_on_game_cancelled`, `_on_score_changed`, `_on_difficulty_changed`
- 这些是可选回调，子类已实现，可忽略

**R6: NPCSchedule 天气条件存根（2个 pass）**
- `_check_special_conditions` 中的 weather check

**R7: NPCSchedule 扩展**
- 411行代码，基础结构完整
- 可扩展更多日程、更多NPC

**R8: 存档加载 UI（MainMenu.gd:176）**
- TODO: 显示加载存档界面
- TODO: 显示设置菜单

**R9: HouseUpgradeUI 消息显示（HouseUpgradeUI.gd:88）**
- TODO: 显示实际的消息UI

**R10: QuestSystem 经验系统（QuestSystem.gd:433）**
- TODO: 实现经验系统后添加

**R11: QuestSystem NPC数据库（QuestSystem.gd:567）**
- TODO: 实现NPC数据库后从数据库获取

---

## 📋 资源/内容清单

| 类别 | 内容 | 状态 |
|------|------|------|
| NPC头像 | 6个 | ✅ |
| 动物精灵 | 5个 | ✅ |
| 成就图标 | 15个 | ✅ |
| BGM | 待定 | ⬜ 需Max套餐 |
| 背景音乐 | 待定 | ⬜ 需Max套餐 |
| 音效 | 待定 | ⬜ |

## 测试状态

- Godot: 4.6.1 ✅
- 检查通过: 18/18 ✅
- 项目无脚本错误 ✅
