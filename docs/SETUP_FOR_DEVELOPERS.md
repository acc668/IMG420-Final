# NecronomiCore - Developer Setup Guide

This guide is for developers who want to build the NecronomiCore extension from source.

## Prerequisites

- **Godot 4.4** or later
- **Python 3.6+** (`python --version`)
- **SCons** (`pip install scons`)
- **Git**
- **Visual Studio 2019/2022** with C++ tools (Windows)
  - Or **Build Tools for Visual Studio** (smaller download)

## Quick Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/necronomicore-game.git
cd necronomicore-game
```

### 2. Set Up Your API Key

Create `api_config.json` in the project root:

```json
{
    "openai_api_key": "sk-your-api-key-here"
}
```

**⚠️ NEVER commit this file!** It's in `.gitignore`.

Get your API key from: https://platform.openai.com/api-keys

### 3. Build the C++ Extension

```bash
# Navigate to the extension folder
cd necronomicore

# Clone godot-cpp (one-time setup)
git clone https://github.com/godotengine/godot-cpp
cd godot-cpp
git checkout 4.4

# Build godot-cpp (15-20 minutes, one-time)
python -m SCons platform=windows target=template_debug

# Go back and build NecronomiCore (2-3 minutes)
cd ..
python -m SCons platform=windows target=template_debug
```

### 4. Open in Godot

1. Open Godot Engine 4.4
2. Import the project
3. The extension should load automatically!

### 5. Test It

Run one of the test scenes:
- `test_cpp_extension.gd` - Tests item generation
- `test_dialog_module.gd` - Tests NPC dialog
- `test_roll_module.gd` - Tests random rolls

## Build Targets

```bash
# Debug build (includes debugging symbols)
python -m SCons platform=windows target=template_debug

# Release build (optimized for production)
python -m SCons platform=windows target=template_release

# Clean build
python -m SCons -c
```

## Troubleshooting

### "scons: command not found"
```bash
pip install scons
# Restart your terminal
```

### "Visual Studio not found"
Install "Desktop development with C++" from:
https://visualstudio.microsoft.com/downloads/

### Extension won't load in Godot
- Check that DLL exists: `necronomicore/bin/libnecronomicore.windows.template_debug.x86_64.dll`
- Check Godot console for error messages
- Make sure `.gdextension` file paths are correct

### API requests fail (401 error)
- Check your API key in `api_config.json`
- Make sure the key starts with `sk-`
- Verify you have credits at https://platform.openai.com/usage

## Project Structure

```
necronomicore/
├── include/          # C++ header files
├── src/             # C++ source files
├── bin/             # Compiled DLLs (gitignored, you build these)
├── godot-cpp/       # Godot bindings (gitignored, clone separately)
└── SConstruct       # Build script

test_*.gd            # Example test scripts
*.md                 # Documentation
api_config.json      # Your API key (gitignored!)
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

[Add your license here]

## Team

- **Landon Coonrod** - Item Generation Module, OpenAI Integration
- **Alexandra Curry** - Emotion Dialog Module, Sprite/Animation Design
- **Noah Valdez** - Random Roll Module, Level Design

---

**Need help?** Check the other documentation files:
- `QUICKSTART.md` - Quick start guide
- `necronomicore/BUILD.md` - Detailed build instructions
- `necronomicore/USAGE.md` - API usage examples

