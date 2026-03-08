extends Control
class_name TimeDisplay

## TimeDisplay - 时间显示UI组件
## 显示当前游戏时间和日期

@onready var time_label: Label = $TimeLabel
@onready var date_label: Label = $DateLabel

func _ready() -> void:
	_connect_signals()
	_update_display()

func _connect_signals() -> void:
	if TimeManager:
		TimeManager.time_changed.connect(_on_time_changed)
		TimeManager.day_changed.connect(_on_day_changed)
		TimeManager.season_changed.connect(_on_season_changed)
		TimeManager.year_changed.connect(_on_year_changed)

func _on_time_changed(_new_time: float) -> void:
	_update_time_display()

func _on_day_changed(_new_day: int) -> void:
	_update_date_display()

func _on_season_changed(_new_season: int, _season_name: String) -> void:
	_update_date_display()

func _on_year_changed(_new_year: int) -> void:
	_update_date_display()

func _update_display() -> void:
	_update_time_display()
	_update_date_display()

func _update_time_display() -> void:
	if time_label and TimeManager:
		time_label.text = TimeManager.get_formatted_time()

func _update_date_display() -> void:
	if date_label and TimeManager:
		date_label.text = TimeManager.get_formatted_date()
