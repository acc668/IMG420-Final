# NecronomiCore Test Setup Verification Script
# This script checks that all prerequisites are met before running tests

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "       NecronomiCore Test Setup Verification              " -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Check 1: C++ Extension DLL
Write-Host "[1/5] Checking C++ Extension DLL..." -NoNewline
$dllPath = "..\necronomicore\bin\libnecronomicore.windows.template_debug.x86_64.dll"
if (Test-Path $dllPath) {
    $dllInfo = Get-Item $dllPath
    Write-Host " [OK]" -ForegroundColor Green
    Write-Host "   Location: $dllPath" -ForegroundColor Gray
    Write-Host "   Size: $([math]::Round($dllInfo.Length / 1KB, 2)) KB" -ForegroundColor Gray
    Write-Host "   Modified: $($dllInfo.LastWriteTime)" -ForegroundColor Gray
} else {
    Write-Host " [FAIL]" -ForegroundColor Red
    Write-Host "   ERROR: DLL not found at: $dllPath" -ForegroundColor Red
    Write-Host "   Run build command in module_source\necronomicore" -ForegroundColor Yellow
    $allGood = $false
}

Write-Host ""

# Check 2: API Configuration
Write-Host "[2/5] Checking API Configuration..." -NoNewline
$apiConfigPath = "..\api_config.json"
if (Test-Path $apiConfigPath) {
    Write-Host " [OK]" -ForegroundColor Green
    Write-Host "   Location: $apiConfigPath" -ForegroundColor Gray
    
    try {
        $config = Get-Content $apiConfigPath | ConvertFrom-Json
        if ($config.openai_api_key -and $config.openai_api_key -ne "sk-your-api-key-here") {
            Write-Host "   API Key: Configured and valid" -ForegroundColor Gray
        } else {
            Write-Host "   WARNING: API key is placeholder/missing in config" -ForegroundColor Yellow
            Write-Host "   Tests requiring AI will fail without a valid key" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   WARNING: Could not parse JSON file" -ForegroundColor Yellow
    }
} else {
    Write-Host " [FAIL]" -ForegroundColor Red
    Write-Host "   ERROR: api_config.json not found" -ForegroundColor Red
    Write-Host "   Copy api_config.json.example to api_config.json and add your key" -ForegroundColor Yellow
    $allGood = $false
}

Write-Host ""

# Check 3: Test Scenes
Write-Host "[3/5] Checking Test Scenes..." -NoNewline
$testScenes = @(
    "test_cpp_extension.tscn",
    "test_dialog_module.tscn",
    "test_roll_module.tscn",
    "run_all_tests.tscn"
)

$missingScenes = @()
foreach ($scene in $testScenes) {
    if (-not (Test-Path $scene)) {
        $missingScenes += $scene
    }
}

if ($missingScenes.Count -eq 0) {
    Write-Host " [OK]" -ForegroundColor Green
    Write-Host "   All 4 test scenes found" -ForegroundColor Gray
} else {
    Write-Host " [FAIL]" -ForegroundColor Red
    Write-Host "   Missing scenes:" -ForegroundColor Red
    foreach ($scene in $missingScenes) {
        Write-Host "   - $scene" -ForegroundColor Red
    }
    $allGood = $false
}

Write-Host ""

# Check 4: Test Scripts
Write-Host "[4/5] Checking Test Scripts..." -NoNewline
$testScripts = @(
    "test_cpp_extension.gd",
    "test_dialog_module.gd",
    "test_roll_module.gd",
    "run_all_tests.gd"
)

$missingScripts = @()
foreach ($script in $testScripts) {
    if (-not (Test-Path $script)) {
        $missingScripts += $script
    }
}

if ($missingScripts.Count -eq 0) {
    Write-Host " [OK]" -ForegroundColor Green
    Write-Host "   All 4 test scripts found" -ForegroundColor Gray
} else {
    Write-Host " [FAIL]" -ForegroundColor Red
    Write-Host "   Missing scripts:" -ForegroundColor Red
    foreach ($script in $missingScripts) {
        Write-Host "   - $script" -ForegroundColor Red
    }
    $allGood = $false
}

Write-Host ""

# Check 5: Project File
Write-Host "[5/5] Checking Godot Project..." -NoNewline
$projectPath = "..\project.godot"
if (Test-Path $projectPath) {
    Write-Host " [OK]" -ForegroundColor Green
    Write-Host "   Location: $projectPath" -ForegroundColor Gray
} else {
    Write-Host " [FAIL]" -ForegroundColor Red
    Write-Host "   ERROR: project.godot not found" -ForegroundColor Red
    $allGood = $false
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan

if ($allGood) {
    Write-Host ""
    Write-Host "SUCCESS: All checks passed! Ready to run tests." -ForegroundColor Green
    Write-Host ""
    Write-Host "To run tests:" -ForegroundColor White
    Write-Host "  1. Open Godot Engine" -ForegroundColor White
    Write-Host "  2. Import/Open project: game_prototype\project.godot" -ForegroundColor White
    Write-Host "  3. Open scene: res://tests/run_all_tests.tscn" -ForegroundColor White
    Write-Host "  4. Press F6 (Run Current Scene)" -ForegroundColor White
    Write-Host "  5. Watch Output panel for results" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "WARNING: Some checks failed. Please fix the issues above." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "See TESTING_GUIDE.md for detailed instructions." -ForegroundColor Cyan
Write-Host ""
