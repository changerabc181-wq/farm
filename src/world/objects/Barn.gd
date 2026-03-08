extends "res://src/world/objects/AnimalBuilding.gd"
class_name Barn

## Barn - 牛棚
## 专门用于饲养牛类动物的建筑

func _ready() -> void:
	building_name = "牛棚"
	building_type = "barn"
	max_animals = 4
	super._ready()

## 创建牛
func create_cow(cow_name: String = "") -> Cow:
	if is_full():
		print("[Barn] Cannot create cow, barn is full!")
		return null

	var cow_scene = preload("res://src/entities/animals/Cow.tscn")
	var cow: Cow = cow_scene.instantiate()

	if cow_name.is_empty():
		cow_name = "小牛%d" % (animals.size() + 1)

	cow.animal_name = cow_name
	cow.animal_id = "cow_%d" % Time.get_unix_time_from_system()

	add_animal(cow)
	return cow

## 获取所有牛奶
func get_milk_count() -> int:
	var count := 0
	for animal in animals:
		if animal is Cow and animal.has_product:
			count += 1
	return count