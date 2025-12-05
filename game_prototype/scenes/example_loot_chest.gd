extends Area2D
## Example: Loot Chest with AI-Generated Items
## Shows how Landon can use the Item Generation module in the actual game

# Reference to the global AI system
var ai_core = null
var current_item_pool = null
var is_opened = false

@onready var sprite = $Sprite2D  # Add a sprite for the chest
@onready var label = $Label      # Add a label to show item name

func _ready():
	# Get or create the AI core
	ai_core = get_node_or_null("/root/AI")
	if ai_core == null:
		# Create it if not in autoload
		ai_core = NecronomiCore.new()
		add_child(ai_core)
		ai_core.set_api_key(load_api_key())
		ai_core.initialize()
	
	# Wait for player to open
	body_entered.connect(_on_player_enter)

func _on_player_enter(body):
	if body.name == "Player" and not is_opened:
		open_chest()

func open_chest():
	is_opened = true
	
	print("🎁 Chest opened!")
	
	# For this example, we'll get a random item from a pre-generated pool
	# In a real game, you'd generate the pool at run start and reuse it
	
	# Quick method: Generate items now (for demo purposes)
	ai_core.item_pool_ready.connect(_on_items_ready)
	ai_core.request_item_generation({
		"difficulty": 1,
		"floor": 1,
		"theme": "lovecraftian fungal dungeon"
	})
	
	if label:
		label.text = "Opening..."

func _on_items_ready(items):
	# Pick a random item based on rarity roll
	var rarity_roll = randi() % 100
	var target_rarity = determine_rarity_from_roll(rarity_roll)
	
	# Find an item with that rarity
	var found_item = null
	for item in items:
		if item["rarity"] == target_rarity:
			found_item = item
			break
	
	# Fallback to any item if rarity not found
	if found_item == null and items.size() > 0:
		found_item = items[randi() % items.size()]
	
	if found_item:
		print("✨ Found: ", found_item["name"])
		print("   Rarity: ", get_rarity_name(found_item["rarity"]))
		print("   ", found_item["flavor_text"])
		
		if label:
			label.text = found_item["name"]
		
		# Add to player inventory (your game logic here)
		add_to_player_inventory(found_item)

func determine_rarity_from_roll(roll):
	# Loot table - adjust probabilities as needed
	if roll >= 98: return 4    # Legendary (2%)
	if roll >= 90: return 3    # Epic (8%)
	if roll >= 70: return 2    # Rare (20%)
	if roll >= 40: return 1    # Uncommon (30%)
	return 0                   # Common (40%)

func get_rarity_name(rarity):
	match rarity:
		0: return "Common"
		1: return "Uncommon"
		2: return "Rare"
		3: return "Epic"
		4: return "Legendary"
		5: return "Cursed"
		_: return "Unknown"

func add_to_player_inventory(item):
	# Your inventory system here
	print("📦 Added to inventory: ", item["name"])
	# Example: PlayerData.add_item(item)

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

