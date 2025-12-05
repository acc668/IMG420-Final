extends Area2D
## Example: Gambling Table with Random Roll Module
## Shows how Noah can use the Random Roll module for gambling mechanics

@export var min_bet = 10
@export var max_bet = 100

var ai_core = null
var player_in_range = false
var is_gambling = false

@onready var ui_panel = $GamblingUI  # Add a UI panel
@onready var result_label = $GamblingUI/ResultLabel
@onready var bet_label = $GamblingUI/BetLabel

func _ready():
	# Set up AI
	ai_core = get_node_or_null("/root/AI")
	if ai_core == null:
		ai_core = NecronomiCore.new()
		add_child(ai_core)
		ai_core.set_api_key(load_api_key())
		ai_core.initialize()
	
	# Connect player interaction
	body_entered.connect(_on_player_enter)
	body_exited.connect(_on_player_exit)
	
	# Hide UI initially
	if ui_panel:
		ui_panel.visible = false

func _on_player_enter(body):
	if body.name == "Player":
		player_in_range = true
		if ui_panel:
			ui_panel.visible = true
			bet_label.text = "Press SPACE to gamble (50 gold)"

func _on_player_exit(body):
	if body.name == "Player":
		player_in_range = false
		if ui_panel:
			ui_panel.visible = false

func _input(event):
	if player_in_range and event.is_action_pressed("ui_accept") and not is_gambling:
		play_gambling_game(50)  # Bet 50 gold

func play_gambling_game(bet_amount):
	is_gambling = true
	
	# Check if player has enough gold
	# if PlayerData.gold < bet_amount:
	#     show_error("Not enough gold!")
	#     return
	
	print("\n🎰 ========== GAMBLING ==========")
	print("💰 Bet: ", bet_amount, " gold")
	
	# Use the C++ roll module
	var roll = ai_core.generate_random_roll(1, 100, "fungal_dice_game")
	
	print("🎲 Rolled: ", roll, "/100")
	
	# Determine outcome
	var result = evaluate_gambling_result(roll, bet_amount)
	
	print(result.message)
	print("💰 Gold change: ", result.gold_change)
	
	# Apply results
	# PlayerData.gold += result.gold_change
	
	# Show in UI
	if result_label:
		result_label.text = result.message + "\nGold: " + str(result.gold_change)
	
	# Special effects for wins/losses
	if result.gold_change > 0:
		play_win_effect()
	elif result.gold_change < 0:
		play_lose_effect()
	
	# Apply curses on catastrophic loss
	if result.apply_curse:
		apply_bad_luck_curse()
	
	is_gambling = false

func evaluate_gambling_result(roll, bet):
	var result = {
		"message": "",
		"gold_change": 0,
		"apply_curse": false
	}
	
	if roll >= 98:
		# Jackpot! (2% chance)
		result.message = "🎉 JACKPOT! The Elder Bloom smiles upon you!"
		result.gold_change = bet * 5
	elif roll >= 90:
		# Big win (8% chance)
		result.message = "✨ BIG WIN! The fungal dice favor you!"
		result.gold_change = bet * 3
	elif roll >= 70:
		# Win (20% chance)
		result.message = "✅ You win! The spores glow approvingly."
		result.gold_change = bet * 2
	elif roll >= 50:
		# Small win (20% chance)
		result.message = "💚 Small win. The mycelium pulses faintly."
		result.gold_change = bet
	elif roll >= 30:
		# Push - no change (20% chance)
		result.message = "➖ Push. The fungus remains dormant."
		result.gold_change = 0
	elif roll >= 10:
		# Loss (20% chance)
		result.message = "❌ Loss. The bloom wilts."
		result.gold_change = -bet
	else:
		# Catastrophic loss + curse! (10% chance)
		result.message = "💀 CATASTROPHIC LOSS! The Elder Bloom REJECTS you!"
		result.gold_change = -bet * 2
		result.apply_curse = true
	
	return result

func play_win_effect():
	# Add visual/audio effects
	# $WinParticles.emitting = true
	# $WinSound.play()
	if sprite:
		# Simple flash effect
		sprite.modulate = Color(1, 1, 0)  # Yellow
		await get_tree().create_timer(0.2).timeout
		sprite.modulate = Color(1, 1, 1)  # Normal

func play_lose_effect():
	# Add visual/audio effects
	# $LoseParticles.emitting = true
	# $LoseSound.play()
	if sprite:
		sprite.modulate = Color(1, 0, 0)  # Red
		await get_tree().create_timer(0.2).timeout
		sprite.modulate = Color(1, 1, 1)  # Normal

func apply_bad_luck_curse():
	print("💀 CURSED: Bad Luck applied!")
	# Apply curse to player
	# PlayerData.add_curse("bad_luck", duration = 60.0)
	# This could reduce loot quality, crit chance, etc.

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

