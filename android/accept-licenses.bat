@echo off
echo ============================================
echo Accepting Android SDK Licenses
echo ============================================
echo.

set "SCRIPT_DIR=%~dp0"

:: Try to get SDK path from local.properties first
set "SDK_DIR="
if exist "%SCRIPT_DIR%local.properties" (
    for /f "tokens=2 delims==" %%a in ('findstr /c:"sdk.dir=" "%SCRIPT_DIR%local.properties"') do set "SDK_DIR=%%a"
)

:: Fall back to ANDROID_HOME
if "%SDK_DIR%"=="" set "SDK_DIR=%ANDROID_HOME%"

:: Fall back to default location
if "%SDK_DIR%"=="" if exist "D:\Android\Sdk" set "SDK_DIR=D:\Android\Sdk"

if "%SDK_DIR%"=="" (
    echo ERROR: Android SDK not found.
    echo Please set ANDROID_HOME or create local.properties with sdk.dir=
    exit /b 1
)

echo Using Android SDK: %SDK_DIR%
echo.

:: Check for sdkmanager
if exist "%SDK_DIR%\cmdline-tools\latest\bin\sdkmanager.bat" (
    set "SDKMANAGER=%SDK_DIR%\cmdline-tools\latest\bin\sdkmanager.bat"
) else if exist "%SDK_DIR%\tools\bin\sdkmanager.bat" (
    set "SDKMANAGER=%SDK_DIR%\tools\bin\sdkmanager.bat"
) else (
    echo ERROR: sdkmanager not found!
    echo Please install Android SDK command-line tools.
    exit /b 1
)

echo Found sdkmanager: %SDKMANAGER%
echo.
echo Accepting all licenses...
echo.

:: Accept all licenses automatically with --sdk_root parameter
echo y | "%SDKMANAGER%" --sdk_root="%SDK_DIR%" --licenses

if errorlevel 1 (
    echo.
    echo WARNING: License acceptance may have encountered issues.
    echo You can try running manually: %SDKMANAGER% --sdk_root="%SDK_DIR%" --licenses
    echo.
) else (
    echo.
    echo Licenses accepted successfully!
    echo.
)

:: Also create licenses directory with accepted licenses
echo Creating license files...
set "LICENSES_DIR=%SDK_DIR%\licenses"
if not exist "%LICENSES_DIR%" mkdir "%LICENSES_DIR%"

:: Android SDK Platform license
echo 24333f8a63b6825ea9c5514f83c2829b004d1fee > "%LICENSES_DIR%\android-sdk-license"

:: Android SDK Build Tools license
echo 8933bad161af4178b1185d1a37fbf41ea5269c55 >> "%LICENSES_DIR%\android-sdk-license"
echo d56f5187479451eabf01fb78af6dfcb131a6481e >> "%LICENSES_DIR%\android-sdk-license"
echo 24333f8a63b6825ea9c5514f83c2829b004d1fee >> "%LICENSES_DIR%\android-sdk-license"

:: Google USB Driver license (if needed)
echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > "%LICENSES_DIR%\google-gdk-license"

:: Install required SDK packages
echo.
echo Installing required SDK packages...
echo y | "%SDKMANAGER%" --sdk_root="%SDK_DIR%" --install "platform-tools" "platforms;android-34" "build-tools;34.0.0" "build-tools;33.0.1"

echo.
echo ============================================
echo License setup complete!
echo ============================================
echo.
echo You can now run: andro build
echo.
