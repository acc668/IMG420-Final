extends Node2D

func _ready():
	print("=== Testing Emotion Dialog Module (Alexandra's Module) ===\n")
	
	# Create the C++ extension
	var ai_core = NecronomiCore.new()
	add_child(ai_core)
	
	if ai_core == null:
		print("❌ Failed to create NecronomiCore")
		return
	
	# Load API key and initialize
	var api_key = load_api_key()
	if api_key == "":
		print("❌ No API key found")
		return
	
	ai_core.set_api_key(api_key)
	ai_core.initialize()
	
	print("✅ NecronomiCore initialized")
	
	# Connect signals
	ai_core.dialog_ready.connect(_on_dialog_ready)
	ai_core.request_failed.connect(_on_error)
	
	# Test 1: Create a paranoid merchant NPC
	print("\n📝 Test 1: Paranoid Merchant (Suspicious, Low Sanity)")
	print("============================================================")
	
	var merchant_personality = {
		"npc_id": "merchant_morgrith",
		"npc_name": "Fungus Vendor Morgrith",
		"archetype": "paranoid merchant",
		"current_mood": "suspicious and anxious",
		"sanity_level": 0.3,
		"traits": [
			{
				"name": "paranoid",
				"intensity": 0.9,
				"description": "Believes everyone is plotting against them and out to steal their goods"
			},
			{
				"name": "greedy",
				"intensity": 0.7,
				"description": "Obsessed with profit and protecting their inventory"
			}
		]
	}
	
	ai_core.request_emotion_dialog(
		"Fungus Vendor Morgrith",
		"Player approaches the merchant's stall in a dark fungal cavern",
		merchant_personality
	)
	
	# Wait a moment, then test another NPC
	await get_tree().create_timer(5.0).timeout
	
	print("\n📝 Test 2: Wise Scholar (Calm, High Sanity)")
	print("============================================================")
	
	var scholar_personality = {
		"npc_id": "scholar_1",
		"npc_name": "Elder Mycologist",
		"archetype": "wise scholar",
		"current_mood": "thoughtful",
		"sanity_level": 0.8,
		"traits": [
			{
				"name": "knowledgeable",
				"intensity": 0.9,
				"description": "Expert in fungal lore and eldritch biology"
			},
			{
				"name": "cryptic",
				"intensity": 0.6,
				"description": "Speaks in riddles and metaphors"
			}
		]
	}
	
	ai_core.request_emotion_dialog(
		"Elder Mycologist",
		"Player asks about the ancient fungal ruins",
		scholar_personality
	)

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

func _on_dialog_ready(dialog_text):
	print("\n💬 NPC Says:")
	print("\"", dialog_text, "\"")
	print()

func _on_error(error):
	print("\n❌ Error: ", error)
