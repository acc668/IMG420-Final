extends Node2D

func _ready():
	print("=== Testing Random Roll Module (Noah's Module) ===\n")
	
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
	
	print("✅ NecronomiCore initialized\n")
	
	# Test different roll types
	run_roll_tests(ai_core)

func run_roll_tests(ai_core):
	print("🎲 Test 1: Basic Random Rolls")
	print("============================================================")
	for i in range(5):
		var roll = ai_core.generate_random_roll(1, 100, "basic roll")
		print("  Roll #", i+1, ": ", roll, " (out of 100)")
	
	print("\n🎰 Test 2: Gambling Rolls")
	print("============================================================")
	print("  Betting 50 gold on the Fungal Dice Game...")
	for i in range(3):
		var roll = ai_core.generate_random_roll(1, 100, "gambling")
		var result = evaluate_gambling(roll, 50)
		print("  Game #", i+1, ": Rolled ", roll, " → ", result)
	
	print("\n⚔️ Test 3: Combat Rolls (Loot Quality)")
	print("============================================================")
	print("  Determining loot rarity from enemy drops...")
	for i in range(5):
		var roll = ai_core.generate_random_roll(1, 100, "loot_drop")
		var rarity = determine_rarity(roll)
		print("  Enemy #", i+1, ": Rolled ", roll, " → ", rarity, " loot")
	
	print("\n💀 Test 4: Sanity Checks (Saving Throws)")
	print("============================================================")
	print("  Player encounters eldritch horror...")
	for i in range(3):
		var roll = ai_core.generate_random_roll(1, 20, "sanity_check")
		var result = evaluate_saving_throw(roll, 15)
		print("  Check #", i+1, ": Rolled ", roll, "/20 → ", result)
	
	print("\n✨ Test 5: Critical Hits")
	print("============================================================")
	print("  Player attacks with base damage 25...")
	for i in range(5):
		var roll = ai_core.generate_random_roll(1, 100, "attack_roll")
		var is_crit = roll >= 95
		var damage = 25 * 2 if is_crit else 25
		var crit_text = " 💥 CRITICAL HIT!" if is_crit else ""
		print("  Attack #", i+1, ": Rolled ", roll, " → ", damage, " damage", crit_text)

func evaluate_gambling(roll, bet_amount):
	if roll >= 90:
		return "🎉 JACKPOT! Won " + str(bet_amount * 3) + " gold!"
	elif roll >= 75:
		return "✅ Big Win! Won " + str(bet_amount * 2) + " gold"
	elif roll >= 50:
		return "✅ Small Win! Won " + str(bet_amount) + " gold"
	elif roll >= 25:
		return "➖ Push - No change"
	elif roll >= 10:
		return "❌ Loss - Lost " + str(bet_amount) + " gold"
	else:
		return "💀 CATASTROPHIC LOSS! Lost " + str(bet_amount * 2) + " gold + cursed!"

func determine_rarity(roll):
	if roll >= 98:
		return "🌟 LEGENDARY"
	elif roll >= 90:
		return "💜 EPIC"
	elif roll >= 70:
		return "💙 RARE"
	elif roll >= 40:
		return "💚 UNCOMMON"
	else:
		return "⚪ COMMON"

func evaluate_saving_throw(roll, difficulty):
	if roll >= 20:
		return "✨ NATURAL 20! Perfect success!"
	elif roll >= difficulty:
		return "✅ Success - Sanity preserved"
	elif roll <= 1:
		return "💀 CRITICAL FAILURE! Mind fractures!"
	else:
		return "❌ Failed - Sanity damage"

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
