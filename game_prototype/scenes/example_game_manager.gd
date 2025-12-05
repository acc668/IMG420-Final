extends Node
## Example: Game Manager / Run Manager
## Shows how to set up NecronomiCore at game/run start
## This is the RECOMMENDED way to use the system

# AI System (singleton pattern)
var ai_core = null
var item_pool_id = null
var items_ready = false

# Run configuration
var current_difficulty = 1
var current_floor = 1
var run_theme = "lovecraftian fungal dungeon"

# Signals for other game systems
signal run_ready
signal items_generated(items)

func _ready():
	print("🎮 ========== GAME MANAGER ==========")
	print("Initializing NecronomiCore AI System...")
	
	# Create and initialize AI core
	ai_core = NecronomiCore.new()
	add_child(ai_core)
	
	var api_key = load_api_key()
	if api_key == "":
		print("⚠️  Warning: No API key found. AI features disabled.")
		print("   Using fallback content...")
		items_ready = true
		run_ready.emit()
		return
	
	ai_core.set_api_key(api_key)
	ai_core.initialize()
	
	print("✅ AI System initialized")
	
	# Connect signals
	ai_core.item_pool_ready.connect(_on_items_ready)
	ai_core.request_failed.connect(_on_ai_error)
	
	# Start a new run
	start_new_run()

func start_new_run():
	print("\n🚀 Starting new run...")
	print("   Difficulty: ", current_difficulty)
	print("   Floor: ", current_floor)
	print("   Theme: ", run_theme)
	
	items_ready = false
	
	# PRE-GENERATE items for this entire run
	# This is key: do it ONCE at run start, not during gameplay!
	print("🔄 Generating item pool... (this may take 3-5 seconds)")
	
	ai_core.request_item_generation({
		"difficulty": current_difficulty,
		"floor": current_floor,
		"theme": run_theme
	})

func _on_items_ready(items):
	print("\n✅ Item pool ready! Generated ", items.size(), " items:")
	
	# Store items globally for the run
	# In a real game, you'd save this to a global singleton
	GlobalItemPool.set_items(items)  # You'd create this
	
	# Preview the items
	var rarity_counts = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0}
	for item in items:
		rarity_counts[item["rarity"]] += 1
	
	print("   Common: ", rarity_counts[0])
	print("   Uncommon: ", rarity_counts[1])
	print("   Rare: ", rarity_counts[2])
	print("   Epic: ", rarity_counts[3])
	print("   Legendary: ", rarity_counts[4])
	print("   Cursed: ", rarity_counts[5])
	
	items_ready = true
	items_generated.emit(items)
	run_ready.emit()
	
	print("\n🎮 RUN READY - Starting gameplay!")
	start_gameplay()

func _on_ai_error(error):
	print("❌ AI Error: ", error)
	print("   Falling back to procedural generation...")
	
	# Use fallback content
	items_ready = true
	run_ready.emit()
	start_gameplay()

func start_gameplay():
	# This is where you'd load your first level
	# get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
	print("✨ Game starting! (Load level 1 here)")

func get_random_item_for_loot(rarity_roll):
	# Helper function for loot drops
	# Call this from chests, enemies, etc.
	
	if not items_ready:
		print("⚠️  Items not ready yet!")
		return null
	
	var target_rarity = determine_rarity(rarity_roll)
	var pool_items = GlobalItemPool.get_items()  # You'd implement this
	
	# Find item with matching rarity
	var matching_items = []
	for item in pool_items:
		if item["rarity"] == target_rarity:
			matching_items.append(item)
	
	if matching_items.size() > 0:
		return matching_items[randi() % matching_items.size()]
	
	# Fallback: return any item
	if pool_items.size() > 0:
		return pool_items[randi() % pool_items.size()]
	
	return null

func determine_rarity(roll):
	# Standard loot table
	if roll >= 98: return 4    # Legendary
	if roll >= 90: return 3    # Epic
	if roll >= 70: return 2    # Rare
	if roll >= 40: return 1    # Uncommon
	return 0                   # Common

func load_api_key():
	if FileAccess.file_exists("res://api_config.json"):
		var file = FileAccess.open("res://api_config.json", FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			var json = JSON.new()
			if json.parse(json_string) == OK:
				var data = json.data
				if data.has("openai_api_key"):
					return data["openai_api_key"]
	return ""

## Example: Create a simple global item pool singleton
## You'd create this as an autoload script
class_name GlobalItemPool
static var _items = []

static func set_items(items):
	_items = items

static func get_items():
	return _items

static func get_item_by_rarity(rarity):
	var matches = []
	for item in _items:
		if item["rarity"] == rarity:
			matches.append(item)
	if matches.size() > 0:
		return matches[randi() % matches.size()]
	return null

