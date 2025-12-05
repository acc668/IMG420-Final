extends Node2D
## Example: Combat System with Random Rolls
## Shows how Noah can use rolls for attack damage, crits, and enemy loot

var ai_core = null

# Combat stats
@export var base_damage = 25
@export var crit_chance = 0.15  # 15% crit chance

# Player reference (you'd get this properly in your game)
var player = null

func _ready():
	# Set up AI
	ai_core = get_node_or_null("/root/AI")
	if ai_core == null:
		ai_core = NecronomiCore.new()
		add_child(ai_core)
		ai_core.set_api_key(load_api_key())
		ai_core.initialize()
	
	print("⚔️  Combat System Ready")
	
	# Example: Simulate some combat
	await get_tree().create_timer(1.0).timeout
	demo_combat_scenarios()

func demo_combat_scenarios():
	print("\n⚔️  ========== COMBAT DEMO ==========\n")
	
	# Demo 1: Regular attacks with crit chance
	print("📍 Scenario 1: Player Attacks Enemy (5 attacks)")
	print("Base damage: ", base_damage, " | Crit chance: ", crit_chance * 100, "%")
	print("=" * 60)
	
	for i in range(5):
		var result = player_attack()
		print("Attack ", i+1, ": ", result.damage, " damage", result.crit_text)
	
	# Demo 2: Enemy loot drops
	print("\n📍 Scenario 2: Enemy Defeated - Loot Drop")
	print("=" * 60)
	
	for i in range(3):
		var loot = roll_enemy_loot("Fungal Horror")
		print("Enemy ", i+1, " drops: ", loot.rarity_name, " quality loot")
	
	# Demo 3: Sanity checks
	print("\n📍 Scenario 3: Eldritch Encounter - Sanity Checks")
	print("=" * 60)
	
	for i in range(3):
		var sanity_result = roll_sanity_check(15)  # Difficulty 15
		print("Check ", i+1, ": ", sanity_result.message)

func player_attack():
	# Roll for critical hit
	var crit_roll = ai_core.generate_random_roll(1, 100, "crit_check")
	var is_crit = crit_roll >= (100 - crit_chance * 100)
	
	var damage = base_damage
	var crit_text = ""
	
	if is_crit:
		damage = base_damage * 2
		crit_text = " 💥 CRITICAL HIT!"
		# Play special effect
		# $CritEffect.play()
	
	# Add damage variance (±20%)
	var variance_roll = ai_core.generate_random_roll(-20, 20, "damage_variance")
	damage += int(damage * variance_roll / 100.0)
	
	return {
		"damage": damage,
		"is_crit": is_crit,
		"crit_text": crit_text
	}

func roll_enemy_loot(enemy_name):
	# Use roll module to determine loot quality
	var loot_roll = ai_core.generate_random_roll(1, 100, "loot_drop")
	
	# Determine rarity based on roll
	var rarity = 0
	var rarity_name = "Common"
	
	if loot_roll >= 95:
		rarity = 4
		rarity_name = "🌟 LEGENDARY"
	elif loot_roll >= 85:
		rarity = 3
		rarity_name = "💜 EPIC"
	elif loot_roll >= 65:
		rarity = 2
		rarity_name = "💙 RARE"
	elif loot_roll >= 35:
		rarity = 1
		rarity_name = "💚 UNCOMMON"
	else:
		rarity = 0
		rarity_name = "⚪ COMMON"
	
	# In a real game, you'd get the actual item from the pre-generated pool:
	# var item = GlobalItemPool.get_item_by_rarity(rarity)
	
	return {
		"rarity": rarity,
		"rarity_name": rarity_name,
		"roll": loot_roll
	}

func roll_sanity_check(difficulty):
	# Roll a d20 for sanity check
	var roll = ai_core.generate_random_roll(1, 20, "sanity_check")
	
	var result = {
		"roll": roll,
		"difficulty": difficulty,
		"success": false,
		"message": ""
	}
	
	if roll == 20:
		result.success = true
		result.message = "✨ NAT 20! Mind fortified against horror!"
		# PlayerData.add_temporary_buff("sanity_boost")
	elif roll >= difficulty:
		result.success = true
		result.message = "✅ Success (" + str(roll) + "/" + str(difficulty) + ") - Sanity preserved"
	elif roll == 1:
		result.success = false
		result.message = "💀 NAT 1! Mind fractures! Severe sanity loss!"
		# PlayerData.sanity -= 30
	else:
		result.success = false
		result.message = "❌ Failed (" + str(roll) + "/" + str(difficulty) + ") - Sanity damaged"
		# PlayerData.sanity -= 10
	
	return result

# Example: Using modifiers
func apply_luck_potion():
	# Noah's module supports modifiers!
	# This would be in the C++ code, but here's the concept:
	print("🍀 Luck Potion consumed! +10 to all rolls for 30 seconds")
	# ai_core.add_modifier("player", "luck_potion", 10, 1.0)
	# await get_tree().create_timer(30.0).timeout
	# ai_core.remove_modifier("player", "luck_potion")

# Example: Critical hit with rolls
func advanced_attack_with_modifiers():
	# Roll for attack
	var attack_roll = ai_core.generate_random_roll(1, 100, "attack")
	
	# Check for crit
	var is_crit = attack_roll >= 95
	
	# Roll damage
	var damage_roll = ai_core.generate_random_roll(
		base_damage / 2, 
		base_damage, 
		"damage_roll"
	)
	
	var final_damage = damage_roll * 2 if is_crit else damage_roll
	
	print("Attack: ", attack_roll, " | Damage: ", final_damage)
	return final_damage

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

