extends Node
class_name FestivalMinigame

## FestivalMinigame - 节日小游戏基类
## 所有节日小游戏都继承此类

# 信号
signal completed(score: int, success: bool)
signal cancelled

# 游戏状态
enum GameState { READY, PLAYING, PAUSED, ENDED }

var current_state: GameState = GameState.READY
var score: int = 0
var time_remaining: float = 60.0
var difficulty: int = 1  # 1-3

# 配置
@export var game_time: float = 60.0
@export var min_score_to_win: int = 100

# 内部 UI 元素
var _state_label: Label
var _score_change_label: Label


func _ready() -> void:
	time_remaining = game_time
	_setup_game()


func _process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		_update_game(delta)
		_update_timer(delta)
	elif current_state == GameState.PAUSED:
		_update_paused_ui()


## 设置游戏（子类重写）
func _setup_game() -> void:
	_create_base_ui()


## 更新游戏逻辑（子类重写）
func _update_game(_delta: float) -> void:
	pass


## 更新计时器
func _update_timer(delta: float) -> void:
	time_remaining -= delta

	if time_remaining <= 0:
		time_remaining = 0
		end_game()


## 开始游戏
func start_game() -> void:
	if current_state != GameState.READY:
		return

	current_state = GameState.PLAYING
	score = 0
	time_remaining = game_time

	_on_game_started()


## 暂停游戏
func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true
		_on_game_paused()


## 恢复游戏
func resume_game() -> void:
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false
		_on_game_resumed()


## 结束游戏
func end_game() -> void:
	current_state = GameState.ENDED

	var success := score >= min_score_to_win
	_on_game_ended(success)

	completed.emit(score, success)


## 取消游戏
func cancel_game() -> void:
	current_state = GameState.ENDED
	_on_game_cancelled()
	cancelled.emit()


## 增加分数
func add_score(points: int) -> void:
	score += points
	_on_score_changed(score)


## 设置难度
func set_difficulty(level: int) -> void:
	difficulty = clamp(level, 1, 3)
	_on_difficulty_changed(difficulty)


## 获取最终结果
func get_result() -> Dictionary:
	return {
		"score": score,
		"success": score >= min_score_to_win,
		"time_remaining": time_remaining,
		"difficulty": difficulty
	}


## 创建基础 UI（状态标签）
func _create_base_ui() -> void:
	_state_label = Label.new()
	_state_label.name = "StateLabel"
	_state_label.position = Vector2(20, 80)
	_state_label.text = "等待开始..."
	add_child(_state_label)

	_score_change_label = Label.new()
	_score_change_label.name = "ScoreChangeLabel"
	_score_change_label.position = Vector2(20, 110)
	_score_change_label.modulate = Color(1.0, 1.0, 0.0, 1.0)
	_score_change_label.text = ""
	add_child(_score_change_label)


## 更新暂停时的 UI
func _update_paused_ui() -> void:
	if _state_label:
		_state_label.text = "游戏已暂停"


## 游戏开始回调（子类重写）
func _on_game_started() -> void:
	if _state_label:
		_state_label.text = "游戏中... 目标: %d 分" % min_score_to_win


## 游戏暂停回调（子类重写）
func _on_game_paused() -> void:
	if _state_label:
		_state_label.text = "游戏已暂停"
		_create_pause_effect()


## 游戏恢复回调（子类重写）
func _on_game_resumed() -> void:
	if _state_label:
		_state_label.text = "继续游戏！"
		_fade_out_label(_state_label, 1.5)


## 游戏结束回调（子类重写）
func _on_game_ended(_success: bool) -> void:
	if _state_label:
		if _success:
			_state_label.text = "🎉 恭喜过关！最终得分: %d" % score
			_state_label.modulate = Color(0.2, 1.0, 0.2, 1.0)
		else:
			_state_label.text = "游戏结束！得分: %d（需要 %d）" % [score, min_score_to_win]
			_state_label.modulate = Color(1.0, 0.4, 0.4, 1.0)


## 游戏取消回调（子类重写）
func _on_game_cancelled() -> void:
	if _state_label:
		_state_label.text = "游戏已取消"
		_state_label.modulate = Color(0.7, 0.7, 0.7, 1.0)


## 分数变化回调（子类重写）
func _on_score_changed(_new_score: int) -> void:
	if _score_change_label:
		_score_change_label.text = "+%d" % _new_score
		_score_change_label.modulate = Color(1.0, 1.0, 0.0, 1.0)
		_fade_out_label(_score_change_label, 1.0)

	# 里程碑提示
	if _new_score >= 100 and _new_score < 500:
		_show_milestone("不错！")
	elif _new_score >= 500 and _new_score < 1000:
		_show_milestone("太棒了！")
	elif _new_score >= 1000:
		_show_milestone("完美！")


## 难度变化回调（子类重写）
func _on_difficulty_changed(_new_difficulty: int) -> void:
	if _state_label:
		var stars := ""
		for i in range(_new_difficulty):
			stars += "⭐"
		_state_label.text = "难度: %s" % stars
		_fade_out_label(_state_label, 2.0)


## 显示里程碑提示
func _show_milestone(text: String) -> void:
	var milestone := Label.new()
	milestone.name = "MilestoneLabel"
	milestone.position = Vector2(300, 200)
	milestone.text = text
	milestone.modulate = Color(1.0, 0.8, 0.0, 1.0)
	add_child(milestone)

	# 淡出动画
	var tween := create_tween()
	tween.tween_property(milestone, "modulate:a", 0.0, 1.5)
	await tween.finished
	milestone.queue_free()


## 标签淡出效果
func _fade_out_label(label: Label, duration: float) -> void:
	if not is_instance_valid(label):
		return
	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 0.5, duration)


## 创建暂停效果
func _create_pause_effect() -> void:
	var overlay := ColorRect.new()
	overlay.name = "PauseOverlay"
	overlay.color = Color(0.0, 0.0, 0.0, 0.3)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)