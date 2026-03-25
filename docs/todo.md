# 田园物语 - 开发任务清单

> 更新时间：2026-03-25

## ✅ 已完成（本次会话）

### 高优先级 R1-R4
- ✅ R1: **WeatherSystem** - 新 Autoload（21个系统之一）
  - 基于 SeasonSystem 权重生成每日天气（晴/多云/雨/暴风雨/雪）
  - 接入 TimeManager.day_changed，每日自动刷新天气
  - 提供 get_current_weather()、get_growth_bonus()、get_fishing_bonus()
  - 天气视觉效果框架（雨/风暴/雪粒子节点）
  - 修复 SeasonSystem 缺 class_name（与 Autoload 冲突）

- ✅ R2: **FestivalSystem Minigame 集成**
  - 添加 mini_game → 类脚本映射（egg_hunt/fishing_tournament/pumpkin_carving/snowball_fight）
  - start_festival() 自动打开对应 Minigame
  - Minigame 完成/取消回调，更新节日分数
  - 修复 EGG_SCENE/SNOWBALL_SCENE preload（缺失 .tscn）
  - 修复 PumpkinCarvingMinigame has_eyes 类型推断

- ✅ R3: **SleepSystem** - 新 Autoload
  - sleep() 推进到第二天（TimeManager.advance_day）
  - 体力恢复机制（100点）
  - can_sleep() 白天禁止睡觉检查
  - 信号通知（sleep_started/sleep_ended）

- ✅ R4: **FishingSystem** - 新 Autoload
  - 跟踪 total_fish_caught、按地点统计、历史记录
  - record_catch() 记录每次钓鱼（含时间戳）
  - 钓鱼成就检查（first_fish, fisherman）
  - Session 跟踪（开始/结束）
  - 存档支持

### TileSet/资源（本次会话）
- ✅ M2-M6: 修正所有 tileset tile ID（Farm/Beach/Forest/Mine/Indoor）
- ✅ S2: NPC头像 6个（64x64 PNG）
- ✅ S3: 动物精灵 5个（64x64 PNG）
- ✅ S4: 成就图标 15个（64x64 PNG）

---

## 🟡 剩余任务

### 中优先级
- ⬜ R5: FestivalMinigame 基类 9个 pass 回调（低影响）
- ⬜ R6: NPCSchedule 天气条件存根（WeatherSystem 已实现可接入）
- ⬜ R7: NPCSchedule 扩展更多日程
- ⬜ R8: MainMenu 存档加载/设置菜单
- ⬜ R9: HouseUpgradeUI 消息显示
- ⬜ R10: QuestSystem 经验系统
- ⬜ R11: QuestSystem NPC数据库集成

### 缺失场景资源
- ⬜ Egg.tscn（EggHuntMinigame 引用，preload 改为 null）
- ⬜ Snowball.tscn（SnowballFightMinigame 引用，preload 改为 null）
- ⬜ FestivalMinigame 基类存根（9个 pass 回调可选）

### 内容/资源
- ⬜ S1: BGM（需 Max 套餐 ¥1,990/年）

---

## 📊 测试状态

- ✅ 18/18 检查通过
- ✅ 21 个系统初始化（新增 Season/Weather/Sleep/FishingSystem）
- ✅ Godot 4.6.1 无脚本错误
- ⏳ Git push 等待网络恢复（3个 commits 待推送）
