@echo off
setlocal enabledelayedexpansion

set VSCODE_EXT_DIR=%USERPROFILE%\.vscode\extensions

if not exist "!VSCODE_EXT_DIR!" (
    echo Creating .vscode extensions directory...
    mkdir "!VSCODE_EXT_DIR!"
)

set TARGET_DIR=!VSCODE_EXT_DIR!\virex-syntax-1.0.0

echo Installing Virex VS Code extension to: !TARGET_DIR!

if exist "!TARGET_DIR!" (
    echo Extension already exists. Removing...
    rmdir /s /q "!TARGET_DIR!"
)

mkdir "!TARGET_DIR!"

xcopy /E /I /Y "%~dp0*" "!TARGET_DIR!\" >nul

if errorlevel 1 (
    echo Installation failed.
    exit /b 1
)

echo Installation successful: !TARGET_DIR!
echo.
echo Please restart VS Code or reload the window (Ctrl+Shift+P, then "Reload Window").
endlocal
