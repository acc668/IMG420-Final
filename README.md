# NecronomiCore: The Elder Bloom

A Lovecraftian dungeon crawler with AI-powered content generation. Made in Godot 4.4 with a custom C++ extension.

## Team Members

- **Alexandra Curry** - Story, Sprite Design, Animation, Tilesets, AI-Powered Emotion Dialogue Module
- **Landon Coonrod** - API Setup, Story, Random Item Generation Module
- **Noah Valdez** - Level Design, Story, Random Roll Generation Module

---

## Project Description

**NecronomiCore: The Elder Bloom** is a 2D top-down dungeon crawler inspired by *Enter the Gungeon* and *The Binding of Isaac*. It blends Lovecraftian cosmic horror with an overgrown fungal dungeon aesthetic where nature has reclaimed forgotten ruins.

This project features a **custom C++ GDExtension** that integrates OpenAI's GPT API to power three dynamic game systems:

- **AI-Generated Items** - Procedurally created weapons, armor, and artifacts with Lovecraftian themes
- **Emotion-Driven NPCs** - Dynamic dialogue based on persistent personalities and sanity levels
- **Contextual Random Rolls** - Gambling, loot drops, and critical hits with atmospheric flavor text

---

## Features

### AI-Powered Systems

**Random Item Generation** (Landon's Module)
- Pre-generates 10-20 themed items at run start
- Lovecraftian fungal naming (e.g., "Mindflayer's Mycelium Staff", "Void Mycelium Blade")
- Balanced stats by rarity (Common → Legendary → Cursed)
- Unique flavor text and sprite descriptions
- Offline fallback system

**Emotion-Based NPC Dialogue** (Alexandra's Module)
- NPCs with persistent personalities and traits
- Mood and sanity-based dialog variations
- Relationship tracking (NPCs remember player actions)
- Context-aware responses
- Environmental message generation for wall writings

**Random Roll System** (Noah's Module)
- Fast local RNG for all chance-based mechanics
- Gambling minigames
- Loot rarity determination
- Critical hit/miss system
- Sanity checks and saving throws
- Modifier system (luck, curses, buffs)

### Technical Features

- Pure C++ GDExtension (high performance)
- Windows native HTTP (WinHTTP)
- Automatic rate limiting
- Graceful error handling and fallbacks
- Comprehensive documentation

---

## Quick Start

### For Players

1. Download the latest release
2. Open in Godot 4.4
3. Get an OpenAI API key: https://platform.openai.com/api-keys
4. Copy `api_config.json.example` to `api_config.json` and add your key
5. Run the game!

### For Developers

See **[docs/SETUP_FOR_DEVELOPERS.md](docs/SETUP_FOR_DEVELOPERS.md)** for complete build instructions.

**Quick build:**

```bash
# Clone the repo
git clone https://github.com/acc668/IMG420-Final.git
cd IMG420-Final

# Set up API key
cd game_prototype
copy api_config.json.example api_config.json
# Edit api_config.json with your key

# Build the C++ extension
cd ..\module_source\necronomicore
git clone https://github.com/godotengine/godot-cpp
cd godot-cpp && git checkout 4.4
python -m SCons platform=windows target=template_debug
cd ..
python -m SCons platform=windows target=template_debug

# Open game_prototype folder in Godot 4.4
```

---

## Documentation

- **[QUICKSTART.md](docs/QUICKSTART.md)** - 10-minute setup guide
- **[SETUP_FOR_DEVELOPERS.md](docs/SETUP_FOR_DEVELOPERS.md)** - Developer setup
- **[BUILD_INSTRUCTIONS.md](docs/BUILD_INSTRUCTIONS.md)** - Detailed build guide
- **[API_REFERENCE.md](docs/API_REFERENCE.md)** - API usage for all 3 modules
- **[USER_GUIDE.md](docs/USER_GUIDE.md)** - How to use in your game
- **[IMPLEMENTATION_SUMMARY.md](docs/IMPLEMENTATION_SUMMARY.md)** - Technical details
- **[PROJECT_OVERVIEW.md](docs/PROJECT_OVERVIEW.md)** - Full project specs
- **[GIT_WORKFLOW.md](docs/GIT_WORKFLOW.md)** - Git collaboration guide

---

## Usage Example

```gdscript
var ai = NecronomiCore.new()
add_child(ai)
ai.set_api_key(your_key)
ai.initialize()

# Generate items
ai.item_pool_ready.connect(func(items):
    for item in items:
        print(item["name"])
)

ai.request_item_generation({
    "difficulty": 1,
    "theme": "lovecraftian fungal dungeon"
})
```

Check `game_prototype/scenes/topdown_game.gd` for a complete working example.

## Project Structure

```
IMG420-Final/
├── module_source/necronomicore/   # C++ extension code
├── game_prototype/                # Godot project
│   └── scenes/topdown_game.tscn   # Main game
└── docs/                          # Documentation
```

## API Costs

Pretty cheap:
- Item generation: ~$0.01 per game start
- Dialog: ~$0.001 per conversation
- Random rolls: Free (local)

We spent maybe $5-10 total during development.

Set spending limits at https://platform.openai.com/account/billing/limits

## Security Note

Don't commit `api_config.json` - it's in .gitignore for a reason. Each person needs their own API key.

## Tech Stack

- Godot 4.4
- C++ GDExtension
- OpenAI GPT-3.5
- WinHTTP for HTTP requests
- SCons for building

## Stats

- ~2,500 lines of C++
- 8 header files, 8 source files
- Built for IMG 420 - Game Development (Fall 2025)

## Docs

- BUILD.md - How to build the extension
- docs/QUICKSTART.md - Get started fast
- docs/SETUP_FOR_DEVELOPERS.md - Full setup
- docs/IMPLEMENTATION_SUMMARY.md - Technical details
- docs/PROJECT_OVERVIEW.md - Original project specs

## License

See LICENSE file.

## Links

- Repository: https://github.com/acc668/IMG420-Final
- Godot: https://godotengine.org/
- OpenAI: https://platform.openai.com/

## Resources Used

- some code was directly ripped from previous projects 
- we used Copilot AI for better formatting, and defining clear code
- ChatGPT was used to connect API and general ideas/examples for scripts
