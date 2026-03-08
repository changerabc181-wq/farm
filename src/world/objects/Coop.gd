extends "res://src/world/objects/AnimalBuilding.gd"
class_name Coop

## Coop - 鸡舍
## 专门用于饲养鸡类动物的建筑

func _ready() -> void:
	building_name = "鸡舍"
	building_type = "coop"
	max_animals = 4
	super._ready()

## 创建鸡
func create_chicken(chicken_name: String = "") -> Chicken:
	if is_full():
		print("[Coop] Cannot create chicken, coop is full!")
		return null

	var chicken_scene = preload("res://src/entities/animals/Chicken.tscn")
	var chicken: Chicken = chicken_scene.instantiate()

	if chicken_name.is_empty():
		chicken_name = "小鸡%d" % (animals.size() + 1)

	chicken.animal_name = chicken_name
	chicken.animal_id = "chicken_%d" % Time.get_unix_time_from_system()

	add_animal(chicken)
	return chicken

## 获取所有鸡蛋
func get_egg_count() -> int:
	var count := 0
	for animal in animals:
		if animal is Chicken and animal.has_product:
			count += 1
	return count