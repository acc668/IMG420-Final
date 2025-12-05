# NecronomiCore Test Suite

**Status:** ✅ All systems ready for testing!

This directory contains test scenes and scripts to verify the functionality of the NecronomiCore C++ GDExtension, including:
- ✅ C++ Extension Loading
- ✅ Random Roll Generation (Noah's Module)  
- ✅ Item Generation (Liam's Module)
- ✅ NPC Dialog System (Alexandra's Module)

---

## 🚀 Quick Start (5 Steps)

1. **Open Godot Engine** (4.4+)
2. **Import project:** `game_prototype/project.godot`
3. **Open scene:** `res://tests/run_all_tests.tscn`
4. **Press F6** (Run Current Scene)
5. **Watch Output panel** for results

**Expected Runtime:** ~27 seconds for all tests

---

## 📋 Prerequisites

### 1. Build the C++ Extension ✅

The C++ extension has been built and is ready to use:
```
game_prototype/necronomicore/bin/libnecronomicore.windows.template_debug.x86_64.dll
```

To rebuild if needed:
```bash
cd module_source/necronomicore
python -m SCons platform=windows target=template_debug
```

### 2. Configure API Key ✅

Copy `api_config.json.example` to `api_config.json` and add your OpenAI API key:

```json
{
    "openai_api_key": "sk-your-actual-api-key-here"
}
```

**Note:** The Roll Module test does NOT require an API key (local computation). Only Item Generation and Dialog tests need the API key.

### 3. Verify Setup

Run the verification script before testing:

```powershell
cd game_prototype/tests
.\verify_setup.ps1
```

Should display: `SUCCESS: All checks passed!`

---

## 🧪 Test Modules

### Test 1: C++ Extension & Item Generation (`test_cpp_extension.tscn`)

**Tests:** Liam's item generation service  
**Duration:** ~10 seconds  
**Requires API:** ✅ Yes

**What it tests:**
- Extension loading and initialization
- OpenAI API integration
- Procedural item generation with AI
- JSON parsing and data structures
- Signal handling (item_pool_ready, request_failed)

**Expected Output:**
```
✅ NecronomiCore extension loaded!
✅ Initialized: true
🔄 Requesting item generation...
🎉 SUCCESS! Generated 10 items:
  📦 Eldritch Sporeblade
     Type: weapon | Rarity: rare
     Damage: 10 | Defense: 0
     Flavor: The blade hums with otherworldly energy
```

### Test 2: Random Roll Module (`test_roll_module.tscn`)

**Tests:** Noah's random roll service  
**Duration:** ~2 seconds  
**Requires API:** ❌ No

**What it tests:**
- Basic random roll generation (1-100, 1-20)
- Gambling mechanics (betting, payouts, jackpots)
- Combat loot rarity determination
- Sanity check saving throws
- Critical hit detection (95+ = crit)

**Expected Output:**
```
🎲 Test 1: Basic Random Rolls
  Roll #1: 42 (out of 100)
  Roll #2: 87 (out of 100)

🎰 Test 2: Gambling Rolls
  Betting 50 gold on the Fungal Dice Game...
  Game #1: Rolled 92 → 🎉 JACKPOT! Won 150 gold!
  Game #2: Rolled 9 → 💀 CATASTROPHIC LOSS! Lost 100 gold + cursed!

⚔️ Test 3: Combat Rolls (Loot Quality)
  Enemy #1: Rolled 95 → 💜 EPIC loot
  Enemy #2: Rolled 68 → 💚 UNCOMMON loot

💀 Test 4: Sanity Checks (Saving Throws)
  Check #1: Rolled 11/20 → ❌ Failed - Sanity damage
  Check #2: Rolled 19/20 → ✅ Success - Sanity preserved

✨ Test 5: Critical Hits
  Attack #1: Rolled 25 → 25 damage
  Attack #2: Rolled 97 → 50 damage 💥 CRITICAL HIT!
```

### Test 3: Emotion Dialog Module (`test_dialog_module.tscn`)

**Tests:** Alexandra's emotion dialog service  
**Duration:** ~15 seconds  
**Requires API:** ✅ Yes

**What it tests:**
- Context-aware NPC dialog generation
- Personality-driven responses
- Emotion and sanity level integration
- Trait-based dialog variation
- Multiple NPC archetypes

**Expected Output:**
```
📝 Test 1: Paranoid Merchant (Suspicious, Low Sanity)
💬 NPC Says:
"Stay back! I see how you're eyeing my spores... Everyone wants 
to steal from old Morgrith. The shadows whisper lies about me, 
but I know the truth! You want something? Pay double or get lost!"

📝 Test 2: Wise Scholar (Calm, High Sanity)
💬 NPC Says:
"Ah, a curious mind seeks the truth in these fungal depths. 
The spores whisper ancient secrets to those who listen..."
```

---

## 🎯 Running Tests

### Option 1: Run All Tests (Recommended)

Open `run_all_tests.tscn` in Godot and press **F6**.

This executes all test modules in sequence with proper timing and reporting.

**Total Runtime:**
- Test 1 (Item Generation): ~10 seconds
- Test 2 (Roll Module): ~2 seconds
- Test 3 (Dialog Module): ~15 seconds
- **Total: ~27 seconds**

### Option 2: Run Individual Tests

Open any specific test scene and press **F6**:

- `test_roll_module.tscn` - Quick test, no API needed (2 seconds)
- `test_cpp_extension.tscn` - Item generation (10 seconds)
- `test_dialog_module.tscn` - NPC dialog (15 seconds)

Useful for debugging specific modules or testing without an API key (Roll Module).

---

## ✅ Understanding Test Results

### Success Indicators
- ✅ Green checkmarks
- 🎉 "SUCCESS!" messages
- Generated content displayed properly
- No ❌ error messages
- Appropriate variety in generated content

### Failure Indicators
- ❌ Red X marks
- "ERROR:" messages
- "Failed to..." messages
- Missing or incomplete output
- Extension loading failures

---

## 🔧 Troubleshooting

### Extension Won't Load

**Symptom:** `❌ Failed to create NecronomiCore`

**Solutions:**

1. **Restart Godot** - Extensions aren't hot-reloadable
2. **Check DLL exists:**
   ```
   game_prototype/necronomicore/bin/libnecronomicore.windows.template_debug.x86_64.dll
   ```
3. **Verify .gdextension file** paths are correct
4. **Rebuild the extension:**
   ```bash
   cd module_source/necronomicore
   python -m SCons -c
   python -m SCons platform=windows target=template_debug
   ```
5. **Copy DLL to game_prototype:**
   ```bash
   cd game_prototype
   mkdir necronomicore\bin
   copy ..\module_source\necronomicore\bin\*.dll necronomicore\bin\
   ```

### API Key Issues

**Symptom:** `❌ No API key found`

**Solutions:**

1. Verify `api_config.json` exists (not just `.example`)
2. Check file contents:
   ```json
   {
       "openai_api_key": "sk-proj-..."
   }
   ```
3. Ensure the key is valid and has API credits
4. Test with Roll Module first (doesn't need API)

### Test Hangs or Times Out

**Symptom:** Test runs but produces no output

**Possible Causes:**
- Network issues (API tests need internet)
- Invalid API key
- OpenAI rate limiting
- Firewall blocking API requests

**Solutions:**
- Run the Roll Module test first (no API needed)
- Check Godot Output panel for error messages
- Verify internet connection
- Check OpenAI API status and credits
- Wait longer (API calls can take 5-10 seconds)

### JSON Parsing Errors

**Symptom:** `❌ ERROR: [JSON parsing failed]`

**Explanation:**  
OpenAI's response wasn't in the expected format. The C++ extension is working, but the AI prompt may need tuning.

**Solutions:**
- Try running the test again (GPT responses vary)
- This is expected occasional behavior
- Prompt engineering in C++ code can improve consistency
- Check that response follows expected JSON schema

### Godot Console Errors

**Check for:**
- Extension loading messages at Godot startup
- Runtime errors during test execution
- File path resolution issues
- Signal connection errors

**Debug with:**
```gdscript
print("Debug: ", variable_name)
```

---

## 📊 Performance Benchmarks

Expected response times:

| Module | Time | Notes |
|--------|------|-------|
| **Roll Generation** | < 1ms | Local computation, instant |
| **Item Generation** | 2-5 seconds | OpenAI API call |
| **Dialog Generation** | 1-3 seconds | OpenAI API call per NPC |

API times depend on:
- Network latency
- OpenAI server load
- Request complexity
- Token count in prompt/response

---

## 🏗️ Test Architecture

All tests follow this consistent pattern:

```gdscript
extends Node2D

func _ready():
    # 1. Create NecronomiCore instance
    var ai_core = NecronomiCore.new()
    add_child(ai_core)
    
    # 2. Load API key and initialize
    var api_key = load_api_key()
    ai_core.set_api_key(api_key)
    ai_core.initialize()
    
    # 3. Connect signals
    ai_core.some_signal.connect(_on_callback)
    
    # 4. Make service request
    ai_core.request_something(params)

func load_api_key():
    if FileAccess.file_exists("res://api_config.json"):
        var file = FileAccess.open("res://api_config.json", FileAccess.READ)
        var json_string = file.get_as_text()
        file.close()
        var json = JSON.new()
        if json.parse(json_string) == OK:
            return json.data["openai_api_key"]
    return ""

func _on_callback(data):
    # Handle response
    print("Result:", data)
```

This ensures consistent testing across all modules.

---

## ➕ Adding New Tests

To add a new test module:

1. **Create test script** (e.g., `test_new_feature.gd`)
2. **Create test scene** (e.g., `test_new_feature.tscn`)
3. **Add to master runner** in `run_all_tests.gd`:
   ```gdscript
   var tests = [
       # ... existing tests ...
       {
           "name": "New Feature Test",
           "scene": "res://tests/test_new_feature.tscn",
           "wait_time": 5.0
       }
   ]
   ```
4. **Document in this README** with expected output
5. **Update verification script** if needed

---

## 🔄 Continuous Integration

Run tests headlessly for CI/CD:

```bash
godot --headless --script res://tests/run_all_tests.tscn
```

**Note:** AI tests require a valid API key in the environment.

For CI pipelines, consider:
- Setting API key via environment variable
- Implementing test result parsing
- Adding timeout handling
- Mocking API responses for faster testing

---

## 📚 Additional Resources

### Project Documentation
- `/docs/QUICKSTART.md` - Getting started guide
- `/docs/API_REFERENCE.md` - Complete API documentation
- `/docs/BUILD_INSTRUCTIONS.md` - Build troubleshooting
- `/docs/USER_GUIDE.md` - How to use in your game
- `/module_source/necronomicore/USAGE.md` - C++ extension usage

### Example Integration
- `game_prototype/scenes/example_combat_system.gd` - Combat integration
- `game_prototype/scenes/example_gambling_table.gd` - Gambling mechanics
- `game_prototype/scenes/example_loot_chest.gd` - Loot generation
- `game_prototype/scenes/example_npc_dialog.gd` - Dialog system
- `game_prototype/scenes/example_game_manager.gd` - Overall integration

### Build Documentation
- `module_source/necronomicore/BUILD.md` - Detailed build instructions
- `BUILD_AND_TEST_SUMMARY.md` - Complete build/test summary (root)

---

## 🤝 Contributing

Found a bug? Want to add tests?

1. Fork the repository
2. Create a feature branch
3. Add your test in this folder
4. Update this README
5. Submit a pull request

### Test Contribution Guidelines
- Follow the existing test pattern
- Include clear expected output
- Document what the test validates
- Add appropriate wait times for API calls
- Test locally before submitting

---

## 🐛 Known Issues

- **Occasional JSON parsing failures** with OpenAI responses (GPT variance)
- **Extensions not hot-reloadable** - Godot restart required after rebuild
- **Windows-only build** - macOS/Linux support planned

---

## 📝 License

Part of the NecronomiCore project. See LICENSE in the root directory.

---

## 🎮 Next Steps

After successful test completion:

1. ✅ **Review test output** - Ensure all modules show success
2. 🎨 **Explore examples** in `game_prototype/scenes/`
3. 📖 **Read API docs** in `/docs/API_REFERENCE.md`
4. 🎯 **Build your game** - Use the tested services
5. ⚙️ **Customize prompts** - Tune AI behavior in C++ source

---

**Ready to test! Open Godot and press F6!** 🎮✨

**Questions?** See the documentation links above or check the Godot Output panel for detailed error messages.
