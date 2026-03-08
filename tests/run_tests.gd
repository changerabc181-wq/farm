extends SceneTree

## Test Runner - 测试运行器
## 运行所有单元测试

func _init() -> void:
	print("=" * 50)
	print("🧪 田园物语 - 单元测试")
	print("=" * 50)
	
	var results = {
		"total": 0,
		"passed": 0,
		"failed": 0
	}
	
	# 运行时间管理器测试
	print("\n📅 测试 TimeManager...")
	results = _run_time_manager_tests(results)
	
	# 运行背包系统测试
	print("\n🎒 测试 Inventory...")
	results = _run_inventory_tests(results)
	
	# 运行烹饪系统测试
	print("\n🍳 测试 CookingSystem...")
	results = _run_cooking_tests(results)
	
	# 输出结果
	print("\n" + "=" * 50)
	print("📊 测试结果")
	print("=" * 50)
	print("总计: %d" % results.total)
	print("通过: %d ✅" % results.passed)
	print("失败: %d ❌" % results.failed)
	print("=" * 50)
	
	if results.failed == 0:
		print("🎉 所有测试通过!")
	else:
		print("⚠️ 有测试失败，请检查")
	
	quit()

func _run_time_manager_tests(results: Dictionary) -> Dictionary:
	var tests = [
		{"name": "初始时间", "func": _test_time_initial},
		{"name": "时间格式化", "func": _test_time_formatting},
		{"name": "季节名称", "func": _test_season_names},
		{"name": "暂停恢复", "func": _test_pause_resume}
	]
	
	for test in tests:
		results.total += 1
		var success = test.func.call()
		if success:
			results.passed += 1
			print("  ✅ %s" % test.name)
		else:
			results.failed += 1
			print("  ❌ %s" % test.name)
	
	return results

func _run_inventory_tests(results: Dictionary) -> Dictionary:
	var tests = [
		{"name": "初始状态", "func": _test_inventory_initial},
		{"name": "添加物品", "func": _test_inventory_add},
		{"name": "移除物品", "func": _test_inventory_remove},
		{"name": "检查物品", "func": _test_inventory_has}
	]
	
	for test in tests:
		results.total += 1
		var success = test.func.call()
		if success:
			results.passed += 1
			print("  ✅ %s" % test.name)
		else:
			results.failed += 1
			print("  ❌ %s" % test.name)
	
	return results

func _run_cooking_tests(results: Dictionary) -> Dictionary:
	var tests = [
		{"name": "加载配方", "func": _test_cooking_load},
		{"name": "学习配方", "func": _test_cooking_learn},
		{"name": "获取配方", "func": _test_cooking_get}
	]
	
	for test in tests:
		results.total += 1
		var success = test.func.call()
		if success:
			results.passed += 1
			print("  ✅ %s" % test.name)
		else:
			results.failed += 1
			print("  ❌ %s" % test.name)
	
	return results

# TimeManager 测试函数
func _test_time_initial() -> bool:
	var tm = TimeManager.new()
	return tm.current_time == 6.0 and tm.current_day == 1

func _test_time_formatting() -> bool:
	var tm = TimeManager.new()
	var formatted = tm.get_formatted_time()
	return formatted != ""

func _test_season_names() -> bool:
	var tm = TimeManager.new()
	return tm.get_season_name() == "Spring"

func _test_pause_resume() -> bool:
	var tm = TimeManager.new()
	tm.pause_time()
	var paused = tm.is_paused
	tm.resume_time()
	return paused and not tm.is_paused

# Inventory 测试函数
func _test_inventory_initial() -> bool:
	var inv = Inventory.new()
	inv._initialize_slots()
	return inv.get_empty_slot_count() == 36

func _test_inventory_add() -> bool:
	var inv = Inventory.new()
	inv._initialize_slots()
	var result = inv.add_item("turnip", 5)
	return result and inv.get_item_count("turnip") == 5

func _test_inventory_remove() -> bool:
	var inv = Inventory.new()
	inv._initialize_slots()
	inv.add_item("turnip", 10)
	var result = inv.remove_item("turnip", 3)
	return result and inv.get_item_count("turnip") == 7

func _test_inventory_has() -> bool:
	var inv = Inventory.new()
	inv._initialize_slots()
	inv.add_item("turnip", 5)
	return inv.has_item("turnip", 3) and not inv.has_item("turnip", 10)

# CookingSystem 测试函数
func _test_cooking_load() -> bool:
	var cs = CookingSystem.new()
	cs._create_default_recipes()
	return cs.get_all_recipes().size() > 0

func _test_cooking_learn() -> bool:
	var cs = CookingSystem.new()
	cs._create_default_recipes()
	var result = cs.learn_recipe("fried_egg")
	return result and cs.is_recipe_learned("fried_egg")

func _test_cooking_get() -> bool:
	var cs = CookingSystem.new()
	cs._create_default_recipes()
	var recipe = cs.get_recipe("fried_egg")
	return recipe != null and recipe.name == "煎蛋"
