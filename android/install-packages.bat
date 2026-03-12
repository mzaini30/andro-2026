@echo off
echo ============================================
echo Install All Required SDK Packages
echo ============================================
echo.
echo This script will install all required Android SDK packages:
echo   - Platform Tools
echo   - Android SDK Platform 34
echo   - Build Tools 34.0.0
echo   - Build Tools 33.0.1
echo.

set "SCRIPT_DIR=%~dp0"

:: Try to get SDK path from local.properties first
set "SDK_DIR="
if exist "%SCRIPT_DIR%local.properties" (
    for /f "tokens=2 delims==" %%a in ('findstr /c:"sdk.dir=" "%SCRIPT_DIR%local.properties"') do set "SDK_DIR=%%a"
)

:: Trim trailing whitespace
if defined SDK_DIR (
    call :trim_string "SDK_DIR"
    set "SDK_DIR=%SDK_DIR:/=\%"
)

:: Fall back to ANDROID_HOME
if "%SDK_DIR%"=="" set "SDK_DIR=%ANDROID_HOME%"

:: Fall back to default location
if "%SDK_DIR%"=="" if exist "D:\Android\Sdk" set "SDK_DIR=D:\Android\Sdk"

if "%SDK_DIR%"=="" (
    echo ERROR: Android SDK not found.
    echo Please set ANDROID_HOME or create local.properties with sdk.dir=
    pause
    exit /b 1
)

echo Using SDK: %SDK_DIR%
echo.

:: Check for sdkmanager
if not exist "%SDK_DIR%\cmdline-tools\latest\bin\sdkmanager.bat" (
    echo ERROR: sdkmanager not found!
    echo Please download and install Android SDK Command-line Tools first.
    echo Download: https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip
    echo.
    echo Extract to: %SDK_DIR%\cmdline-tools\latest\
    pause
    exit /b 1
)

echo Found sdkmanager. Installing packages...
echo.

:: Install all required packages
echo y | "%SDK_DIR%\cmdline-tools\latest\bin\sdkmanager.bat" --sdk_root="%SDK_DIR%" --install "platform-tools" "platforms;android-34" "build-tools;34.0.0" "build-tools;33.0.1"

if errorlevel 1 (
    echo.
    echo ============================================
    echo Installation encountered errors.
    echo ============================================
    echo.
    echo You can download packages manually from:
    echo https://dl.google.com/android/repository/
    echo.
    echo Or see MANUAL_DOWNLOAD.md for direct links.
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================
echo All SDK packages installed successfully!
echo ============================================
echo.
echo You can now run: andro build
echo.
pause

goto :eof

:trim_string
:: Helper function to trim leading/trailing whitespace from a variable
setlocal enabledelayedexpansion
set "varName=%~1"
set "varValue=!%varName%!"
:trim_lead
if "!varValue:~0,1!"==" " set "varValue=!varValue:~1!" & goto trim_lead
:trim_trail
if "!varValue:~-1!"==" " set "varValue=!varValue:~0,-1!" & goto trim_trail
endlocal & set "%varName%=%varValue%"
goto :eof
