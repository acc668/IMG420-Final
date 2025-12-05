extends Area2D
## Example: Interactive NPC with AI-Powered Dialog
## Shows how Alexandra can use the Emotion Dialog module in the actual game

# NPC Configuration
@export var npc_name = "Fungal Merchant"
@export var npc_archetype = "suspicious vendor"
@export var sanity_level = 0.4

# AI System
var ai_core = null
var is_talking = false
var dialog_history = []

@onready var sprite = $Sprite2D  # Add NPC sprite
@onready var dialog_bubble = $DialogBubble  # Add UI element for dialog
@onready var dialog_label = $DialogBubble/Label

signal dialog_finished(npc_name)

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
	
	# Hide dialog initially
	if dialog_bubble:
		dialog_bubble.visible = false

func _on_player_enter(body):
	if body.name == "Player" and not is_talking:
		start_conversation()

func _on_player_exit(body):
	if body.name == "Player":
		end_conversation()

func start_conversation():
	is_talking = true
	
	# Build NPC personality
	var personality = {
		"npc_id": npc_name.to_lower().replace(" ", "_"),
		"npc_name": npc_name,
		"archetype": npc_archetype,
		"current_mood": determine_mood(),
		"sanity_level": sanity_level,
		"traits": get_npc_traits()
	}
	
	# Build context
	var context = "player approaches in a dark fungal cavern"
	
	# Request dialog
	ai_core.dialog_ready.connect(_on_dialog_received)
	ai_core.request_failed.connect(_on_dialog_failed)
	
	if dialog_bubble:
		dialog_bubble.visible = true
		dialog_label.text = "..."
	
	print("💬 ", npc_name, " is thinking...")
	ai_core.request_emotion_dialog(npc_name, context, personality)

func get_npc_traits():
	# Customize based on NPC archetype
	match npc_archetype:
		"suspicious vendor":
			return [
				{"name": "paranoid", "intensity": 0.9, "description": "Doesn't trust customers"},
				{"name": "greedy", "intensity": 0.7, "description": "Obsessed with profit"}
			]
		"mad scholar":
			return [
				{"name": "obsessive", "intensity": 0.8, "description": "Consumed by research"},
				{"name": "cryptic", "intensity": 0.9, "description": "Speaks in riddles"}
			]
		"cultist":
			return [
				{"name": "fanatical", "intensity": 0.9, "description": "Worships the Elder Bloom"},
				{"name": "eerie calm", "intensity": 0.7, "description": "Unnaturally peaceful"}
			]
		_:
			return [
				{"name": "mysterious", "intensity": 0.5, "description": "Unknown motives"}
			]

func determine_mood():
	# Mood can change based on game state, player actions, etc.
	# For now, base it on sanity
	if sanity_level > 0.7:
		return "thoughtful"
	elif sanity_level > 0.4:
		return "suspicious"
	else:
		return "erratic"

func _on_dialog_received(dialog_text):
	print("💬 ", npc_name, ": ", dialog_text)
	
	# Store in history
	dialog_history.append(dialog_text)
	
	# Show in UI
	if dialog_label:
		dialog_label.text = dialog_text
	
	# Optionally: Play text-to-speech or typing animation
	# show_dialog_animation(dialog_text)

func _on_dialog_failed(error):
	print("❌ Dialog generation failed: ", error)
	
	# Fallback dialog
	var fallback_lines = [
		"...",
		"The spores cloud my thoughts...",
		"I cannot speak...",
		"*incomprehensible whispers*"
	]
	var fallback = fallback_lines[randi() % fallback_lines.size()]
	
	if dialog_label:
		dialog_label.text = fallback

func end_conversation():
	is_talking = false
	if dialog_bubble:
		dialog_bubble.visible = false
	
	dialog_finished.emit(npc_name)

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

# Example: Player can trigger different dialog by pressing a key
func _input(event):
	if is_talking and event.is_action_pressed("ui_accept"):
		# Get next line of dialog or end conversation
		end_conversation()
