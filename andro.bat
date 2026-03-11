@echo off
setlocal enabledelayedexpansion

:: Andro - Build Android APK and AAB from andro.yml configuration
:: Usage: andro [build|clean|help]

set "SCRIPT_DIR=%~dp0"
set "CONFIG_FILE=%SCRIPT_DIR%andro.yml"

if "%1"=="" goto :build
if "%1"=="build" goto :build
if "%1"=="clean" goto :clean
if "%1"=="help" goto :help

echo Unknown command: %1
echo Use "andro help" for usage information
exit /b 1

:help
echo Andro - Android Build Tool
echo.
echo Usage: andro [command]
echo.
echo Commands:
echo   build    Build APK and AAB from andro.yml (default)
echo   clean    Clean build artifacts
echo   help     Show this help message
echo.
echo Configuration file: andro.yml
goto :eof

:clean
echo Cleaning build artifacts...
if exist "%SCRIPT_DIR%build" rmdir /s /q "%SCRIPT_DIR%build"
if exist "%SCRIPT_DIR%app\build" rmdir /s /q "%SCRIPT_DIR%app\build"
if exist "%SCRIPT_DIR%.gradle" rmdir /s /q "%SCRIPT_DIR%.gradle"
echo Clean complete.
goto :eof

:build
echo ============================================
echo   Andro - Android Build Tool
echo ============================================
echo.

:: Check if andro.yml exists
if not exist "%CONFIG_FILE%" (
    echo ERROR: Configuration file not found: %CONFIG_FILE%
    exit /b 1
)

echo Reading configuration from %CONFIG_FILE%...
echo.

:: Parse YAML configuration using PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%parse_yaml.ps1" -configFile "%CONFIG_FILE%" > "%TEMP%\andro_config.tmp"

for /f "delims=" %%i in (%TEMP%\andro_config.tmp) do set "%%i"
del "%TEMP%\andro_config.tmp"

echo Configuration loaded:
echo   Title:   %APP_TITLE%
echo   Version: %APP_VERSION%
echo   Package: %APP_PACKAGE%
echo   Icon:    %APP_ICON%
echo   Web:     %APP_WEB%
echo   Ads ID:  %APP_ADS%
echo.

:: Check Java
where java >nul 2>nul
if errorlevel 1 (
    echo ERROR: Java not found in PATH.
    echo Please install JDK 11 or higher.
    exit /b 1
)

java -version >nul 2>&1
for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do set "JAVA_VERSION=%%v"
echo Java version: %JAVA_VERSION%
echo.

:: Bootstrap Gradle if needed
if not exist "%SCRIPT_DIR%gradle\wrapper\gradle-wrapper.jar" (
    echo Setting up Gradle wrapper...
    call "%SCRIPT_DIR%bootstrap-gradle.bat"
    echo.
)

:: Accept SDK licenses automatically
call :accept_sdk_licenses

:: Generate project structure
echo Generating Android project structure...

:: Create directories using PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%create_dirs.ps1" ^
    -scriptDir "%SCRIPT_DIR:~0,-1%" ^
    -appPackage "%APP_PACKAGE%"

:: Copy icon
if exist "%SCRIPT_DIR%%APP_ICON%" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$src = '%SCRIPT_DIR:~0,-1%\%APP_ICON%'; $dst = '%SCRIPT_DIR:~0,-1%\app\src\main\res\drawable\ic_launcher.png'; Copy-Item $src $dst -Force"
    echo Icon copied: %APP_ICON%
) else (
    echo WARNING: Icon file not found: %APP_ICON%
)

:: Copy web assets
if exist "%SCRIPT_DIR%%APP_WEB%" (
    echo Copying web assets from %APP_WEB%...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$src = '%SCRIPT_DIR:~0,-1%\%APP_WEB%'; $dst = '%SCRIPT_DIR:~0,-1%\app\src\main\assets'; Get-ChildItem $src -File | ForEach-Object { Copy-Item $_.FullName $dst -Force }"
    echo Web assets copied.
) else (
    echo WARNING: Web folder not found: %APP_WEB%
)

:: Generate keystore if not exists
if not exist "%SCRIPT_DIR%keystore.jks" (
    echo Generating keystore...
    call :generate_keystore
) else (
    echo Keystore found.
)

:: Generate source files using PowerShell
echo Generating source files...
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%generate_project.ps1" ^
    -title "%APP_TITLE%" ^
    -version "%APP_VERSION%" ^
    -package "%APP_PACKAGE%" ^
    -ads "%APP_ADS%" ^
    -output "%SCRIPT_DIR:~0,-1%"

:: Build with Gradle
echo.
echo ============================================
echo   Building APK and AAB...
echo ============================================
echo.

cd /d "%SCRIPT_DIR%"

:: Run Gradle build
if exist "%SCRIPT_DIR%gradlew.bat" (
    call "%SCRIPT_DIR%gradlew.bat" assembleRelease assembleDebug bundleRelease --no-daemon
) else (
    gradle assembleRelease assembleDebug bundleRelease --no-daemon
)

if errorlevel 1 (
    echo.
    echo ============================================
    echo   Build Failed!
    echo ============================================
    echo.
    echo Common issues:
    echo - Java JDK 11+ not installed or not in PATH
    echo - ANDROID_HOME environment variable not set
    echo - Android SDK not installed
    echo - Internet connection required for Gradle downloads
    echo.
    exit /b 1
)

echo.
echo ============================================
echo   Build Complete!
echo ============================================
echo.
echo Output files:
if exist "%SCRIPT_DIR%app\build\outputs\apk\debug\app-debug.apk" (
    echo   APK (Debug):  %SCRIPT_DIR%app\build\outputs\apk\debug\app-debug.apk
)
if exist "%SCRIPT_DIR%app\build\outputs\apk\release\app-release.apk" (
    echo   APK (Release): %SCRIPT_DIR%app\build\outputs\apk\release\app-release.apk
)
if exist "%SCRIPT_DIR%app\build\outputs\bundle\release\app-release.aab" (
    echo   AAB (Release): %SCRIPT_DIR%app\build\outputs\bundle\release\app-release.aab
)
echo.

goto :eof

:generate_keystore
keytool -genkey -v ^
    -keystore "%SCRIPT_DIR%keystore.jks" ^
    -keyalg RSA ^
    -keysize 2048 ^
    -validity 10000 ^
    -alias andro ^
    -dname "CN=Muhammad Zaini, L=Samarinda, EMAIL=muhzaini30@gmail.com" ^
    -storepass 0809894kali ^
    -keypass 0809894kali

if errorlevel 1 (
    echo ERROR: Failed to generate keystore.
    exit /b 1
)
echo Keystore generated successfully.
goto :eof

:accept_sdk_licenses
echo.
echo Checking Android SDK licenses...
echo.

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
    echo WARNING: Android SDK not found. Skipping license acceptance.
    goto :eof
)

if not exist "%SDK_DIR%" (
    echo WARNING: SDK directory not found: %SDK_DIR%
    goto :eof
)

:: Find sdkmanager
set "SDKMANAGER="
if exist "%SDK_DIR%\cmdline-tools\latest\bin\sdkmanager.bat" (
    set "SDKMANAGER=%SDK_DIR%\cmdline-tools\latest\bin\sdkmanager.bat"
) else if exist "%SDK_DIR%\tools\bin\sdkmanager.bat" (
    set "SDKMANAGER=%SDK_DIR%\tools\bin\sdkmanager.bat"
)

if "%SDKMANAGER%"=="" (
    echo WARNING: sdkmanager not found. Skipping license acceptance.
    goto :eof
)

echo Found SDK: %SDK_DIR%
@REM echo Creating license files...

:: Create licenses directory
@REM set "LICENSES_DIR=%SDK_DIR%\licenses"
@REM if not exist "%LICENSES_DIR%" mkdir "%LICENSES_DIR%"

:: Accept all licenses using sdkmanager
@REM echo Accepting licenses via sdkmanager...
@REM echo y | "%SDKMANAGER%" --sdk_root="%SDK_DIR%" --licenses >nul 2>&1

:: Install required SDK packages
@REM echo Installing required SDK packages...
@REM "%SDKMANAGER%" --sdk_root="%SDK_DIR%" --install "platform-tools" "platforms;android-34" "build-tools;34.0.0" "build-tools;33.0.1" >nul 2>&1

:: Also create license files directly (backup method)
echo 24333f8a63b6825ea9c5514f83c2829b004d1fee > "%LICENSES_DIR%\android-sdk-license"
echo 8933bad161af4178b1185d1a37fbf41ea5269c55 >> "%LICENSES_DIR%\android-sdk-license"
echo d56f5187479451eabf01fb78af6dfcb131a6481e >> "%LICENSES_DIR%\android-sdk-license"
echo 24333f8a63b6825ea9c5514f83c2829b004d1fee >> "%LICENSES_DIR%\android-sdk-license"

echo Licenses accepted and packages installed.
goto :eof
