extends Node2D

## Master Test Runner
## Runs all module tests in sequence

var current_test = 0
var tests = [
	{
		"name": "C++ Extension Loading & Item Generation",
		"scene": "res://tests/test_cpp_extension.tscn",
		"wait_time": 10.0
	},
	{
		"name": "Random Roll Module (Noah's Module)",
		"scene": "res://tests/test_roll_module.tscn",
		"wait_time": 2.0
	},
	{
		"name": "Emotion Dialog Module (Alexandra's Module)",
		"scene": "res://tests/test_dialog_module.tscn",
		"wait_time": 15.0
	}
]

func _ready():
	print("\n")
	print("╔═══════════════════════════════════════════════════════════════╗")
	print("║          NECRONOMICORE TEST SUITE - MASTER RUNNER            ║")
	print("╚═══════════════════════════════════════════════════════════════╝")
	print("\nRunning ", tests.size(), " test modules...\n")
	
	# Check for API key
	if not FileAccess.file_exists("res://api_config.json"):
		print("❌ ERROR: api_config.json not found!")
		print("Please copy api_config.json.example to api_config.json")
		print("and add your OpenAI API key.\n")
		return
	
	run_next_test()

func run_next_test():
	if current_test >= tests.size():
		print("\n")
		print("╔═══════════════════════════════════════════════════════════════╗")
		print("║                   ALL TESTS COMPLETED!                        ║")
		print("╚═══════════════════════════════════════════════════════════════╝")
		print("\nCheck the output above for results.")
		return
	
	var test = tests[current_test]
	print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("🧪 TEST ", current_test + 1, "/", tests.size(), ": ", test["name"])
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
	
	# Load and instantiate test scene
	var test_scene = load(test["scene"])
	if test_scene == null:
		print("❌ Failed to load test scene: ", test["scene"])
		current_test += 1
		await get_tree().create_timer(1.0).timeout
		run_next_test()
		return
	
	var test_instance = test_scene.instantiate()
	add_child(test_instance)
	
	# Wait for test to complete
	await get_tree().create_timer(test["wait_time"]).timeout
	
	# Clean up
	test_instance.queue_free()
	
	# Move to next test
	current_test += 1
	await get_tree().create_timer(1.0).timeout
	run_next_test()

func _input(event):
	# Press Escape to quit
	if event.is_action_pressed("ui_cancel"):
		print("\n⚠️  Test suite interrupted by user.")
		get_tree().quit()
