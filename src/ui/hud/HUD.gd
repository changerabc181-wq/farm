extends CanvasLayer
class_name HUD

## HUD - 游戏界面显示
## 显示时间、日期、体力、金钱等信息

# UI节点引用
@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeBox/TimeLabel
@onready var date_label: Label = $MarginContainer/VBoxContainer/TimeBox/DateLabel
@onready var stamina_bar: ProgressBar = $MarginContainer/VBoxContainer2/StaminaBar
@onready var stamina_label: Label = $MarginContainer/VBoxContainer2/StaminaLabel
@onready var money_label: Label = $MarginContainer/MoneyBox/MoneyLabel

func _ready() -> void:
	_connect_signals()
	_update_display()

func _connect_signals() -> void:
	if TimeManager:
		TimeManager.time_changed.connect(_on_time_changed)
		TimeManager.day_changed.connect(_on_day_changed)
	if GameManager:
		GameManager.stamina_changed.connect(_on_stamina_changed)
	if MoneySystem:
		MoneySystem.money_changed.connect(_on_money_changed)

func _update_display() -> void:
	_update_time_display()
	_update_stamina_display()
	_update_money_display()

func _update_time_display() -> void:
	if TimeManager:
		time_label.text = TimeManager.get_formatted_time()
		date_label.text = TimeManager.get_formatted_date()

func _update_stamina_display() -> void:
	if GameManager:
		stamina_bar.max_value = GameManager.max_stamina
		stamina_bar.value = GameManager.current_stamina
		stamina_label.text = str(int(GameManager.current_stamina)) + "/" + str(int(GameManager.max_stamina))

func _update_money_display() -> void:
	if MoneySystem:
		money_label.text = "$" + str(MoneySystem.get_money())

func _on_time_changed(_new_time: float) -> void:
	_update_time_display()

func _on_day_changed(_new_day: int) -> void:
	_update_time_display()

func _on_stamina_changed(_new_stamina: float) -> void:
	_update_stamina_display()

func _on_money_changed(_new_money: int, _delta: int) -> void:
	_update_money_display()
