extends Node2D

func _ready():
	print("=== Testing NecronomiCore C++ Extension ===")
	
	# Create the C++ extension directly
	var ai_core = NecronomiCore.new()
	add_child(ai_core)
	
	# Check if it loaded
	if ai_core == null:
		print("❌ Failed to create NecronomiCore")
		return
	
	print("✅ NecronomiCore extension loaded!")
	
	# Set API key
	var api_key = load_api_key()
	if api_key == "":
		print("❌ No API key found")
		return
	
	ai_core.set_api_key(api_key)
	ai_core.initialize()
	
	print("✅ Initialized:", ai_core.is_initialized())
	
	# Connect signals
	ai_core.item_pool_ready.connect(_on_items_ready)
	ai_core.request_failed.connect(_on_request_failed)
	
	# Test item generation
	print("🔄 Requesting item generation...")
	var config = {
		"difficulty": 1,
		"floor": 1,
		"theme": "lovecraftian fungal dungeon"
	}
	ai_core.request_item_generation(config)

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

func _on_items_ready(items):
	print("\n🎉 SUCCESS! Generated ", items.size(), " items:")
	print("============================================================")
	for item in items:
		print("  📦 ", item["name"])
		print("     Type: ", item["type"], " | Rarity: ", item["rarity"])
		print("     Damage: ", item["damage"], " | Defense: ", item["defense"])
		print("     Flavor: ", item["flavor_text"])
		print("     ---")

func _on_request_failed(error):
	print("\n❌ ERROR: ", error)
	print("This usually means the JSON parsing failed.")
	print("The C++ extension is working, but needs better prompt tuning.")
