# NecronomiCore - Game Integration Examples

This folder contains **real-world examples** showing how to integrate the three AI modules into your actual game.

---

## 📁 Example Files

### 1. **example_game_manager.gd** ⭐ **START HERE**
**What it shows:** The recommended way to initialize NecronomiCore

**Key concepts:**
- Initialize AI at game/run start
- Pre-generate item pool ONCE per run
- Store items globally for the entire run
- Handle API failures gracefully with fallbacks

**For:** All team members (game initialization)

**Usage:**
```gdscript
# Attach to a GameManager or RunManager node
# This runs at the start of each game/run
```

---

### 2. **example_loot_chest.gd** (Landon's Module)
**What it shows:** Using pre-generated items for loot drops

**Key concepts:**
- Pick items from the pre-generated pool
- Rarity-based loot tables
- Random item selection
- Adding to player inventory

**For:** Landon (item drops, chests, rewards)

**Usage:**
```gdscript
# Attach to Area2D or StaticBody2D for chests
# Add Sprite2D and Label as children
# Player collision triggers chest opening
```

**How it works:**
1. Player touches chest
2. Rolls for rarity (1-100)
3. Picks an item from pool matching that rarity
4. Adds to inventory

---

### 3. **example_npc_dialog.gd** (Alexandra's Module)
**What it shows:** Creating NPCs with dynamic AI dialog

**Key concepts:**
- Define NPC personalities (traits, mood, sanity)
- Generate context-aware dialog
- Different archetypes (merchant, scholar, cultist)
- Dialog bubbles and UI integration

**For:** Alexandra (NPC interactions, story)

**Usage:**
```gdscript
# Attach to Area2D for NPCs
# Add Sprite2D for NPC visual
# Add UI elements for dialog bubble
# Customize personality in inspector
```

**Customization:**
- Change `npc_name`, `npc_archetype`, `sanity_level` in inspector
- Edit `get_npc_traits()` to add custom personalities
- Modify `determine_mood()` based on game state

---

### 4. **example_gambling_table.gd** (Noah's Module)
**What it shows:** Gambling mechanics using random rolls

**Key concepts:**
- Player interaction with gambling stations
- Risk/reward calculations
- Win/loss outcomes
- Curses on catastrophic failures
- Visual feedback

**For:** Noah (gambling, chance-based mechanics)

**Usage:**
```gdscript
# Attach to Area2D for gambling stations
# Add UI panel for bet display
# Player presses SPACE to gamble
```

**Outcomes:**
- 🎉 Jackpot (2%) → Win 5x
- ✨ Big Win (8%) → Win 3x
- ✅ Win (20%) → Win 2x
- 💚 Small Win (20%) → Win 1x
- ➖ Push (20%) → No change
- ❌ Loss (20%) → Lose bet
- 💀 Catastrophic (10%) → Lose 2x + cursed!

---

### 5. **example_combat_system.gd** (Noah's Module)
**What it shows:** Using rolls for combat mechanics

**Key concepts:**
- Critical hit system
- Damage variance
- Loot quality rolls after enemy death
- Sanity saving throws
- Modifier system (buffs/debuffs)

**For:** Noah (combat, enemy drops)

**Usage:**
```gdscript
# Attach to a CombatManager or GameManager node
# Call functions from player/enemy scripts
```

**Functions you can use:**
- `player_attack()` → Returns damage with crit detection
- `roll_enemy_loot()` → Determines loot rarity
- `roll_sanity_check()` → Horror encounters
- `apply_luck_potion()` → Temporary modifiers

---

## 🎯 Integration Workflow

### **At Game Start** (Use `example_game_manager.gd`):

```gdscript
# 1. Initialize AI system
var ai = NecronomiCore.new()
ai.set_api_key(your_key)
ai.initialize()

# 2. Pre-generate items for this run
ai.request_item_generation(config)

# 3. Wait for items_ready signal

# 4. Start gameplay
```

### **During Gameplay:**

**For Loot Drops** (Landon):
```gdscript
# Use example_loot_chest.gd
# Items come from pre-generated pool (instant, no API calls)
```

**For NPC Interaction** (Alexandra):
```gdscript
# Use example_npc_dialog.gd
# Each dialog = 1 API call (~1-2 seconds)
# Can pre-generate common lines at run start
```

**For Chance Mechanics** (Noah):
```gdscript
# Use example_combat_system.gd or example_gambling_table.gd
# All rolls are instant (local RNG, no API calls)
```

---

## 💡 **Pro Tips**

### Performance
- ✅ **Pre-generate items** at run start (loading screen)
- ✅ **Cache NPC dialog** for repeated interactions
- ✅ **Use local RNG** for all rolls (instant)
- ❌ **Don't** make API calls during combat/gameplay

### Error Handling
Always provide fallbacks:
```gdscript
ai.request_failed.connect(func(error):
    print("AI failed, using fallback content")
    use_procedural_generation()
)
```

### Testing Without API
For development without API calls:
```gdscript
# Comment out AI initialization
# Use mock data instead
var mock_items = create_mock_items()
```

---

## 📚 **See Also**

- **tests/test_cpp_extension.gd** - Simple item generation test
- **tests/test_dialog_module.gd** - NPC personality test
- **tests/test_roll_module.gd** - All roll types test
- **docs/USAGE.md** - Complete API reference

---

## 🎮 **Example Game Flow**

```
1. Main Menu
   └→ Start New Run
       │
2. GameManager initializes
   ├→ Create AI core
   ├→ Load API key
   ├→ Request item generation
   └→ Wait for items_ready
       │
3. Gameplay Starts
   ├→ Player explores levels
   ├→ Defeats enemies → Loot drops (from pool)
   ├→ Opens chests → Items (from pool)
   ├→ Talks to NPCs → AI dialog generated
   └→ Gambles → Roll-based outcomes
       │
4. Run Ends
   └→ Return to menu or start new run
```

---

## 🚀 **Quick Test**

Want to test an example?

1. Open Godot
2. Create a new scene (Node2D)
3. Attach one of the example scripts
4. Add required child nodes (Sprite2D, Label, etc.)
5. Press F5

Each example is self-contained and demonstrates a complete feature!

---

**These examples are production-ready code your team can build upon!** 🎉

