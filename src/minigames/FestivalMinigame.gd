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


func _ready() -> void:
	time_remaining = game_time
	_setup_game()


func _process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		_update_game(delta)
		_update_timer(delta)


## 设置游戏（子类重写）
func _setup_game() -> void:
	pass


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


## 游戏开始回调（子类重写）
func _on_game_started() -> void:
	pass


## 游戏暂停回调（子类重写）
func _on_game_paused() -> void:
	pass


## 游戏恢复回调（子类重写）
func _on_game_resumed() -> void:
	pass


## 游戏结束回调（子类重写）
func _on_game_ended(_success: bool) -> void:
	pass


## 游戏取消回调（子类重写）
func _on_game_cancelled() -> void:
	pass


## 分数变化回调（子类重写）
func _on_score_changed(_new_score: int) -> void:
	pass


## 难度变化回调（子类重写）
func _on_difficulty_changed(_new_difficulty: int) -> void:
	pass


## 获取最终结果
func get_result() -> Dictionary:
	return {
		"score": score,
		"success": score >= min_score_to_win,
		"time_remaining": time_remaining,
		"difficulty": difficulty
	}