@echo off
REM Test Runner Script for NecronomiCore
REM This script helps run tests from command line if Godot is in PATH

echo ================================================
echo NecronomiCore Test Suite Runner
echo ================================================
echo.

REM Check if Godot is available
where godot >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Godot not found in PATH.
    echo.
    echo Please add Godot to your PATH or run tests manually:
    echo 1. Open Godot Engine
    echo 2. Load this project: game_prototype/project.godot
    echo 3. Open scene: res://tests/run_all_tests.tscn
    echo 4. Press F6 to run
    echo.
    pause
    exit /b 1
)

echo Found Godot! Running tests...
echo.

godot --path "%~dp0.." --headless res://tests/run_all_tests.tscn

echo.
echo ================================================
echo Tests completed!
echo ================================================
pause

