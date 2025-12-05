# NecronomiCore: The Elder Bloom - Project Overview

## 🎮 Project Summary

**NecronomiCore: The Elder Bloom** is a top-down 2D Lovecraftian horror dungeon crawler built in Godot 4.4, featuring a custom C++ GDExtension that integrates OpenAI's GPT API to power three AI-driven game systems.

**Course:** IMG 420 - Game Development  
**Semester:** Fall 2025  
**Engine:** Godot 4.4 with C# and C++ GDExtension

---

## 👥 Team

| Name | Role | Custom Module |
|------|------|---------------|
| **Alexandra Curry** | Sprite Design, Animation, Story | AI-Powered Emotion Dialog |
| **Landon Coonrod** | Story, OpenAI Integration | Random Item Generation |
| **Noah Valdez** | Level Design, Story | Random Roll Generation |

---

## 🎯 Game Design

### Core Concept
A Lovecraftian horror dungeon crawler where players explore overgrown, decaying dungeons filled with fungal horrors. The game emphasizes:
- Careful exploration and resource management
- Environmental hazards and cosmic dread
- High-tension encounters with otherworldly creatures
- Procedural elements powered by AI

### Visual Style
- **Aesthetic:** Lovecraftian + Fungal Overgrowth
- **Theme:** Decay, corruption, eldritch horror
- **Palette:** Muted tones with glowing fungal accents
- **Inspiration:** Real-world mushroom biology + cosmic horror

### Gameplay
- Top-down 2D movement and combat
- Dodge-focused combat (Enter the Gungeon, Binding of Isaac style)
- Progressive difficulty across multiple levels
- AI-generated items, lore, and NPC interactions

---

## 🔧 Technical Architecture

### Two-Layer System

```
┌─────────────────────────────────────────────┐
│          Godot Game (C#)                    │
│  - Player Controller                        │
│  - Level Manager                            │
│  - NPC System                               │
│  - Loot System                              │
└──────────────┬──────────────────────────────┘
               │
┌──────────────▼──────────────────────────────┐
│    NecronomiCoreManager (C# Singleton)      │
│  - Clean API for all three modules          │
│  - Event-based callbacks                    │
│  - API key management                       │
└──────────────┬──────────────────────────────┘
               │
┌──────────────▼──────────────────────────────┐
│    NecronomiCore (C++ GDExtension)          │
│                                             │
│  ┌────────────────────────────────────┐    │
│  │   OpenAIClient (Shared Service)    │    │
│  │   - HTTP/HTTPS via WinHTTP         │    │
│  │   - JSON parsing                   │    │
│  │   - Rate limiting                  │    │
│  │   - Request queuing                │    │
│  └─────────────┬──────────────────────┘    │
│                │                            │
│  ┌─────────────┴──────────────────┐        │
│  │                                 │        │
│  ▼                                 ▼        │
│  ItemGenerationService    EmotionDialogService
│  - Pre-gen items          - NPC personalities │
│  - Rarity system          - Trait-based       │
│  - Stat balancing         - Relationships     │
│                                 │             │
│                                 ▼             │
│                    RandomRollService          │
│                    - Dice & gambling          │
│                    - Modifiers                │
│                    - Critical hits            │
└───────────────────────────────────────────────┘
```

### Technology Stack

**Game Engine:**
- Godot 4.4 (Forward+ Renderer)
- C# for game logic
- C++ GDExtension for AI integration

**Backend:**
- OpenAI GPT-3.5 Turbo API
- Windows WinHTTP (HTTP client)
- Godot JSON Parser

**Build System:**
- SCons (C++ compilation)
- MSBuild (C# compilation)
- godot-cpp bindings

---

## 🎨 Asset Pipeline

### Alexandra's Workflow
1. Design sprites in digital art software
2. Create animations (walk, attack, death, etc.)
3. Build tilesets for environments
4. Export to Godot-compatible formats
5. Integrate with level design

### Deliverables
- Character sprites (player, enemies, NPCs)
- Environmental tilesets (walls, floors, fungal growth)
- Animations for all entities
- UI elements

---

## 🤖 AI Integration (Custom Modules)

### Module 1: Item Generation (Landon)

**Purpose:** Pre-generate thematic loot pools at run start

**How it works:**
1. At new run start, send run config to GPT API
2. AI generates 15-20 items with:
   - Lovecraftian/fungal names
   - Stats (damage, defense, effects)
   - Rarity classifications
   - Flavor text
3. C++ service parses and validates items
4. Items cached for instant loot drops during gameplay

**Example Output:**
```json
{
  "name": "Spore-Touched Blade",
  "type": "weapon",
  "rarity": "rare",
  "damage": 45,
  "flavor_text": "Mycelium pulses with eldritch energy",
  "sprite_hint": "Glowing green blade with fungal growth"
}
```

**C# Usage:**
```csharp
AI.Instance.GenerateItemPool(difficulty: 1, floor: 1);
```

### Module 2: Emotion Dialog (Alexandra)

**Purpose:** Generate emotionally consistent NPC dialogue

**How it works:**
1. Define NPC personality (traits, mood, sanity level)
2. Provide context (location, player actions, history)
3. AI generates dialogue that matches personality
4. Dialog stored in history for continuity

**Example:**
```csharp
var personality = new Dictionary {
    ["archetype"] = "mad scholar",
    ["traits"] = [{"name": "paranoid", "intensity": 0.9}],
    ["sanity_level"] = 0.3
};

// AI Output: "The walls... they whisper your name. 
// You've brought the spores, haven't you? HAVEN'T YOU?!"
```

**Features:**
- Persistent personalities
- Relationship tracking
- Sanity-based variations
- Environmental messages

### Module 3: Random Rolls (Noah)

**Purpose:** Handle all chance-based game mechanics

**How it works:**
1. Fast local RNG for gameplay rolls
2. Optional AI-enhanced flavor text
3. Modifier system (luck, curses, items)
4. Critical success/failure detection

**Use Cases:**
- Gambling minigames
- Loot quality determination
- Critical hit calculations
- Saving throws (sanity checks)

**C# Usage:**
```csharp
int roll = AI.Instance.RollGambling();
if (roll >= 75) 
    Player.Gold += bet * 3; // Big win!
```

---

## 📁 Project Structure

```
img-final/
├── necronomicore/              # C++ GDExtension
│   ├── include/                # Header files (8 files)
│   ├── src/                    # Source files (8 files)
│   ├── bin/                    # Compiled DLLs (gitignored)
│   ├── godot-cpp/              # Godot bindings (gitignored)
│   ├── SConstruct              # Build script
│   ├── BUILD.md                # Build instructions
│   ├── USAGE.md                # API documentation
│   └── README.md               # Technical overview
│
├── assets/                     # Game assets (future)
│   ├── sprites/
│   ├── tilesets/
│   └── animations/
│
├── scenes/                     # Godot scenes (future)
│   ├── levels/
│   ├── ui/
│   └── entities/
│
├── scripts/                    # C# game scripts (future)
│   ├── Player.cs
│   ├── Enemy.cs
│   └── GameManager.cs
│
├── NecronomiCoreManager.cs     # AI system wrapper
├── necronomicore.gdextension   # Extension config
├── api_config.json             # API key (gitignored)
├── project.godot               # Godot project file
├── QUICKSTART.md               # Setup guide
├── IMPLEMENTATION_SUMMARY.md   # What's been built
└── PROJECT_OVERVIEW.md         # This file
```

---

## 🗓️ Development Timeline

### Weeks 1-2: Design & Scaffolding ✅
- [x] Define module responsibilities
- [x] Set up C++ GDExtension project
- [x] Create JSON schemas
- [x] Design C# API surface

### Weeks 3-4: Core Logic (Offline) ✅
- [x] Implement item data structures
- [x] Implement NPC personality system
- [x] Implement roll mechanics
- [x] Test with hard-coded data

### Weeks 5-6: OpenAI Integration ✅
- [x] Shared HTTP client
- [x] API request/response handling
- [x] Pre-generation flow
- [x] Error handling & fallbacks

### Weeks 7-8: Polish & Integration (Current)
- [ ] Build C++ extension
- [ ] Test with real API calls
- [ ] Balance item stats
- [ ] Tune NPC personalities
- [ ] Integrate with level design

### Weeks 9-12: Game Development
- [ ] Create sprites & tilesets
- [ ] Build levels
- [ ] Implement player controller
- [ ] Design enemies
- [ ] Add UI/UX

### Weeks 13-15: Testing & Polish
- [ ] Playtest and balance
- [ ] Bug fixes
- [ ] Performance optimization
- [ ] Final presentation prep

---

## 🎯 Learning Objectives

### Technical Skills
- ✅ GDExtension development (C++)
- ✅ C++/C# interop
- ✅ REST API integration
- ✅ Build systems (SCons)
- ✅ Design patterns
- ⏳ Game architecture
- ⏳ 2D game development

### Soft Skills
- ✅ Team collaboration
- ✅ Technical documentation
- ✅ Project planning
- ⏳ Time management
- ⏳ Presentation skills

---

## 🚧 Current Status

### ✅ Completed
- Full C++ codebase (~2,500 lines)
- All three custom modules
- OpenAI integration layer
- Build configuration
- C# wrapper
- Documentation (6 MD files)
- GDScript prototypes (working)

### 🔨 In Progress
- Building C++ extension
- Testing API integration
- Asset creation
- Level design

### ⏳ Upcoming
- Game mechanics implementation
- Enemy AI
- UI/UX design
- Sound/music
- Playtesting

---

## 💰 Cost Estimates

### OpenAI API Usage
- **Item Generation:** ~$0.01 per run (15-20 items)
- **NPC Dialog:** ~$0.001 per interaction
- **Environmental Messages:** ~$0.0005 per message

**Project Total:** ~$5-10 for development + testing

**Note:** Set spending limits at: https://platform.openai.com/account/billing/limits

---

## 🔐 Security & Best Practices

### API Key Management
- ✅ Keys stored in `api_config.json` (gitignored)
- ✅ Never exposed to GDScript
- ✅ Loaded securely in C#
- ✅ No keys in source control

### Rate Limiting
- ✅ 60 requests/minute automatic throttling
- ✅ Request queuing
- ✅ Error handling

### Offline Mode
- ✅ Fallback content for all systems
- ✅ Game playable without API
- ✅ Graceful degradation

---

## 📊 Success Metrics

### Technical Success
- [ ] Extension builds cleanly
- [ ] All modules functional
- [ ] No memory leaks
- [ ] Stable performance (60 FPS)
- [ ] API requests < 2 seconds

### Game Design Success
- [ ] Cohesive visual style
- [ ] Engaging gameplay loop
- [ ] Effective atmosphere
- [ ] Balanced difficulty
- [ ] Replayability

### Academic Success
- [ ] Meets all project requirements
- [ ] Demonstrates technical competence
- [ ] Strong presentation
- [ ] Complete documentation
- [ ] Team collaboration evident

---

## 🎓 Academic Deliverables

1. **Playable Game Build**
   - Executable for Windows
   - At least 3 complete levels
   - Full AI integration

2. **Technical Documentation**
   - ✅ Architecture overview
   - ✅ API documentation
   - ✅ Build instructions
   - ⏳ Post-mortem analysis

3. **Presentation**
   - Live demo
   - Technical breakdown
   - Team retrospective

4. **Source Code**
   - GitHub repository
   - Clean, commented code
   - README with setup instructions

---

## 🛠️ Tools & Resources

### Development
- **Godot Engine 4.4**
- **Visual Studio 2022** (C++ & C#)
- **VS Code** (documentation)
- **Git/GitHub** (version control)
- **SCons** (build system - use `python -m SCons`)

### AI Services
- **OpenAI Platform** (GPT-3.5 API)
- **Postman** (API testing)

### Art & Design
- **Digital art software** (sprites/tilesets)
- **Godot Editor** (animation, tilemaps)

---

## 📚 Documentation Index

| File | Purpose | Audience |
|------|---------|----------|
| `QUICKSTART.md` | 10-min setup guide | All team |
| `necronomicore/README.md` | Technical overview | Developers |
| `necronomicore/BUILD.md` | Build instructions | Developers |
| `necronomicore/USAGE.md` | API guide | All team |
| `IMPLEMENTATION_SUMMARY.md` | What's built | Team/instructor |
| `PROJECT_OVERVIEW.md` | This file | Team/instructor |

---

## 🎉 What Makes This Special

1. **Real AI Integration** - Not just buzzwords, actual OpenAI API
2. **Professional Architecture** - C++ extension, clean APIs, proper patterns
3. **Team-Specific Modules** - Each member has ownership
4. **Production-Ready** - Build system, docs, error handling
5. **Educational Value** - Demonstrates advanced game dev concepts
6. **Impressive Demo** - Live AI generation in gameplay

---

## 🚀 Next Steps

### For Landon:
1. Read `QUICKSTART.md`
2. Follow `BUILD.md` to compile extension
3. Test item generation
4. Integrate with loot system

### For Alexandra:
1. Continue sprite/tileset work
2. Test dialog system with `USAGE.md`
3. Design NPC personalities
4. Create dialog scenes

### For Noah:
1. Design level layouts
2. Test roll system
3. Implement gambling mechanics
4. Balance difficulty curve

---

**This is going to be an amazing game! 🍄✨**

Good luck, team!

