# Git Workflow for NecronomiCore

## 🎯 What to Push to GitHub

### ✅ **PUSH These Files:**

**C++ Extension Source:**
- `necronomicore/include/*.h` (8 header files)
- `necronomicore/src/*.cpp` (8 source files)
- `necronomicore/SConstruct` (build script)
- `necronomicore/BUILD.md` (build instructions)
- `necronomicore/USAGE.md` (API guide)
- `necronomicore/README.md` (technical docs)

**Godot Configuration:**
- `necronomicore.gdextension` (extension config)
- `project.godot` (Godot project file)
- `.gitignore` (ignore rules)

**Documentation:**
- All `.md` files (README, guides, etc.)

**Example/Test Scripts:**
- `test_cpp_extension.gd`
- `test_dialog_module.gd`
- `test_roll_module.gd`

**Assets:**
- `icon.svg` (project icon)
- Future: sprites, tilesets, levels, etc.

---

### ❌ **DON'T PUSH These Files:**

**Build Artifacts:**
- `necronomicore/bin/*.dll` ← Users build this themselves
- `necronomicore/bin/*.lib`
- `necronomicore/bin/*.exp`
- `*.obj` files

**godot-cpp:**
- `necronomicore/godot-cpp/` ← Users clone separately
- `.sconsign.dblite`

**API Keys & Secrets:**
- `api_config.json` ← NEVER COMMIT THIS!
- `.env` files

**C# Generated Files:**
- `*.csproj`
- `*.sln`
- `.vs/`

**Godot Metadata:**
- `.godot/`
- `.import/`
- `*.import`
- `*.uid`

**Disabled/Temporary:**
- `*.disabled` files
- `*.tmp` files

---

## 📦 **Step-by-Step: Push to GitHub**

### First Time Setup

```bash
# Navigate to your project
cd "C:\Users\lando\Desktop\Fall 2025\2DGame\img-final"

# Initialize git (if not already done)
git init

# Add all files (gitignore will exclude what shouldn't be pushed)
git add .

# Check what will be committed
git status

# Commit
git commit -m "Initial commit: NecronomiCore C++ GDExtension with OpenAI integration"

# Add your GitHub repository as remote
# Replace with your actual repo URL from https://github.com/acc668/IMG420-Final
git remote add origin https://github.com/acc668/IMG420-Final.git

# Push to GitHub
git push -u origin main
```

### Subsequent Pushes

```bash
# Check what changed
git status

# Add specific files or all changes
git add .

# Commit with descriptive message
git commit -m "Add new NPC personalities for level 2"

# Push
git push
```

---

## 🔒 **CRITICAL: Verify API Key is NOT Committed**

Before pushing, always check:

```bash
# Make sure api_config.json is ignored
git status

# Should NOT show api_config.json
# If it does, stop! Check your .gitignore
```

**Never commit:**
- API keys
- Passwords
- Personal tokens
- Compiled binaries

---

## 📋 **.gitignore is Already Configured**

Your `.gitignore` already excludes:
- ✅ `api_config.json`
- ✅ `necronomicore/bin/`
- ✅ `necronomicore/godot-cpp/`
- ✅ All build artifacts
- ✅ C# generated files
- ✅ Godot metadata

**You're safe to `git add .`** - sensitive files are protected!

---

## 👥 **Team Collaboration Workflow**

### For Team Members Cloning the Repo:

```bash
# Clone the repository
git clone https://github.com/acc668/IMG420-Final.git
cd IMG420-Final

# Create your own api_config.json
# (copy from .env.example if provided)
echo '{"openai_api_key": "your-key-here"}' > api_config.json

# Build the C++ extension (see SETUP_FOR_DEVELOPERS.md)
cd necronomicore
git clone https://github.com/godotengine/godot-cpp
cd godot-cpp && git checkout 4.4
python -m SCons platform=windows target=template_debug
cd ..
python -m SCons platform=windows target=template_debug

# Open in Godot and start developing!
```

### Each Team Member's Workflow:

**Landon (Item System):**
```bash
git pull                          # Get latest changes
# Make changes to item system
git add necronomicore/src/item_generation_service.cpp
git commit -m "Adjust item stat balancing"
git push
```

**Alexandra (Dialog System):**
```bash
git pull
# Add new NPC personalities or dialog code
git add necronomicore/src/emotion_dialog_service.cpp
git commit -m "Add new merchant personalities"
git push
```

**Noah (Level Design):**
```bash
git pull
# Add new levels or roll mechanics
git add levels/level_3.tscn
git commit -m "Add level 3 layout"
git push
```

---

## 🔄 **Before Each Work Session:**

```bash
git pull  # Get latest changes from team
```

## 📤 **After Each Work Session:**

```bash
git add .
git status                        # Review what you're committing
git commit -m "Descriptive message"
git push
```

---

## 🐛 **Common Git Issues**

### "API key in commit!"
```bash
# STOP! Remove the file from staging
git reset HEAD api_config.json

# Make sure it's in .gitignore
echo "api_config.json" >> .gitignore
```

### Merge Conflicts
```bash
git pull
# Fix conflicts in files
git add .
git commit -m "Resolve merge conflicts"
git push
```

### Accidentally Committed Binary
```bash
# If you accidentally committed a DLL or binary
git rm --cached necronomicore/bin/*.dll
git commit -m "Remove accidentally committed binaries"
git push
```

---

## 📝 **Commit Message Guidelines**

**Good commit messages:**
- ✅ "Add merchant NPC personality system"
- ✅ "Fix item stat balancing for legendary items"
- ✅ "Implement level 2 boss encounter"

**Bad commit messages:**
- ❌ "Update"
- ❌ "Fix stuff"
- ❌ "asdf"

---

## 🎯 **What Each Team Member Pushes:**

| Member | Pushes | Don't Push |
|--------|--------|------------|
| **Landon** | C++ item code, test scripts | DLLs, API keys |
| **Alexandra** | C++ dialog code, sprites, animations | Build artifacts |
| **Noah** | C++ roll code, level scenes, tilesets | godot-cpp |

---

## 🔐 **Security Checklist**

Before **every** push:
- [ ] `api_config.json` is in `.gitignore`
- [ ] Run `git status` - no `api_config.json` shown
- [ ] No DLLs in the commit
- [ ] No `.obj` or build artifacts
- [ ] Commit message is descriptive

---

## 📦 **Release Process**

When ready to release:

```bash
# Build release version
cd necronomicore
python -m SCons platform=windows target=template_release

# Tag the release
git tag -a v1.0 -m "Release version 1.0"
git push origin v1.0

# Create GitHub Release
# Upload the compiled DLLs as release assets
# Users can download without building
```

---

## 🆘 **Need Help?**

- **Git Basics:** https://git-scm.com/doc
- **GitHub Guide:** https://docs.github.com/en/get-started
- **Team Discord:** [Your Discord link]

---

**Remember:** Users will build the DLLs themselves from your source code. Only push source files!

