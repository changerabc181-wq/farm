# 田园物语 - 开发任务清单

> 更新时间：2026-03-25

## 最高优先（阻塞游戏运行）

- ✅ M1: VillageTileSize 修复
- ✅ C1: Player精灵引用修复
- ✅ C2-C10: 核心玩法集成（烹饪体力、对话系统、节日UI、睡眠系统等）

## 第一梯队（已完成 ✅）

- ✅ M2: FarmTilesetBuilder tile ID 修正
- ✅ M3: BeachTilesetBuilder tile ID 修正
- ✅ M4: ForestTilesetBuilder tile ID 修正
- ✅ M5: MineTilesetBuilder tile ID 修正
- ✅ M6: IndoorTilesetBuilder tile ID 修正
- ✅ S2: NPC头像（6个）- 已生成 64x64 PNG
- ✅ S3: 动物精灵（5个）- 已生成 64x64 PNG
- ✅ S4: 成就图标（15个）- 已生成 64x64 PNG

## 第二梯队（功能性增强）

- ⬜ FestivalMinigame: 需要实际 minigame 游戏循环实现
  - EggHuntMinigame: 找彩蛋逻辑
  - FishingTournamentMinigame: 钓鱼比赛
  - PumpkinCarvingMinigame: 南瓜雕刻
  - SnowballFightMinigame: 雪球大战
- ⬜ FestivalSystem: 节日时触发 minigame
- ⬜ WeatherSystem: 天气系统（影响鱼刷新等）

## 第三梯队（可延迟）

- ⬜ NPC好感度对话内容扩展
- ⬜ 更多食谱和烹饪组合
- ⬜ BGM生成（S1）- 需要 Max 套餐（¥1,990/年）

## 已知问题

- 音乐生成受限：MiniMax 音乐生成需 Max 套餐
- Godot 4.6.1 运行验证通过，无脚本错误

## MiniMax API 状态（2026-03-25）

- 图片生成：✅ 正常，额度充足
- 音乐生成：❌ 需 Max 套餐
