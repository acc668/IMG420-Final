extends Node2D

#top down lovecraftian dungeon crawler
#wasd/arrow keys to move, E to interact

#player stuff
@export var player_speed = 200.0
@export var player_sprint_speed = 350.0
var player_position = Vector2(1200, 900)
@export var player_stamina = 100.0
var player_max_stamina = 100.0
var stamina_drain_rate = 30.0  #drains per second
var stamina_regen_rate = 20.0  #regens per second
var is_sprinting = false

#npc
var npc_position = Vector2(1200, 600)
var npc_interaction_range = 80.0
var npc_name = "Fungal Merchant Morgrith"
var is_near_npc = false

#chest
var chest_position = Vector2(800, 900)
var chest_interaction_range = 60.0
var is_near_chest = false
var chest_opened = false
var preloaded_items: Array = []
var items_ready = false

#hidden door
var door_position = Vector2(-4091, 868)
var door_interaction_range = 80.0
var is_near_door = false
var door_found = false

#boss enemy guarding the door
var boss_enemy = null
var boss_position = Vector2(-4091, 750)
var boss_health = 300
var boss_max_health = 300
var boss_shoot_cooldown = 0.0
var boss_shoot_interval = 1.5
var boss_projectile_count = 8
var boss_defeated = false
var boss_wander_direction = Vector2.ZERO
var boss_wander_timer = 0.0
var boss_speed = 350.0  #faster than normal walk, slower than sprint
var boss_chase_range = 800.0
var boss_attack_range = 50.0
var boss_attack_cooldown = 0.0
var boss_attack_interval = 0.5
var boss_wander_radius = 400.0
var boss_last_direction = Vector2.ZERO

#enemies
var enemies = []
@export var enemy_speed = 120.0
var enemy_wander_speed = 50.0
var enemy_detection_range = 200.0
var enemy_attack_range = 40.0
var shooter_attack_range = 300.0
var shooter_flee_range = 150.0

#projectiles
var projectiles = []
var projectile_speed = 250.0
var player_shoot_cooldown = 0.0
var player_shoot_interval = 0.3

#player stats
var player_health = 100
var player_max_health = 100
var is_player_hurt = false
var hurt_cooldown = 0.0

#ai core
var ai_core: Node
var is_talking = false

#ui references
@onready var player_node: Node2D
@onready var player_area: Area2D
@onready var player_sprite: AnimatedSprite2D
@onready var npc_node: ColorRect
@onready var npc_sprite: Sprite2D
@onready var chest_node: ColorRect
@onready var chest_sprite: Sprite2D
@onready var door_sprite: Sprite2D
@onready var enemies_container: Node2D
@onready var projectiles_container: Node2D
@onready var player_camera: Camera2D
@onready var dialog_box: Panel
@onready var dialog_text: RichTextLabel
@onready var prompt_label: Label
@onready var chest_prompt_label: Label
@onready var door_prompt_label: Label
@onready var loading_label: Label
@onready var health_bar: ProgressBar
@onready var stamina_bar: ProgressBar
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound

func _ready():
	#get node references
	player_node = $Player
	player_area = $Player/Area2D
	player_sprite = $Player/AnimatedSprite
	npc_node = $NPC
	npc_sprite = $NPC/MerchantSprite
	chest_node = $Chest
	chest_sprite = $Chest/ChestSprite
	door_sprite = $HiddenBrush/Door
	enemies_container = $Enemies
	projectiles_container = $Projectiles
	player_camera = $Player/Camera2D
	dialog_box = $UI/DialogBox
	dialog_text = $UI/DialogBox/DialogText
	prompt_label = $UI/PromptLabel
	chest_prompt_label = $UI/ChestPromptLabel
	door_prompt_label = $UI/DoorPromptLabel
	loading_label = $UI/LoadingLabel
	health_bar = $UI/HealthBar
	stamina_bar = $UI/StaminaBar
	
	#setup player position
	player_node.position = player_position
	#npc chest and door already positioned in scene file
	
	#door hidden in brush initially
	door_sprite.visible = false
	
	#hide dialog stuff
	dialog_box.visible = false
	prompt_label.visible = false
	chest_prompt_label.visible = false
	door_prompt_label.visible = false
	loading_label.visible = false
	
	#setup enemies
	setup_enemies()
	
	#setup boss
	setup_boss_enemy()
	
	update_health_ui()
	update_stamina_ui()
	
	#init ai in background so game starts fast
	print("Starting game... AI loading in background")
	call_deferred("initialize_ai_async")

func setup_enemies():
	#load enemy textures
	var enemy_texture1 = load("res://assets/ememywaking1.PNG")
	var enemy_texture2 = load("res://assets/ememywaking2.PNG")
	
	#sprite frames for animation
	var sprite_frames = SpriteFrames.new()
	sprite_frames.add_animation("walk")
	sprite_frames.add_animation("idle")
	sprite_frames.add_frame("walk", enemy_texture1)
	sprite_frames.add_frame("walk", enemy_texture2)
	sprite_frames.add_frame("idle", enemy_texture1)
	sprite_frames.set_animation_speed("walk", 8.0)
	sprite_frames.set_animation_speed("idle", 5.0)
	sprite_frames.set_animation_loop("walk", true)
	sprite_frames.set_animation_loop("idle", true)
	
	#create 5 enemies
	var enemy_positions = [
		Vector2(1500, 1200),
		Vector2(600, 600),
		Vector2(1800, 900),
		Vector2(900, 1400),
		Vector2(1600, 400)
	]
	
	var enemy_colors = [
		Color(0.8, 0.2, 0.2),
		Color(0.6, 0.2, 0.6),
		Color(0.8, 0.4, 0.1),
		Color(1.0, 0.9, 0.2),
		Color(0.3, 0.8, 0.8)
	]
	
	var enemy_types = ["melee", "melee", "melee", "shooter", "shooter"]
	
	for i in range(enemy_positions.size()):
		#create enemy sprite
		var enemy_sprite = AnimatedSprite2D.new()
		enemy_sprite.sprite_frames = sprite_frames
		enemy_sprite.animation = "walk"
		enemy_sprite.play()
		enemy_sprite.scale = Vector2(0.17, 0.17)
		enemy_sprite.modulate = enemy_colors[i]
		enemy_sprite.position = enemy_positions[i]
		enemies_container.add_child(enemy_sprite)
		
		#enemy data
		var enemy_data = {
			"sprite": enemy_sprite,
			"position": enemy_positions[i],
			"state": "wander",
			"type": enemy_types[i],
			"wander_direction": Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized(),
			"wander_timer": 0.0,
			"shoot_timer": 0.0
		}
		enemies.append(enemy_data)

func setup_boss_enemy():
	#load boss textures
	var boss_texture1 = load("res://assets/ememywaking1.PNG")
	var boss_texture2 = load("res://assets/ememywaking2.PNG")
	
	#boss animation
	var sprite_frames = SpriteFrames.new()
	sprite_frames.add_animation("idle")
	sprite_frames.add_frame("idle", boss_texture1)
	sprite_frames.add_frame("idle", boss_texture2)
	sprite_frames.set_animation_speed("idle", 3.0)
	sprite_frames.set_animation_loop("idle", true)
	
	#create boss sprite bigger than enemies
	var boss_sprite = AnimatedSprite2D.new()
	boss_sprite.sprite_frames = sprite_frames
	boss_sprite.animation = "idle"
	boss_sprite.play()
	boss_sprite.scale = Vector2(0.4, 0.4)
	boss_sprite.modulate = Color(0.8, 0.1, 0.9)
	boss_sprite.position = boss_position
	enemies_container.add_child(boss_sprite)
	
	#boss data
	boss_enemy = {
		"sprite": boss_sprite,
		"position": boss_position,
		"health": boss_health,
		"max_health": boss_max_health,
		"active": true
	}
	
	#init wander direction
	boss_wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	boss_wander_timer = 0.0
	
	print("Boss enemy created at door position!")

func initialize_ai_async():
	#runs async so game starts fast
	ai_core = NecronomiCore.new()
	add_child(ai_core)
	
	var api_key = load_api_key()
	if api_key != "":
		ai_core.set_api_key(api_key)
		ai_core.initialize()
		ai_core.dialog_ready.connect(_on_dialog_ready)
		ai_core.request_failed.connect(_on_dialog_failed)
		ai_core.item_pool_ready.connect(_on_items_preloaded)
		print("AI Core initialized - preloading items in background...")
		
		#preload chest items
		var config = {
			"difficulty": 1,
			"floor": 1,
			"theme": "lovecraftian fungal dungeon",
			"item_count": 5
		}
		ai_core.request_item_generation(config)
	else:
		print("No API key - using fallback dialog")
		#use fallback items
		preloaded_items = [
			{"name": "Rusty Fungal Blade", "rarity": 0, "flavor_text": "A sword covered in strange spores", "damage": 10, "defense": 0},
			{"name": "Glowing Mushroom Cap", "rarity": 1, "flavor_text": "It pulses with an eerie light", "damage": 0, "defense": 5},
			{"name": "Eldritch Spore Vial", "rarity": 2, "flavor_text": "Ancient and powerful spores within", "damage": 0, "defense": 0},
			{"name": "Cursed Fungal Staff", "rarity": 3, "flavor_text": "Whispers emanate from its core", "damage": 20, "defense": 0},
			{"name": "Nyarlathotep's Ring", "rarity": 4, "flavor_text": "Reality bends around this artifact", "damage": 0, "defense": 10}
		]
		items_ready = true

func _process(delta):
	#update hurt cooldown
	if hurt_cooldown > 0:
		hurt_cooldown -= delta
		is_player_hurt = false
	else:
		#reset player color
		player_sprite.modulate = Color(1, 1, 1)
	
	#update shoot cooldown
	if player_shoot_cooldown > 0:
		player_shoot_cooldown -= delta
		if player_shoot_cooldown < 0:
			player_shoot_cooldown = 0
	
	if is_talking:
		return  #cant move while talking
	
	#check if sprinting
	is_sprinting = Input.is_key_pressed(KEY_SHIFT) and player_stamina > 0
	
	#stamina management
	if is_sprinting:
		player_stamina -= stamina_drain_rate * delta
		if player_stamina < 0:
			player_stamina = 0
			is_sprinting = false
	else:
		player_stamina += stamina_regen_rate * delta
		if player_stamina > player_max_stamina:
			player_stamina = player_max_stamina
	
	update_stamina_ui()
	
	#player movement
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction.y -= 1
	
	if direction.length() > 0:
		direction = direction.normalized()
		var current_speed = player_sprint_speed if is_sprinting else player_speed
		var movement = direction * current_speed * delta
		
		#raycast collision detection
		var space_state = get_world_2d().direct_space_state
		
		#try X movement
		var can_move_x = true
		if movement.x != 0:
			var ray_query = PhysicsRayQueryParameters2D.create(player_position, player_position + Vector2(movement.x * 2, 0))
			ray_query.collide_with_bodies = true
			ray_query.collide_with_areas = false
			var result_x = space_state.intersect_ray(ray_query)
			if result_x and result_x.collider is StaticBody2D:
				can_move_x = false
		
		if can_move_x:
			player_position.x += movement.x
		
		#try Y movement
		var can_move_y = true
		if movement.y != 0:
			var ray_query = PhysicsRayQueryParameters2D.create(player_position, player_position + Vector2(0, movement.y * 2))
			ray_query.collide_with_bodies = true
			ray_query.collide_with_areas = false
			var result_y = space_state.intersect_ray(ray_query)
			if result_y and result_y.collider is StaticBody2D:
				can_move_y = false
		
		if can_move_y:
			player_position.y += movement.y
		
		#update position
		player_node.position = player_position
		
		#flip sprite
		if direction.x < 0:
			player_sprite.flip_h = true
		elif direction.x > 0:
			player_sprite.flip_h = false
		
		#walk animation
		if player_sprite.animation != "walk":
			player_sprite.play("walk")
			player_sprite.scale = Vector2(0.17, 0.17)
	else:
		#idle animation when standing
		if player_sprite.animation != "idle":
			player_sprite.play("idle")
			player_sprite.scale = Vector2(0.12, 0.12)
	
	#enemy ai
	update_enemy_ai(delta)
	
	#boss ai only after chest opened
	if chest_opened and not boss_defeated and boss_enemy != null:
		update_boss_ai(delta)
	
	#update projectiles
	update_projectiles(delta)
	
	#check distance to npc
	var distance_to_npc = player_position.distance_to(npc_position)
	is_near_npc = distance_to_npc < npc_interaction_range
	
	#check distance to chest
	var distance_to_chest = player_position.distance_to(chest_position)
	is_near_chest = distance_to_chest < chest_interaction_range and not chest_opened
	
	#check distance to door
	if chest_opened:
		var distance_to_door = player_position.distance_to(door_position)
		is_near_door = distance_to_door < door_interaction_range and not door_found
		
		#debug print
		if distance_to_door < 150:
			print("Distance to door: ", distance_to_door, " | Near door: ", is_near_door, " | Door found: ", door_found)
		
		#make door visible when close
		if distance_to_door < 150:
			door_sprite.visible = true
	
	#show/hide prompts
	prompt_label.visible = is_near_npc and not is_talking
	chest_prompt_label.visible = is_near_chest and not is_talking
	door_prompt_label.visible = is_near_door and not is_talking

func _input(event):
	#E to interact
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_E and not is_talking:
			print("E pressed! Near NPC: ", is_near_npc, " | Near Chest: ", is_near_chest, " | Near Door: ", is_near_door, " | Chest opened: ", chest_opened)
			if is_near_npc:
				interact_with_npc()
			elif is_near_chest and not chest_opened:
				open_chest()
			elif is_near_door and not door_found:
				print("Triggering find_door()!")
				find_door()
			else:
				print("Not near any interactive object")
		elif event.keycode == KEY_ESCAPE and is_talking:
			close_dialog()
	
	#shooting disabled
	# if event is InputEventMouseButton and event.pressed:
	# 	if event.button_index == MOUSE_BUTTON_LEFT and not is_talking:
	# 		print("Click detected! Cooldown: ", player_shoot_cooldown, " | Player pos: ", player_position)
	# 		if player_shoot_cooldown <= 0.0:
	# 			# Get mouse position in global/world coordinates
	# 			var world_mouse_pos = get_global_mouse_position()
	# 			
	# 			print("Shooting! Mouse world pos: ", world_mouse_pos, " | Player pos: ", player_position, " | Direction: ", (world_mouse_pos - player_position).normalized())
	# 			
	# 			# Shoot projectile towards mouse
	# 			spawn_player_projectile(player_position, world_mouse_pos)
	# 			player_shoot_cooldown = player_shoot_interval
	# 			print("Set cooldown to: ", player_shoot_cooldown)
	# 		else:
	# 			print("Cooldown active, can't shoot yet")
		

func interact_with_npc():
	is_talking = true
	dialog_box.visible = true
	dialog_text.clear()
	dialog_text.append_text("[color=gray]Generating dialog...[/color]\n")
	
	if not ai_core or not ai_core.is_initialized():
		#fallback if no ai
		await get_tree().create_timer(0.5).timeout
		show_fallback_dialog()
		return
	
	#different personality based on chest state
	var personality = {}
	var context = ""
	
	if not chest_opened:
		#before chest opened
		personality = {
			"npc_id": "merchant_morgrith",
			"npc_name": npc_name,
			"archetype": "paranoid fungal merchant who knows about a hidden treasure chest",
			"current_mood": "suspicious and anxious but eager to share secret knowledge",
			"sanity_level": 0.3,
			"traits": [
				{
					"name": "paranoid",
					"intensity": 0.9,
					"description": "paranoid but wants to share chest secret"
				},
				{
					"name": "obsessed_with_chest",
					"intensity": 0.95,
					"description": "cant stop talking about hidden chest"
				},
				{
					"name": "cryptic",
					"intensity": 0.8,
					"description": "speaks in riddles"
				}
			]
		}
		context = "player approaches merchant in fungal cavern, merchant wants to tell about hidden chest"
	else:
		#after chest opened
		personality = {
			"npc_id": "merchant_morgrith",
			"npc_name": npc_name,
			"archetype": "paranoid fungal merchant who is impressed the player found the chest",
			"current_mood": "excited and manic, eager to share another secret",
			"sanity_level": 0.3,
			"traits": [
				{
					"name": "congratulatory",
					"intensity": 0.95,
					"description": "excited player found the chest"
				},
				{
					"name": "obsessed_with_door",
					"intensity": 0.95,
					"description": "cant stop talking about hidden door in brush"
				},
				{
					"name": "cryptic",
					"intensity": 0.8,
					"description": "speaks in riddles about door location"
				}
			]
		}
		context = "player returns after finding chest, merchant tells about secret door in brush"
	
	ai_core.request_emotion_dialog(npc_name, context, personality)

func close_dialog():
	is_talking = false
	dialog_box.visible = false

func _on_dialog_ready(dialog: String):
	dialog_text.clear()
	dialog_text.append_text("[color=cyan]%s:[/color]\n" % npc_name)
	dialog_text.append_text('[color=white]"%s"[/color]\n\n' % dialog)
	dialog_text.append_text("[color=gray]Press ESC to close[/color]")

func _on_dialog_failed(error: String):
	dialog_text.clear()
	dialog_text.append_text("[color=red]Error: %s[/color]\n" % error)
	dialog_text.append_text("[color=gray]Using fallback...[/color]\n\n")
	await get_tree().create_timer(0.5).timeout
	show_fallback_dialog()

func show_fallback_dialog():
	var fallback_dialogs = []
	
	if not chest_opened:
		#before chest opened
		fallback_dialogs = [
			"Stay back! But... but there's a chest hidden in the shadows. I've seen it! Full of treasures!",
			"The shadows whisper about a chest... a chest full of wonders! Have you found it yet?",
			"My mushrooms... they grow near the chest! Yes, yes, there's a chest hidden somewhere here!",
			"The deep ones told me about the chest... a magnificent chest full of eldritch artifacts!",
			"Do you seek the chest? I know where it is! Well... somewhere in the darkness... there's definitely a chest!"
		]
	else:
		#after chest opened
		fallback_dialogs = [
			"You found it! Good job! But wait... there's more! A door... hidden in the brush! Can you find it?",
			"Well done, well done! The chest was just the beginning! Now seek the door hidden in the vegetation!",
			"Excellent work! But the real secret... a door concealed among the fungal growths! Look carefully!",
			"You've proven yourself! Now I'll tell you... there's a door, hidden in the brush and mushrooms! Seek it!",
			"Good job finding my chest! But there's a door... hidden where the mushrooms grow thick! Find it!"
		]
	
	var dialog = fallback_dialogs[randi() % fallback_dialogs.size()]
	
	dialog_text.clear()
	dialog_text.append_text("[color=cyan]%s:[/color]\n" % npc_name)
	dialog_text.append_text('[color=white]"%s"[/color]\n\n' % dialog)
	dialog_text.append_text("[color=gray]Press ESC to close[/color]")

func open_chest():
	is_talking = true
	chest_opened = true
	dialog_box.visible = true
	dialog_text.clear()
	
	#change chest texture
	chest_sprite.texture = preload("res://assets/chestopened.PNG")
	
	#darken background
	chest_node.color = Color(0.4, 0.3, 0.2)
	
	#show items
	if items_ready and preloaded_items.size() > 0:
		show_chest_items(preloaded_items)
	else:
		dialog_text.append_text("[color=yellow]📦 Opening the mysterious chest...[/color]\n")
		dialog_text.append_text("[color=gray]Loading treasures...[/color]\n\n")

func _on_items_preloaded(items: Array):
	#store preloaded items
	preloaded_items = items
	items_ready = true
	print("Chest items preloaded in background! (%d items ready)" % items.size())

func show_chest_items(items: Array):
	dialog_text.clear()
	dialog_text.append_text("[color=yellow]✨ The chest reveals its treasures![/color]\n\n")
	
	var rarity_colors = {
		0: "white",
		1: "green",
		2: "blue",
		3: "purple",
		4: "orange",
		5: "red"
	}
	
	var rarity_names = ["Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"]
	
	for item in items:
		var rarity = item.get("rarity", 0)
		var rarity_color = rarity_colors.get(rarity, "white")
		var rarity_name = rarity_names[rarity] if rarity < rarity_names.size() else "Unknown"
		
		dialog_text.append_text("[color=%s]📦 %s[/color]\n" % [rarity_color, item["name"]])
		dialog_text.append_text("[color=gray]   Rarity: %s[/color]\n" % rarity_name)
		dialog_text.append_text("[color=gray]   %s[/color]\n\n" % item["flavor_text"])
	
	dialog_text.append_text("[color=green]Items added to your inventory![/color]\n")
	dialog_text.append_text("[color=gray]Press ESC to close[/color]")


func find_door():
	door_found = true
	is_talking = true
	dialog_box.visible = true
	dialog_text.clear()
	
	#green glow when found
	door_sprite.modulate = Color(1.0, 1.5, 1.0)
	
	dialog_text.append_text("[color=green]🚪 You found the hidden door![/color]\n\n")
	dialog_text.append_text("[color=yellow]The ancient door creaks open, revealing a passage deeper into the fungal depths...[/color]\n\n")
	dialog_text.append_text("[color=cyan]Beyond lies mysteries untold. The spores grow thicker here.[/color]\n\n")
	dialog_text.append_text("[color=white]Your journey into the unknown continues...[/color]\n\n")
	dialog_text.append_text("[color=gray]Press ESC to close[/color]")
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/win_screen.tscn")

func update_enemy_ai(delta):
	#update each enemy
	for enemy in enemies:
		var distance_to_player = enemy.position.distance_to(player_position)
		
		#different behavior for shooters vs melee
		if enemy.type == "shooter":
			update_shooter_enemy(enemy, distance_to_player, delta)
		else:
			update_melee_enemy(enemy, distance_to_player, delta)
		
		#update sprite position
		enemy.sprite.position = enemy.position
		
		#flip sprite
		var direction_to_player = (player_position - enemy.position).normalized()
		if direction_to_player.x < 0:
			enemy.sprite.flip_h = true
		elif direction_to_player.x > 0:
			enemy.sprite.flip_h = false

func update_melee_enemy(enemy: Dictionary, distance_to_player: float, delta):
	#state machine
	if distance_to_player < enemy_detection_range:
		#player detected
		if distance_to_player < enemy_attack_range:
			enemy.state = "attack"
			attack_player_with_enemy(enemy, delta)
		else:
			enemy.state = "chase"
			chase_player_with_enemy(enemy, delta)
	else:
		enemy.state = "wander"
		wander_enemy(enemy, delta)

func update_shooter_enemy(enemy: Dictionary, distance_to_player: float, delta):
	#shooters keep distance
	if distance_to_player < shooter_attack_range:
		#in range
		if distance_to_player < shooter_flee_range:
			#too close back away
			enemy.state = "flee"
			flee_from_player(enemy, delta)
		else:
			#good distance shoot
			enemy.state = "shoot"
			shoot_at_player(enemy, delta)
	else:
		enemy.state = "wander"
		wander_enemy(enemy, delta)

func wander_enemy(enemy: Dictionary, delta):
	#change direction every 2 sec
	enemy.wander_timer += delta
	if enemy.wander_timer >= 2.0:
		enemy.wander_timer = 0.0
		enemy.wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	#move in wander direction
	enemy.position += enemy.wander_direction * enemy_wander_speed * delta
	
	#keep in bounds
	enemy.position.x = clamp(enemy.position.x, 120, 2280)
	enemy.position.y = clamp(enemy.position.y, 120, 1680)

func chase_player_with_enemy(enemy: Dictionary, delta):
	#move towards player
	var direction = (player_position - enemy.position).normalized()
	enemy.position += direction * enemy_speed * delta

func attack_player_with_enemy(enemy: Dictionary, delta):
	#attack every 1 sec
	
	if hurt_cooldown <= 0:
		var damage = 10
		
		#use ai roll for damage variation
		if ai_core and ai_core.is_initialized():
			var roll = ai_core.generate_random_roll(1, 20, "enemy_attack")
			damage = 5 + roll
		
		player_health -= damage
		hurt_cooldown = 1.0
		is_player_hurt = true
		
		
		#flash player red
		player_sprite.modulate = Color(1, 0.3, 0.3)
		hurt_sound.play()
		await get_tree().create_timer(0.2).timeout
		player_sprite.modulate = Color(1, 1, 1)
		
		update_health_ui()
		
		#check if dead
		if player_health <= 0:
			game_over()

func flee_from_player(enemy: Dictionary, delta):
	#run away
	var direction = (enemy.position - player_position).normalized()
	enemy.position += direction * enemy_speed * delta
	
	#keep in bounds
	enemy.position.x = clamp(enemy.position.x, 120, 2280)
	enemy.position.y = clamp(enemy.position.y, 120, 1680)

func shoot_at_player(enemy: Dictionary, delta):
	#shoot every 1.5 sec
	enemy.shoot_timer += delta
	if enemy.shoot_timer >= 1.5:
		enemy.shoot_timer = 0.0
		spawn_projectile(enemy.position, player_position)

func spawn_projectile(from_position: Vector2, target_position: Vector2):
	#create enemy projectile
	var projectile_sprite = ColorRect.new()
	projectile_sprite.custom_minimum_size = Vector2(16, 16)
	projectile_sprite.color = Color(1, 0.8, 0.2)
	projectile_sprite.position = from_position
	projectiles_container.add_child(projectile_sprite)
	
	#calc direction
	var direction = (target_position - from_position).normalized()
	
	#projectile data
	var projectile_data = {
		"sprite": projectile_sprite,
		"position": from_position,
		"direction": direction
	}
	projectiles.append(projectile_data)

func spawn_player_projectile(from_position: Vector2, target_position: Vector2):
	#create player projectile
	var projectile_sprite = ColorRect.new()
	projectile_sprite.custom_minimum_size = Vector2(20, 20)
	projectile_sprite.color = Color(0.2, 0.8, 1.0)
	projectile_sprite.position = from_position
	projectiles_container.add_child(projectile_sprite)
	
	#calc direction
	var direction = (target_position - from_position).normalized()
	
	#projectile data
	var projectile_data = {
		"sprite": projectile_sprite,
		"position": from_position,
		"direction": direction,
		"from_player": true
	}
	projectiles.append(projectile_data)

func update_boss_ai(delta):
	if not boss_enemy or not boss_enemy.active:
		return
	
	#check distance to player
	var distance_to_player = boss_position.distance_to(player_position)
	
	#update attack cooldown
	if boss_attack_cooldown > 0:
		boss_attack_cooldown -= delta
	
	#aggressive ai
	var movement_direction = Vector2.ZERO
	
	if distance_to_player < boss_chase_range:
		#chase mode
		var direction_to_player = (player_position - boss_position).normalized()
		boss_position += direction_to_player * boss_speed * delta
		movement_direction = direction_to_player
		
		#attack if close
		if distance_to_player < boss_attack_range:
			if boss_attack_cooldown <= 0:
				boss_attack_player()
				boss_attack_cooldown = boss_attack_interval
	else:
		#wander near door
		boss_wander_timer += delta
		
		#change direction every 2 sec
		if boss_wander_timer >= 2.0:
			boss_wander_timer = 0.0
			boss_wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		
		#move slower when wandering
		boss_position += boss_wander_direction * (boss_speed * 0.4) * delta
		movement_direction = boss_wander_direction
		
		#keep near door
		var distance_from_start = boss_position.distance_to(Vector2(-4091, 750))
		if distance_from_start > boss_wander_radius:
			#pull back to door
			var direction_to_door = (Vector2(-4091, 750) - boss_position).normalized()
			boss_position += direction_to_door * boss_speed * delta
			movement_direction = direction_to_door
	
	#smooth sprite flipping
	if movement_direction.length() > 0.1:
		#only flip if significant horizontal movement
		if abs(movement_direction.x) > 0.3:
			if movement_direction.x < -0.3 and not boss_enemy.sprite.flip_h:
				boss_enemy.sprite.flip_h = true
			elif movement_direction.x > 0.3 and boss_enemy.sprite.flip_h:
				boss_enemy.sprite.flip_h = false
		
		boss_last_direction = movement_direction
	
	#update sprite position
	boss_enemy.position = boss_position
	boss_enemy.sprite.position = boss_position

func boss_attack_player():
	#melee damage
	if hurt_cooldown <= 0:
		hurt_sound.play()
		player_health -= 15
		hurt_cooldown = 1.0
		
		#flash red
		player_sprite.modulate = Color(1, 0.2, 0.2)
		
		update_health_ui()
		
		if player_health <= 0:
			game_over()
		
		print("Boss attacked! Player health: ", player_health)

func spawn_boss_projectile(from_position: Vector2, direction: Vector2):
	#boss projectile
	var projectile_sprite = ColorRect.new()
	projectile_sprite.custom_minimum_size = Vector2(24, 24)
	projectile_sprite.color = Color(0.9, 0.1, 0.9)
	projectile_sprite.position = from_position
	projectiles_container.add_child(projectile_sprite)
	
	#projectile data
	var projectile_data = {
		"sprite": projectile_sprite,
		"position": from_position,
		"direction": direction,
		"from_boss": true
	}
	projectiles.append(projectile_data)

func damage_boss(damage_amount: int):
	if not boss_enemy or not boss_enemy.active:
		return
	
	boss_health -= damage_amount
	print("Boss took ", damage_amount, " damage! Health: ", boss_health, "/", boss_max_health)
	
	#flash boss white
	boss_enemy.sprite.modulate = Color(1, 1, 1)
	await get_tree().create_timer(0.1).timeout
	boss_enemy.sprite.modulate = Color(0.8, 0.1, 0.9)
	
	#check if dead
	if boss_health <= 0:
		defeat_boss()

func defeat_boss():
	boss_defeated = true
	boss_enemy.active = false
	
	#remove sprite
	if boss_enemy.sprite:
		boss_enemy.sprite.queue_free()
	
	#victory
	print("Boss defeated! Door is now accessible!")
	
	#make door glow
	door_sprite.modulate = Color(1.5, 1.5, 1.0)

func update_projectiles(delta):
	#update each projectile
	var projectiles_to_remove = []
	
	for i in range(projectiles.size()):
		var projectile = projectiles[i]
		
		#move projectile
		projectile.position += projectile.direction * projectile_speed * delta
		projectile.sprite.position = projectile.position
		
		#check type
		var is_from_boss = projectile.get("from_boss", false)
		var is_from_player = projectile.get("from_player", false)
		
		if is_from_player:
			#player projectiles hit enemies/boss
			var hit_something = false
			
			#check boss collision
			if boss_enemy and boss_enemy.active:
				var distance_to_boss = projectile.position.distance_to(boss_position)
				if distance_to_boss < 40:
					damage_boss(20)
					projectiles_to_remove.append(i)
					hit_something = true
			
			#check enemy collisions
			if not hit_something:
				for enemy in enemies:
					var distance_to_enemy = projectile.position.distance_to(enemy.position)
					if distance_to_enemy < 30:
						#hit
						enemy.sprite.queue_free()
						enemies.erase(enemy)
						projectiles_to_remove.append(i)
						hit_something = true
						break
			
			if hit_something:
				continue
				
		elif is_from_boss:
			#boss projectiles hit player
			var distance_to_player = projectile.position.distance_to(player_position)
			if distance_to_player < 20:
				#hit
				if hurt_cooldown <= 0:
					hurt_sound.play()
					player_health -= 10
					hurt_cooldown = 1.0
					
					#flash player
					player_sprite.modulate = Color(1, 0.5, 0.2)
					
					update_health_ui()
					
					if player_health <= 0:
						game_over()
				
				projectiles_to_remove.append(i)
				continue
		else:
			#enemy projectiles hit player
			var distance_to_player = projectile.position.distance_to(player_position)
			if distance_to_player < 20:
				#hit
				if hurt_cooldown <= 0:
					hurt_sound.play()
					player_health -= 5
					hurt_cooldown = 1.0
					
					#flash player
					player_sprite.modulate = Color(1, 0.5, 0.2)
					
					update_health_ui()
					
					if player_health <= 0:
						game_over()
				
				projectiles_to_remove.append(i)
				continue
		
		#remove if out of bounds
		if projectile.position.x < 100 or projectile.position.x > 2300 or \
		   projectile.position.y < 100 or projectile.position.y > 1700:
			projectiles_to_remove.append(i)
	
	#remove dead projectiles
	for i in range(projectiles_to_remove.size() - 1, -1, -1):
		var idx = projectiles_to_remove[i]
		projectiles[idx].sprite.queue_free()
		projectiles.remove_at(idx)

func update_health_ui():
	if health_bar:
		health_bar.value = player_health
		
		#color code health
		if player_health > 70:
			health_bar.modulate = Color(0.3, 1, 0.3)
		elif player_health > 30:
			health_bar.modulate = Color(1, 1, 0.3)
		else:
			health_bar.modulate = Color(1, 0.3, 0.3)

func update_stamina_ui():
	if stamina_bar:
		stamina_bar.value = player_stamina
		
		#color based on stamina
		if player_stamina > 60:
			stamina_bar.modulate = Color(0.3, 1, 0.3)
		elif player_stamina > 20:
			stamina_bar.modulate = Color(1, 1, 0.3)
		else:
			stamina_bar.modulate = Color(1, 0.3, 0.3)

func game_over():
	is_talking = true
	dialog_box.visible = true
	dialog_text.clear()
	dialog_text.append_text("[color=red]💀 YOU HAVE BEEN CONSUMED BY THE FUNGAL HORROR[/color]\n\n")
	dialog_text.append_text("[color=gray]The spores claim another victim...[/color]\n\n")
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/lose_screen.tscn")

func load_api_key() -> String:
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
