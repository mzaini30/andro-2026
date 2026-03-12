@echo off
echo ============================================
echo   Andro Fix Script
echo ============================================
echo.
echo This script will copy the updated files to your project.
echo.

set "SOURCE_DIR=D:\Andro\android"
set "TARGET_DIR=%CD%\android"

if not exist "%TARGET_DIR%" (
    echo ERROR: android folder not found in current directory!
    echo Current directory: %CD%
    echo.
    echo Please run this script from your project folder (D:\Aplikasi-Android\learning-kana)
    pause
    exit /b 1
)

echo Copying updated scripts...
echo.

:: Copy PowerShell scripts
copy /Y "%SOURCE_DIR%\create_dirs.ps1" "%TARGET_DIR%\create_dirs.ps1"
copy /Y "%SOURCE_DIR%\copy_assets.ps1" "%TARGET_DIR%\copy_assets.ps1"

:: Copy andro.bat to current directory
copy /Y "%SOURCE_DIR%\..\andro.bat" "%CD%\andro.bat"

echo.
echo ============================================
echo   Fix Complete!
echo ============================================
echo.
echo Updated files:
echo   - andro.bat (in project root)
echo   - android\create_dirs.ps1
echo   - android\copy_assets.ps1
echo.
echo Now try running: andro build
echo.
pause
