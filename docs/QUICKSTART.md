# NecronomiCore Quick Start Guide

Get up and running with the AI-powered C++ GDExtension in 10 minutes!

## ⚡ Super Quick Setup (Testing with GDScript Prototype)

**Want to test the OpenAI integration RIGHT NOW?** You already have a working prototype!

### Option 1: Test with GDScript Version (Already Done!)

1. Open `openai_example.tscn` in Godot
2. Run it (F5)
3. Type a prompt and click "Send Request"

✅ **This works RIGHT NOW** and proves your API key is valid!

---

## 🔨 Building the C++ GDExtension (Production Version)

Follow these steps to build the high-performance C++ version.

### Prerequisites Checklist

- [ ] **Python 3.6+** installed (`python --version`)
- [ ] **SCons** installed (`pip install scons`)
- [ ] **Visual Studio 2019/2022** with C++ tools
- [ ] **Git** installed

### Step-by-Step Build

#### 1. Clone godot-cpp

Open PowerShell in your project directory:

```powershell
cd "C:\Users\lando\Desktop\Fall 2025\2DGame\img-final\necronomicore"
git clone https://github.com/godotengine/godot-cpp
cd godot-cpp
git checkout 4.4
```

#### 2. Build godot-cpp (15-20 minutes first time)

```powershell
# Debug build
python -m SCons platform=windows target=template_debug

# Release build
python -m SCons platform=windows target=template_release
```

☕ **Grab a coffee** - this takes a while!

#### 3. Build NecronomiCore (2-3 minutes)

```powershell
cd ..
python -m SCons platform=windows target=template_debug
python -m SCons platform=windows target=template_release
```

#### 4. Verify Build

Check that these files exist:

```
necronomicore/bin/
├── libnecronomicore.windows.template_debug.x86_64.dll
└── libnecronomicore.windows.template_release.x86_64.dll
```

✅ If you see these DLLs, you're done building!

---

## 🎮 Using in Your Game

### 1. Add to Autoload

In Godot:
1. **Project** → **Project Settings** → **Autoload**
2. Click **+** button
3. Select `NecronomiCoreManager.cs`
4. Set Node Name: `AI`
5. Click **Add**

### 2. Test It!

Create a new script:

```csharp
using Godot;

public partial class TestAI : Node
{
    public override void _Ready()
    {
        // Listen for items
        AI.Instance.OnItemPoolReady += (items) => {
            GD.Print($"✅ Generated {items.Count} items!");
            foreach (var item in items)
            {
                var dict = item.As<Godot.Collections.Dictionary>();
                GD.Print($"  - {dict["name"]} ({dict["rarity"]})");
            }
        };

        // Listen for errors
        AI.Instance.OnRequestFailed += (error) => {
            GD.Print($"❌ Error: {error}");
        };

        // Request item generation
        GD.Print("Requesting AI item generation...");
        AI.Instance.GenerateItemPool(
            difficulty: 1,
            floor: 1,
            theme: "lovecraftian fungal dungeon"
        );
    }
}
```

Run it and check the console!

---

## 📚 What Each File Does

### Core System
- `necronomicore/` - C++ extension source code
- `necronomicore.gdextension` - Tells Godot about the extension
- `NecronomiCoreManager.cs` - C# wrapper (what you actually use)

### GDScript Prototype (You Can Delete Later)
- `openai_client.gd` - Prototype OpenAI client
- `openai_example.gd` - Example scene
- `config_loader.gd` - Config utility

### Configuration
- `api_config.json` - Your API key (gitignored)

---

## 🎯 Next Steps for Each Team Member

### Landon (Item Generation)

```csharp
// In your run manager
public override void _Ready()
{
    AI.Instance.OnItemPoolReady += HandleItems;
    AI.Instance.GenerateItemPool(CurrentDifficulty, CurrentFloor);
}

private void HandleItems(Godot.Collections.Array items)
{
    // Store items for loot drops
    ItemDatabase.StoreItems(items);
}
```

📖 See `USAGE.md` section "For Landon"

### Alexandra (NPC Dialog)

```csharp
// In your NPC script
public void TalkToPlayer()
{
    var personality = new Godot.Collections.Dictionary {
        ["npc_name"] = "Fungal Merchant",
        ["archetype"] = "suspicious vendor",
        ["sanity_level"] = 0.5f
    };
    
    AI.Instance.OnDialogReady += ShowDialog;
    AI.Instance.RequestNPCDialog("Fungal Merchant", "greeting", personality);
}
```

📖 See `USAGE.md` section "For Alexandra"

### Noah (Random Rolls)

```csharp
// In your gambling system
public void RollDice()
{
    int roll = AI.Instance.RollGambling();
    
    if (roll >= 75)
        GD.Print("Big win!");
    else if (roll >= 50)
        GD.Print("Small win");
    else
        GD.Print("Loss");
}
```

📖 See `USAGE.md` section "For Noah"

---

## 🐛 Common Issues

### "scons: command not found"
```powershell
pip install scons
# If still not working, use: python -m SCons instead of scons
# Example: python -m SCons platform=windows target=template_debug
```

### "Visual Studio not found"
Download: https://visualstudio.microsoft.com/downloads/  
Install "Desktop development with C++"

### "API request failed: 401"
Your API key is wrong. Check `api_config.json`:
```json
{
    "openai_api_key": "sk-your-key-starts-with-sk"
}
```

### Extension not loading
1. Check Godot console for errors
2. Verify DLL files exist in `necronomicore/bin/`
3. Check `.gdextension` file points to correct paths

### Build takes forever
This is normal! godot-cpp build takes 15-20 minutes the first time.

---

## 💰 OpenAI Costs

**Don't panic!** For your project:
- Item generation: ~$0.01 per run
- Dialog: ~$0.001 per NPC interaction
- Total for whole project: ~$5-10

Set a spending limit at: https://platform.openai.com/account/billing/limits

---

## 📖 Full Documentation

- **`necronomicore/BUILD.md`** - Detailed build instructions
- **`necronomicore/USAGE.md`** - Complete API guide for all 3 modules
- **`necronomicore/README.md`** - Technical architecture

---

## ✅ Success Checklist

- [ ] GDScript prototype works
- [ ] godot-cpp built successfully
- [ ] NecronomiCore DLLs exist
- [ ] `NecronomiCoreManager` added to Autoload
- [ ] Test script prints "Generated X items"

If all checked, you're ready to build your game! 🎉

---

## 🆘 Need Help?

1. Check the error in Godot console
2. Read the relevant `.md` file
3. Ask in your team Discord
4. Check Godot GDExtension docs: https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/

Good luck with NecronomiCore: The Elder Bloom! 🍄

