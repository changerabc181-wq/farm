extends Node

## Core Unit Tests - 核心系统单元测试
## 使用公共 API 进行测试

var total_tests = 0
var passed_tests = 0
var failed_tests = 0

func _ready() -> void:
	print("==================================================")
	print("CORE UNIT TESTS - Pastoral Tales")
	print("==================================================")
	
	run_item_database_tests()
	run_inventory_tests()
	run_time_manager_tests()
	run_growth_system_tests()
	run_crafting_system_tests()
	
	print("==================================================")
	print("RESULTS: %d/%d passed" % [passed_tests, total_tests])
	print("==================================================")
	
	if failed_tests == 0:
		print("ALL TESTS PASSED!")
	else:
		print("FAILED: %d tests" % failed_tests)
	
	get_tree().quit()

func run_item_database_tests():
	print("\n[ItemDatabase Tests]")
	
	var db = ItemDatabase
	
	# Test: Database is loaded
	var item = db.get_item("turnip")
	assert_true(item != null, "Should get turnip item")
	
	# Test: Item properties
	assert_true(item.name == "芜菁", "Turnip name should be 芜菁")
	assert_true(item.type == ItemDatabase.ItemType.CROP, "Turnip should be CROP type")
	assert_true(item.sell_price > 0, "Turnip should have sell price")
	
	# Test: Get icon path
	var icon_path = db.get_icon_path("turnip")
	assert_true(icon_path != "", "Turnip should have icon path")
	
	# Test: Get multiple items
	var potato = db.get_item("potato")
	assert_true(potato != null, "Should get potato item")
	
	# Test: Get items by type
	var seeds = db.get_items_by_type(ItemDatabase.ItemType.SEED)
	assert_true(seeds.size() > 0, "Should have seed items")
	
	print("  ItemDatabase: All tests completed")

func run_inventory_tests():
	print("\n[Inventory Tests]")
	
	var inv = Inventory
	
	# Test: Add item (use actual item from database)
	inv.add_item("turnip", 5)
	
	# Test: Get item count
	assert_true(inv.get_item_count("turnip") == 5, "Should have 5 turnips")
	
	# Test: Has item
	assert_true(inv.has_item("turnip", 3), "Should have at least 3 turnips")
	assert_true(inv.has_item("turnip", 5), "Should have at least 5 turnips")
	assert_true(not inv.has_item("turnip", 100), "Should not have 100 turnips")
	
	# Test: Remove item
	inv.remove_item("turnip", 2)
	assert_true(inv.get_item_count("turnip") == 3, "Should have 3 turnips after removal")
	
	# Test: Add more
	inv.add_item("turnip", 10)
	assert_true(inv.get_item_count("turnip") == 13, "Should have 13 turnips after adding more")
	
	# Test: Remove all
	inv.remove_item("turnip", inv.get_item_count("turnip"))
	assert_true(inv.get_item_count("turnip") == 0, "Should have 0 turnips after removal")
	
	print("  Inventory: All tests completed")

func run_time_manager_tests():
	print("\n[TimeManager Tests]")
	
	var tm = TimeManager
	
	# Test: Get current time
	var time = tm.get_formatted_time()
	assert_true(time != "", "Should get formatted time")
	
	# Test: Get season
	var season = tm.get_season_name()
	assert_true(season == "Spring" or season == "Summer" or season == "Fall" or season == "Winter", 
		"Season should be valid")
	
	# Test: Day number
	var day = tm.current_day
	assert_true(day > 0, "Day should be positive")
	
	# Test: Time pause/resume
	tm.pause_time()
	var is_paused = tm.is_paused
	tm.resume_time()
	assert_true(is_paused and not tm.is_paused, "Pause/resume should work")
	
	print("  TimeManager: All tests completed")

func run_growth_system_tests():
	print("\n[GrowthSystem Tests]")
	
	var gs = GrowthSystem
	
	# Test: Get crop data
	var turnip = gs.get_crop_data("turnip")
	assert_true(turnip != null, "Should get turnip crop data")
	
	# Test: Crop data is a valid resource
	assert_true(turnip is Resource, "CropData should be a Resource")
	
	# Test: Get another crop
	var potato = gs.get_crop_data("potato")
	assert_true(potato != null, "Should get potato crop data")
	
	# Test: Get all crop IDs
	var crop_ids = gs.get_all_crop_ids()
	assert_true(crop_ids.size() > 0, "Should have crop IDs")
	
	print("  GrowthSystem: All tests completed")

func run_crafting_system_tests():
	print("\n[CraftingSystem Tests]")
	
	var cs = CraftingSystem
	
	# Test: Get recipe
	var fried_egg = cs.get_recipe("fried_egg")
	assert_true(fried_egg != null, "Should get fried_egg recipe")
	
	# Test: Recipe properties (Recipe extends RefCounted)
	assert_true(fried_egg.get("name") != "" or fried_egg.name != "", "Recipe should have name")
	assert_true(fried_egg.get("ingredients").size() > 0 or fried_egg.ingredients.size() > 0, "Recipe should have ingredients")
	
	# Test: Get result item
	assert_true(fried_egg.get("result_item") != "" or fried_egg.result_item != "", "Recipe should have result item")
	
	# Test: Get all recipes
	var all_recipes = cs.get_all_recipes()
	assert_true(all_recipes.size() > 0, "Should have recipes")
	
	print("  CraftingSystem: All tests completed")

func assert_true(condition: bool, message: String):
	total_tests += 1
	if condition:
		passed_tests += 1
		print("  [PASS] %s" % message)
	else:
		failed_tests += 1
		print("  [FAIL] %s" % message)
