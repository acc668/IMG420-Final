# NecronomiCore Usage Guide

Complete guide for using the NecronomiCore AI system in your Godot project.

## Setup

### 1. Add to Autoload

In Godot Editor:
1. Go to **Project > Project Settings > Autoload**
2. Add `NecronomiCoreManager.cs`
3. Set name to: `AI`
4. Click "Add"

### 2. Configure API Key

Create or edit `api_config.json` in your project root:

```json
{
    "openai_api_key": "sk-your-actual-api-key-here"
}
```

**Important:** Add to `.gitignore`!

## For Landon: Item Generation

### Generate Items at Run Start

```csharp
public partial class RunManager : Node
{
    public override void _Ready()
    {
        // Listen for when items are ready
        AI.Instance.OnItemPoolReady += HandleItemsReady;
        
        // Request item generation
        AI.Instance.GenerateItemPool(
            difficulty: 1,
            floor: 1,
            theme: "lovecraftian fungal dungeon"
        );
    }
    
    private void HandleItemsReady(Godot.Collections.Array items)
    {
        GD.Print($"Item pool ready with {items.Count} items!");
        
        foreach (var itemVar in items)
        {
            var item = itemVar.As<Godot.Collections.Dictionary>();
            GD.Print($"Item: {item["name"]}, Rarity: {item["rarity"]}");
        }
    }
}
```

### Item Structure

Each item in the array is a Dictionary with:

```csharp
{
    "name": "Spore-Touched Blade",
    "description": "A weapon infused with fungal essence",
    "type": 0, // 0=Weapon, 1=Armor, 2=Consumable, 3=Relic, 4=Artifact
    "rarity": 2, // 0=Common, 1=Uncommon, 2=Rare, 3=Epic, 4=Legendary, 5=Cursed
    "damage": 25,
    "defense": 0,
    "healing": 0,
    "cooldown": 1.5,
    "flavor_text": "Mycelium pulses with eldritch energy",
    "sprite_hint": "Glowing green blade with fungal growths"
}
```

### Example: Loot Chest

```csharp
public partial class LootChest : Node2D
{
    public void OpenChest()
    {
        // Use the roll service to determine rarity
        int rarityRoll = AI.Instance.RollLootQuality();
        
        // Get item based on roll
        // Items are pre-generated, this just picks one
        AI.Instance.OnItemPoolReady += (items) => {
            var item = GetRandomItemByRarity(items, rarityRoll);
            GD.Print($"Found: {item["name"]}!");
        };
    }
}
```

## For Alexandra: NPC Dialog

### Create an NPC with Personality

```csharp
public partial class MadMerchant : NPC
{
    private Godot.Collections.Dictionary _personality;
    
    public override void _Ready()
    {
        _personality = new Godot.Collections.Dictionary
        {
            ["npc_name"] = "Fungus Vendor",
            ["archetype"] = "mad merchant",
            ["current_mood"] = "suspicious",
            ["sanity_level"] = 0.3f, // Low sanity = more erratic
            ["traits"] = new Godot.Collections.Array
            {
                new Godot.Collections.Dictionary
                {
                    ["name"] = "paranoid",
                    ["intensity"] = 0.9f,
                    ["description"] = "Believes customers are spies"
                },
                new Godot.Collections.Dictionary
                {
                    ["name"] = "greedy",
                    ["intensity"] = 0.7f,
                    ["description"] = "Obsessed with profit"
                }
            }
        };
        
        // Listen for dialog
        AI.Instance.OnDialogReady += HandleDialog;
    }
    
    public void Interact()
    {
        var context = new Godot.Collections.Dictionary
        {
            ["location"] = "fungal marketplace",
            ["first_encounter"] = true,
            ["player_sanity"] = 100
        };
        
        AI.Instance.RequestNPCDialog("Fungus Vendor", "player approaches", _personality);
    }
    
    private void HandleDialog(string dialogText)
    {
        ShowDialogBubble(dialogText);
        GD.Print($"NPC says: {dialogText}");
    }
}
```

### Quick Dialog Request

```csharp
// Simple version for one-off dialog
AI.Instance.RequestNPCDialog(
    npcName: "Mysterious Voice",
    mood: "ominous",
    archetype: "eldritch horror"
);
```

### Environmental Messages

Perfect for wall writings, signs, cryptic messages:

```csharp
// Note: This would need to be added to the C# wrapper, but the C++ backend supports it!
// For now, use RequestNPCDialog with archetype "ancient_writing"
AI.Instance.RequestNPCDialog(
    npcName: "Wall Inscription",
    mood: "cryptic",
    archetype: "ancient carved message"
);
```

## For Noah: Random Rolls

### Basic Rolls

```csharp
// Simple random number
int roll = AI.Instance.GenerateRoll(1, 100);

// Dice roll
int d20 = AI.Instance.GenerateRoll(1, 20, "attack roll");
```

### Gambling System

```csharp
public partial class GamblingTable : Node2D
{
    public void PlaceBet(int amount)
    {
        int roll = AI.Instance.RollGambling();
        
        if (roll >= 75)
        {
            GD.Print("Critical win!");
            Player.Gold += amount * 3;
        }
        else if (roll >= 50)
        {
            GD.Print("You win!");
            Player.Gold += amount;
        }
        else if (roll <= 10)
        {
            GD.Print("Catastrophic loss!");
            Player.Gold -= amount * 2;
            Player.AddCurse("bad_luck");
        }
        else
        {
            GD.Print("You lose.");
            Player.Gold -= amount;
        }
    }
}
```

### Loot Quality Rolls

```csharp
public int DetermineLootRarity()
{
    int roll = AI.Instance.RollLootQuality();
    
    // Map roll to rarity
    if (roll >= 95) return 4; // Legendary
    if (roll >= 80) return 3; // Epic
    if (roll >= 60) return 2; // Rare
    if (roll >= 30) return 1; // Uncommon
    return 0; // Common
}
```

### Critical Hit System

```csharp
public void PlayerAttack(Enemy enemy)
{
    int baseroll = AI.Instance.GenerateRoll(1, 100, "attack");
    
    bool isCritical = baseRoll >= 95;
    int damage = isCritical ? weaponDamage * 2 : weaponDamage;
    
    enemy.TakeDamage(damage);
    
    if (isCritical)
    {
        ShowCriticalEffect();
    }
}
```

## Complete Example: Run Start Flow

```csharp
public partial class GameManager : Node
{
    private bool _itemsReady = false;
    
    public override void _Ready()
    {
        // Subscribe to events
        AI.Instance.OnItemPoolReady += OnItemsReady;
        AI.Instance.OnRequestFailed += OnAIError;
        
        StartNewRun();
    }
    
    public void StartNewRun()
    {
        int difficulty = CalculateDifficulty();
        int floor = CurrentFloor;
        
        // Pre-generate items for this run
        AI.Instance.GenerateItemPool(difficulty, floor);
        
        ShowLoadingScreen("Generating realm...");
    }
    
    private void OnItemsReady(Godot.Collections.Array items)
    {
        _itemsReady = true;
        GD.Print($"Run ready! {items.Count} items generated.");
        
        HideLoadingScreen();
        StartGameplay();
    }
    
    private void OnAIError(string error)
    {
        GD.PushError($"AI System Error: {error}");
        
        // Fallback: Use procedurally generated items instead
        UseFallbackItemGeneration();
        _itemsReady = true;
        StartGameplay();
    }
}
```

## Error Handling

Always handle potential failures:

```csharp
AI.Instance.OnRequestFailed += (error) => {
    GD.PushError($"AI Request failed: {error}");
    
    // Implement fallback behavior
    UseOfflineContent();
};
```

## Performance Tips

1. **Generate items at run start**, not during gameplay
2. **Cache dialog** for repeated interactions
3. **Use local RNG for non-critical rolls** (only use AI when you want flavor text)
4. **Pre-generate** all AI content during loading screens

## Testing Without API

During development, you can test without API calls:

```csharp
// In your test scene
public override void _Ready()
{
    // Don't initialize AI
    // Use fallback systems
    
    var mockItems = CreateMockItems();
    OnItemsReady(mockItems);
}
```

## Debugging

Enable verbose logging:

```csharp
// In NecronomiCoreManager
GD.Print($"AI initialized: {_isInitialized}");
GD.Print($"Making request: {configType}");
```

Check Godot console for:
- ✅ "NecronomiCore initialized: True"
- ❌ "Failed to load API key"
- ❌ "Request failed with response code: 401" (bad API key)

## Next Steps

1. Build the C++ extension (see `BUILD.md`)
2. Test with your API key
3. Integrate into your game systems
4. Implement fallback content for offline mode

Happy coding! 🍄

