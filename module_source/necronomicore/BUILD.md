# Building NecronomiCore GDExtension

This guide explains how to build the NecronomiCore C++ GDExtension for Godot 4.4.

## Prerequisites

### Required Software

1. **Python 3.6+**
   - Download: https://www.python.org/downloads/
   - Make sure Python is in your PATH

2. **SCons Build Tool**
   ```bash
   pip install scons
   ```

3. **Visual Studio 2019/2022** (Windows)
   - Download: https://visualstudio.microsoft.com/downloads/
   - Install "Desktop development with C++" workload
   - Or use "Build Tools for Visual Studio" (smaller download)

4. **Git**
   - Download: https://git-scm.com/download/win

## Setup Steps

### 1. Clone godot-cpp

From the `necronomicore` directory:

```bash
cd necronomicore
git clone https://github.com/godotengine/godot-cpp
cd godot-cpp
git checkout 4.4
```

### 2. Build godot-cpp

Still in the `godot-cpp` directory:

```bash
# For debug build
python -m SCons platform=windows target=template_debug

# For release build
python -m SCons platform=windows target=template_release
```

**Note:** If `scons` command works directly, you can use `scons` instead of `python -m SCons`.

This will take 5-15 minutes depending on your system.

### 3. Build NecronomiCore

Go back to the `necronomicore` directory:

```bash
cd ..

# Build debug version
python -m SCons platform=windows target=template_debug

# Build release version
python -m SCons platform=windows target=template_release
```

### 4. Verify Build

After building, you should see DLL files in `necronomicore/bin/`:
- `libnecronomicore.windows.template_debug.x86_64.dll`
- `libnecronomicore.windows.template_release.x86_64.dll`

## Testing in Godot

1. Open your Godot project
2. The extension should be automatically loaded via `necronomicore.gdextension`
3. Create a test script:

```gdscript
extends Node

func _ready():
    var necronomi = NecronomiCore.new()
    add_child(necronomi)
    necronomi.set_api_key("your-api-key")
    necronomi.initialize()
    print("NecronomiCore initialized:", necronomi.is_initialized())
```

## Troubleshooting

### "Python not found"
- Make sure Python is installed and in your PATH
- Try running `python --version` in a new terminal

### "scons: command not found"
- Run `pip install scons` again
- Try using `python -m SCons` instead of `scons`
- Restart your terminal if needed

### "Visual Studio not found"
- Make sure VS 2019/2022 is installed with C++ tools
- Or install "Build Tools for Visual Studio"

### Build errors in godot-cpp
- Make sure you're on the correct godot-cpp branch (4.4)
- Try cleaning and rebuilding: `python -m SCons -c` then `python -m SCons platform=windows target=template_debug` again

### Extension not loading in Godot
- Check that `.gdextension` file points to correct DLL paths
- Make sure DLLs exist in `necronomicore/bin/`
- Check Godot console for error messages

## Quick Build Commands

```bash
# Full rebuild (debug)
cd necronomicore
python -m SCons -c
python -m SCons platform=windows target=template_debug

# Full rebuild (release)
python -m SCons -c
python -m SCons platform=windows target=template_release

# Build both
python -m SCons platform=windows target=template_debug
python -m SCons platform=windows target=template_release
```

## Development Workflow

1. Make changes to C++ code
2. Rebuild: `python -m SCons platform=windows target=template_debug`
3. Close and reopen Godot (extensions aren't hot-reloadable)
4. Test your changes

## Platform-Specific Notes

### Windows
- Uses WinHTTP for HTTP requests (built into Windows)
- Requires Visual Studio C++ compiler

### Future: macOS/Linux
- Will need different HTTP client implementation
- Build commands would be similar but with `platform=macos` or `platform=linux`

## Performance Tips

- Use `target=template_release` for final builds (much faster)
- Debug builds include symbols for debugging with Visual Studio
- Parallel builds: `python -m SCons -j4` (uses 4 CPU cores, though auto-detection works well)

## Need Help?

Check Godot GDExtension docs: https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/what_is_gdextension.html

