# NecronomiCore: AI-Powered Game Systems for Godot

A C++ GDExtension for Godot 4.4 that integrates OpenAI's GPT API to power dynamic item generation, emotion-driven NPC dialog, and contextual random rolls for "NecronomiCore: The Elder Bloom" dungeon crawler.

## 🎮 Features

### 🗡️ **Item Generation Service** (Landon's Module)
- Pre-generates themed item pools at run start
- AI creates items with names, stats, and lore
- Organized by rarity (Common → Legendary → Cursed)
- Lovecraftian fungal aesthetic
- Fallback system for offline mode

### 💬 **Emotion Dialog Service** (Alexandra's Module)
- NPCs with persistent personalities and traits
- Context-aware, emotionally consistent dialog
- Relationship system (NPCs remember player actions)
- Sanity-based interactions
- Environmental message generation

### 🎲 **Random Roll Service** (Noah's Module)
- Gambling mechanics with AI-generated flavor text
- Critical hit/miss system
- Loot quality determination
- Modifier system (luck, curses, buffs)
- Fast local RNG with optional AI enhancement

## 📁 Project Structure

```
necronomicore/
├── include/           # C++ header files
│   ├── necronomi_core.h
│   ├── openai_client.h
│   ├── item_generation_service.h
│   ├── emotion_dialog_service.h
│   ├── random_roll_service.h
│   ├── json_utils.h
│   └── http_client.h
├── src/              # C++ implementation files
│   ├── register_types.cpp
│   ├── necronomi_core.cpp
│   ├── openai_client.cpp
│   ├── http_client.cpp
│   ├── json_utils.cpp
│   ├── item_generation_service.cpp
│   ├── emotion_dialog_service.cpp
│   └── random_roll_service.cpp
├── bin/              # Compiled DLLs (generated)
├── lib/              # Third-party libraries
├── godot-cpp/        # Godot C++ bindings (git submodule)
├── SConstruct        # Build configuration
├── BUILD.md          # Build instructions
├── USAGE.md          # Usage guide for team
└── README.md         # This file

necronomicore.gdextension  # Godot extension config
NecronomiCoreManager.cs    # C# wrapper for easy use
api_config.json            # Your OpenAI API key (gitignored)
```

## 🚀 Quick Start

### 1. Get Dependencies

You need:
- **Python 3.6+** and **SCons** (`pip install scons`)
- **Visual Studio 2019/2022** with C++ tools
- **Git**

### 2. Clone godot-cpp

```bash
cd necronomicore
git clone https://github.com/godotengine/godot-cpp
cd godot-cpp
git checkout 4.4
```

### 3. Build godot-cpp

```bash
# From godot-cpp directory
scons platform=windows target=template_debug
scons platform=windows target=template_release
```

### 4. Build NecronomiCore

```bash
# From necronomicore directory
cd ..
scons platform=windows target=template_debug
scons platform=windows target=template_release
```

### 5. Configure API Key

Create `api_config.json` in project root:

```json
{
    "openai_api_key": "sk-your-actual-api-key-here"
}
```

### 6. Add to Godot

1. Open project in Godot
2. Go to **Project > Project Settings > Autoload**
3. Add `NecronomiCoreManager.cs` as `AI`
4. Test it!

```csharp
// In any script
public override void _Ready()
{
    AI.Instance.GenerateItemPool(1, 1);
}
```

## 📖 Documentation

- **[BUILD.md](BUILD.md)** - Detailed build instructions
- **[USAGE.md](USAGE.md)** - Complete usage guide for all three modules
- **[Design Document](../PROJECT_DESIGN.md)** - Full project specifications

## 🏗️ Architecture

### C++ Layer (Native Performance)

```
NecronomiCore (Singleton)
    ├─ OpenAIClient (Shared HTTP Service)
    ├─ ItemGenerationService
    ├─ EmotionDialogService
    └─ RandomRollService
```

### C# Layer (Easy Game Integration)

```csharp
NecronomiCoreManager (Autoload Singleton)
    ├─ Events: OnItemPoolReady, OnDialogReady, OnRequestFailed
    ├─ GenerateItemPool(difficulty, floor, theme)
    ├─ RequestNPCDialog(name, context, personality)
    └─ GenerateRoll(min, max, context)
```

## 💡 Usage Examples

### Landon: Generate Items

```csharp
AI.Instance.OnItemPoolReady += (items) => {
    foreach (var item in items) {
        var dict = item.As<Godot.Collections.Dictionary>();
        GD.Print($"Generated: {dict["name"]}");
    }
};

AI.Instance.GenerateItemPool(difficulty: 1, floor: 1);
```

### Alexandra: NPC Dialog

```csharp
var personality = new Godot.Collections.Dictionary {
    ["npc_name"] = "Mad Merchant",
    ["archetype"] = "suspicious vendor",
    ["current_mood"] = "paranoid",
    ["sanity_level"] = 0.3f
};

AI.Instance.OnDialogReady += (dialog) => {
    ShowDialog(dialog);
};

AI.Instance.RequestNPCDialog("Mad Merchant", "player approaches", personality);
```

### Noah: Random Rolls

```csharp
// Gambling
int roll = AI.Instance.RollGambling();
if (roll >= 75) {
    Player.Gold += betAmount * 3;
}

// Loot quality
int quality = AI.Instance.RollLootQuality();
var rarity = DetermineRarity(quality);
```

## 🔧 Technical Details

### HTTP Client
- **Windows:** WinHTTP (native, no dependencies)
- **Future:** libcurl for cross-platform support

### JSON Parsing
- Uses Godot's built-in JSON parser
- Seamless conversion between C++ and GDScript/C#

### Rate Limiting
- Automatic 60 requests/minute throttling
- Queue system for async requests
- Prevents API overuse

### Error Handling
- Fallback content when API unavailable
- Graceful degradation
- Detailed error messages

## 🎯 Design Philosophy

1. **Pre-generation over Real-time**
   - Items generated at run start, not mid-combat
   - No gameplay stutter from network calls

2. **Offline-First**
   - Fallback systems for all features
   - Game playable without API

3. **Type Safety**
   - Strongly typed C++ structs
   - Clean C# API surface

4. **Team-Friendly**
   - Each module is independent
   - Simple, documented API
   - Clear separation of concerns

## 🛠️ Development Workflow

1. Edit C++ code
2. Rebuild: `scons platform=windows target=template_debug`
3. **Close and reopen Godot** (extensions aren't hot-reloadable)
4. Test changes

## 🐛 Troubleshooting

### Extension won't load
- Check `.gdextension` file paths
- Verify DLLs exist in `bin/` folder
- Look for errors in Godot console

### API requests fail
- Verify API key is correct
- Check `api_config.json` format
- Ensure API key has credits

### Build errors
- Make sure godot-cpp is on branch 4.4
- Verify Visual Studio C++ tools installed
- Try clean build: `scons -c && scons`

## 📊 Performance

- **Item Generation:** ~2-5 seconds for 15-20 items (one-time at run start)
- **Dialog Generation:** ~1-3 seconds per response
- **Random Rolls:** Instant (local RNG, optional AI flavor)

## 🔒 Security

- API keys never exposed to GDScript/C#
- All HTTP in C++ layer
- Config files in `.gitignore`
- No keys in source control

## 🎓 Learning Resources

- [Godot GDExtension Docs](https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/what_is_gdextension.html)
- [OpenAI API Reference](https://platform.openai.com/docs/api-reference)
- [SCons User Manual](https://scons.org/doc/production/HTML/scons-user.html)

## 👥 Team Roles

- **Landon Coonrod** - Item Generation Module, OpenAI Integration
- **Alexandra Curry** - Emotion Dialog Module, NPC Personalities  
- **Noah Valdez** - Random Roll Module, Level Design Integration

## 📝 License

Created for IMG 420 Final Project - Fall 2025  
"NecronomiCore: The Elder Bloom"

## 🙏 Acknowledgments

- Built with Godot Engine 4.4
- Powered by OpenAI's GPT-3.5
- Uses godot-cpp bindings

---

**Need help?** Check `USAGE.md` or `BUILD.md`  
**Found a bug?** Check the project repository issues

