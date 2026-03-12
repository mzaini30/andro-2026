@echo off
setlocal enabledelayedexpansion

:: Andro - Build Android APK and AAB from andro.yml configuration
:: Usage: andro [build|clean|init|help]

set "SCRIPT_DIR=%~dp0"
set "CURRENT_DIR=%CD%"

:: Handle 'init' command early (before config search) since it creates new config
if "%1"=="init" goto :init
if "%1"=="help" goto :help

:: For other commands, search for existing andro.yml
set "CONFIG_DIR=%CURRENT_DIR%"

:: Search for andro.yml in current directory and parent directories
:find_config
set "CONFIG_FILE=%CONFIG_DIR%\andro.yml"
if exist "%CONFIG_FILE%" goto :config_found
set "PARENT_DIR=%CONFIG_DIR%\.."
if /i "%PARENT_DIR%"=="%CONFIG_DIR%" goto :config_not_found
set "CONFIG_DIR=%PARENT_DIR%"
goto :find_config

:config_not_found
echo ERROR: Configuration file (andro.yml) not found in current directory or any parent directory.
echo Current directory: %CURRENT_DIR%
echo.
echo Use "andro init" to create a new project configuration.
exit /b 1

:config_found
:: Set ANDROID_DIR relative to where andro.yml was found
set "ANDROID_DIR=%CONFIG_DIR%\android"
set "SCRIPT_ANDROID_DIR=%SCRIPT_DIR%android"

if "%1"=="" goto :build
if "%1"=="build" goto :build
if "%1"=="clean" goto :clean

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
echo   init     Initialize a new project (create andro.yml)
echo   help     Show this help message
echo.
echo Configuration file: andro.yml
goto :eof

:init
echo ============================================
echo   Andro Init - Create New Project
echo ============================================
echo.
echo Script directory: %SCRIPT_DIR%
echo Current directory: %CURRENT_DIR%
echo.

:: Check if andro.yml already exists
if exist "%CURRENT_DIR%\andro.yml" (
    echo ERROR: andro.yml already exists in:
    echo   %CURRENT_DIR%\andro.yml
    echo.
    echo Delete it first or choose a different directory.
    exit /b 1
)

:: Test write permission
echo Testing write permission...
echo test > "%CURRENT_DIR%\test_write.tmp" 2>nul
if errorlevel 1 (
    echo.
    echo ERROR: Cannot write to current directory!
    echo   Directory: %CURRENT_DIR%
    echo.
    echo Please run from a writable directory.
    exit /b 1
)
del "%CURRENT_DIR%\test_write.tmp" >nul 2>&1
set errorlevel=0
echo Write permission: OK
echo.

:: Create andro.yml
echo Creating andro.yml...
(
echo - title: "My Awesome App"
echo - version: "1"
echo - package: "com.example.myapp"
echo - icon: "round.png"
echo - web: "html"
echo - ads: "202843390"
) > "%CURRENT_DIR%\andro.yml"

if exist "%CURRENT_DIR%\andro.yml" (
    echo   Created: %CURRENT_DIR%\andro.yml
) 
@REM else (
@REM     echo.
@REM     echo ERROR: Failed to create andro.yml!
@REM     echo   Target: %CURRENT_DIR%\andro.yml
@REM     echo.
@REM     echo Possible causes:
@REM     echo - Path too long (max 260 characters on Windows)
@REM     echo - Insufficient permissions
@REM     echo - Disk full
@REM     exit /b 1
@REM )
echo.

:: Copy andro.md if exists
echo Checking for andro.md...
echo   Source: %SCRIPT_DIR%\andro.md
if exist "%SCRIPT_DIR%\andro.md" (
    echo Copying andro.md...
    copy /Y "%SCRIPT_DIR%\andro.md" "%CURRENT_DIR%\andro.md"
    if exist "%CURRENT_DIR%\andro.md" (
        echo   Copied: %CURRENT_DIR%\andro.md
    ) else (
        echo   WARNING: Failed to copy andro.md
    )
) else (
    echo   andro.md not found in %SCRIPT_DIR% (skipping)
)

echo.
echo ============================================
echo   Init Complete!
echo ============================================
echo.
echo Next steps:
echo   1. Edit andro.yml to configure your app
echo   2. Copy the android\ folder to this directory
echo   3. Run "andro build" to build your APK
echo.
goto :eof

:clean
echo Cleaning build artifacts...
if exist "%CONFIG_DIR%\android\build" rmdir /s /q "%CONFIG_DIR%\android\build"
if exist "%CONFIG_DIR%\android\app\build" rmdir /s /q "%CONFIG_DIR%\android\app\build"
if exist "%CONFIG_DIR%\android\.gradle" rmdir /s /q "%CONFIG_DIR%\android\.gradle"
if exist "%CONFIG_DIR%\android\app" rmdir /s /q "%CONFIG_DIR%\android\app"
if exist "%CONFIG_DIR%\android\gradle" rmdir /s /q "%CONFIG_DIR%\android\gradle"
if exist "%CONFIG_DIR%\android\local.properties" del /q "%CONFIG_DIR%\android\local.properties"
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
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_ANDROID_DIR%\parse_yaml.ps1" -configFile "%CONFIG_FILE%" > "%TEMP%\andro_config.tmp"

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
if not exist "%ANDROID_DIR%\gradle\wrapper\gradle-wrapper.jar" (
    echo Setting up Gradle wrapper...
    
    :: Create gradle wrapper directory in output folder
    if not exist "%ANDROID_DIR%\gradle\wrapper" mkdir "%ANDROID_DIR%\gradle\wrapper"
    
    :: Copy gradlew.bat to output directory
    copy /Y "%SCRIPT_ANDROID_DIR%\gradlew.bat" "%ANDROID_DIR%\gradlew.bat" >nul
    
    :: Copy gradle-wrapper.properties to output directory
    copy /Y "%SCRIPT_ANDROID_DIR%\gradle\wrapper\gradle-wrapper.properties" "%ANDROID_DIR%\gradle\wrapper\gradle-wrapper.properties" >nul
    
    :: Download gradle-wrapper.jar directly to output directory
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/gradle/gradle/v8.0.0/gradle/wrapper/gradle-wrapper.jar' -OutFile '%ANDROID_DIR%\gradle\wrapper\gradle-wrapper.jar' -UseBasicParsing"
    
    echo Gradle wrapper setup complete.
    echo.
)

:: Accept SDK licenses automatically
call :accept_sdk_licenses

:: Generate project structure
echo Generating Android project structure...

:: Create directories using PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_ANDROID_DIR%\create_dirs.ps1" ^
    -scriptDir "%ANDROID_DIR%" ^
    -appPackage "%APP_PACKAGE%"

:: Copy icon (resolve path relative to config directory)
set "ICON_SRC=%CONFIG_DIR%\%APP_ICON%"
if exist "%ICON_SRC%" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$src = '%ICON_SRC%'; $dst = '%ANDROID_DIR%\app\src\main\res\drawable\ic_launcher.png'; Copy-Item $src $dst -Force"
    echo Icon copied: %APP_ICON%
) else (
    echo WARNING: Icon file not found: %ICON_SRC%
)

:: Copy web assets (resolve path relative to config directory)
set "WEB_SRC=%CONFIG_DIR%\%APP_WEB%"
if exist "%WEB_SRC%" (
    echo Copying web assets from %APP_WEB%...
    :: Ensure assets directory exists
    if not exist "%ANDROID_DIR%\app\src\main\assets" mkdir "%ANDROID_DIR%\app\src\main\assets"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$src = '%WEB_SRC%'; $dst = '%ANDROID_DIR%\app\src\main\assets'; Get-ChildItem $src -Recurse -File | ForEach-Object { $relPath = $_.FullName.Substring($src.Length); $destFile = $dst + $relPath; if (!(Test-Path (Split-Path $destFile))) { New-Item -ItemType Directory -Force -Path (Split-Path $destFile) | Out-Null }; Copy-Item $_.FullName $destFile -Force }"
    echo Web assets copied.
) else (
    echo WARNING: Web folder not found: %WEB_SRC%
)

:: Generate keystore if not exists (in android directory)
if not exist "%ANDROID_DIR%\keystore.jks" (
    echo Generating keystore...
    call :generate_keystore
) else (
    echo Keystore found.
)

:: Generate source files using PowerShell
echo Generating source files...
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_ANDROID_DIR%\generate_project.ps1" ^
    -title "%APP_TITLE%" ^
    -version "%APP_VERSION%" ^
    -package "%APP_PACKAGE%" ^
    -ads "%APP_ADS%" ^
    -output "%ANDROID_DIR%"

:: Update local.properties with actual SDK path (use forward slashes to avoid escaping issues)
if exist "D:\Android\Sdk" (
    echo sdk.dir=D:/Android/Sdk> "%ANDROID_DIR%\local.properties"
)

:: Copy andro.md to output directory if it exists
if exist "%SCRIPT_ANDROID_DIR%\..\andro.md" (
    copy /Y "%SCRIPT_ANDROID_DIR%\..\andro.md" "%CONFIG_DIR%\andro.md" >nul
    echo andro.md copied to %CONFIG_DIR%.
)

:: Build with Gradle
echo.
echo ============================================
echo   Building APK and AAB...
echo ============================================
echo.

cd /d "%ANDROID_DIR%"

:: Run Gradle build
if exist "%ANDROID_DIR%\gradlew.bat" (
    call "%ANDROID_DIR%\gradlew.bat" assembleRelease assembleDebug bundleRelease --no-daemon
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
if exist "%ANDROID_DIR%\app\build\outputs\apk\debug\app-debug.apk" (
    echo   APK (Debug):  %ANDROID_DIR%\app\build\outputs\apk\debug\app-debug.apk
)
if exist "%ANDROID_DIR%\app\build\outputs\apk\release\app-release.apk" (
    echo   APK (Release): %ANDROID_DIR%\app\build\outputs\apk\release\app-release.apk
)
if exist "%ANDROID_DIR%\app\build\outputs\bundle\release\app-release.aab" (
    echo   AAB (Release): %ANDROID_DIR%\app\build\outputs\bundle\release\app-release.aab
)
echo.

cd /d "%CONFIG_DIR%"
goto :eof

:generate_keystore
keytool -genkey -v ^
    -keystore "%ANDROID_DIR%\keystore.jks" ^
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
if exist "%ANDROID_DIR%\local.properties" (
    for /f "tokens=2 delims==" %%a in ('findstr /c:"sdk.dir=" "%ANDROID_DIR%\local.properties"') do set "SDK_DIR=%%a"
)

:: Trim trailing whitespace and normalize path separators
if defined SDK_DIR (
    call :trim_string "SDK_DIR"
    set "SDK_DIR=%SDK_DIR:/=\%"
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

:: Create licenses directory
set "LICENSES_DIR=%SDK_DIR%\licenses"
if not exist "%LICENSES_DIR%" mkdir "%LICENSES_DIR%"

:: Create license files directly
echo Creating license files...
echo 24333f8a63b6825ea9c5514f83c2829b004d1fee > "%LICENSES_DIR%\android-sdk-license"
echo 8933bad161af4178b1185d1a37fbf41ea5269c55 >> "%LICENSES_DIR%\android-sdk-license"
echo d56f5187479451eabf01fb78af6dfcb131a6481e >> "%LICENSES_DIR%\android-sdk-license"
echo 24333f8a63b6825ea9c5514f83c2829b004d1fee >> "%LICENSES_DIR%\android-sdk-license"

echo Licenses accepted.
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
