# Build Guide

## Prerequisites

- Python 3.6+
- SCons (`pip install scons`)
- Visual Studio 2019 or 2022 with C++ tools
- Godot 4.4+

## Building the C++ Extension

```bash
cd module_source/necronomicore
python -m SCons platform=windows target=template_debug
```

This creates `bin/libnecronomicore.windows.template_debug.x86_64.dll`

The DLL needs to be in `game_prototype/necronomicore/bin/` for Godot to find it.

## Setting up the API Key

Copy `game_prototype/api_config.json.example` to `game_prototype/api_config.json` and add your OpenAI API key:

```json
{
    "openai_api_key": "sk-your-key-here"
}
```

## Running the Game

1. Open Godot
2. Import `game_prototype/project.godot`
3. Open `res://scenes/topdown_game.tscn`
4. Press F6

## Rebuilding

If you change the C++ code:

```bash
cd module_source/necronomicore
python -m SCons -c
python -m SCons platform=windows target=template_debug
```

Then restart Godot (extensions don't hot-reload).

## Common Issues

**"NecronomiCore not found"**
- Make sure the DLL is in `game_prototype/necronomicore/bin/`
- Restart Godot

**"No API key"**
- Check `api_config.json` exists and has your key
- The game still works without it, just uses fallback text

**Build fails**
- Check that Visual Studio C++ tools are installed
- Make sure you're in the `necronomicore` directory when building


