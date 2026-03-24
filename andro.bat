@echo off
setlocal enabledelayedexpansion

REM Andro - Build Android APK and AAB from andro.yml configuration
REM Usage: andro [build|clean|init|help]

set "SCRIPT_DIR=%~dp0"
set "CURRENT_DIR=%CD%"

REM Handle 'init' command early (before config search) since it creates new config
if "%1"=="init" goto :init
if "%1"=="help" goto :help

REM For other commands, search for andro.yml in current directory and parent directories
set "CONFIG_DIR=%CURRENT_DIR%"

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
REM Set ANDROID_DIR relative to where andro.yml was found
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

REM Check if andro.yml already exists
if exist "%CURRENT_DIR%\andro.yml" (
    echo ERROR: andro.yml already exists in:
    echo   %CURRENT_DIR%\andro.yml
    echo.
    echo Delete it first or choose a different directory.
    exit /b 1
)

REM Test write permission
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

REM Create andro.yml
echo Creating andro.yml...
(
echo - title: ""
echo - version: "1"
echo - package: "com.mzaini30."
echo - icon: ""
echo - web: "html"
echo - ads: ""
) > "%CURRENT_DIR%\andro.yml"

if exist "%CURRENT_DIR%\andro.yml" (
    echo   Created: %CURRENT_DIR%\andro.yml
)
echo.

REM Copy andro.md if exists
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
    echo   andro.md not found in %SCRIPT_DIR% [skipping]
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

REM Check and create .gitignore if not exists
if not exist "%CONFIG_DIR%\.gitignore" (
    echo Creating .gitignore...
    (
    echo # Android build artifacts
    echo android/build/
    echo android/app/build/
    echo android/.gradle/
    echo android/app/src/main/res/mipmap-*/
    echo android/app/src/main/res/drawable-*/
    echo *.apk
    echo *.aab
    echo *.jks
    echo *.keystore
    echo.
    echo # Gradle
    echo .gradle/
    echo gradle-app.secure.properties
    echo.
    echo # IDE
    echo .idea/
    echo *.iml
    echo *.ipr
    echo *.iws
    echo ) > "%CONFIG_DIR%\.gitignore"
    echo   Created: %CONFIG_DIR%\.gitignore
    echo.
)

REM Check if andro.yml exists
if not exist "%CONFIG_FILE%" (
    echo ERROR: Configuration file not found: %CONFIG_FILE%
    exit /b 1
)

echo Reading configuration from %CONFIG_FILE%...
echo.

REM Parse YAML configuration using PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_ANDROID_DIR%\parse_yaml.ps1" -configFile "%CONFIG_FILE%" > "%TEMP%\andro_config.tmp"

for /f "usebackq delims=" %%i in ("%TEMP%\andro_config.tmp") do set "%%i"
del "%TEMP%\andro_config.tmp"

echo Configuration loaded:
echo   Title:      %APP_TITLE%
echo   Version:    %APP_VERSION%
echo   Package:    %APP_PACKAGE%
echo   Icon:       %APP_ICON%
echo   Web:        %APP_WEB%
echo   Start.io ID: %APP_ADS%
echo.

REM Check Java
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

REM Bootstrap Gradle if needed
if not exist "%ANDROID_DIR%\gradle\wrapper\gradle-wrapper.jar" (
    echo Setting up Gradle wrapper...

    REM Create gradle wrapper directory in output folder
    if not exist "%ANDROID_DIR%\gradle\wrapper" mkdir "%ANDROID_DIR%\gradle\wrapper"

    REM Copy gradlew.bat to output directory
    copy /Y "%SCRIPT_ANDROID_DIR%\gradlew.bat" "%ANDROID_DIR%\gradlew.bat" >nul

    REM Copy gradle-wrapper.properties to output directory
    copy /Y "%SCRIPT_ANDROID_DIR%\gradle\wrapper\gradle-wrapper.properties" "%ANDROID_DIR%\gradle\wrapper\gradle-wrapper.properties" >nul

    REM Download gradle-wrapper.jar directly to output directory
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/gradle/gradle/v8.0.0/gradle/wrapper/gradle-wrapper.jar' -OutFile '%ANDROID_DIR%\gradle\wrapper\gradle-wrapper.jar' -UseBasicParsing"

    echo Gradle wrapper setup complete.
    echo.
)

REM Accept SDK licenses automatically
call :accept_sdk_licenses

REM Generate project structure
echo Generating Android project structure...

REM Create directories using PowerShell (pass scriptDir without trailing backslash)
set "SCRIPT_DIR_PARAM=%ANDROID_DIR%"
if "%SCRIPT_DIR_PARAM:~-1%"=="\" set "SCRIPT_DIR_PARAM=%SCRIPT_DIR_PARAM:~0,-1%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_ANDROID_DIR%\create_dirs.ps1" -scriptDir "%SCRIPT_DIR_PARAM%" -appPackage "%APP_PACKAGE%"

if errorlevel 1 (
    echo ERROR: Failed to create directory structure.
    exit /b 1
)

REM Copy icon (resolve path relative to config directory)
set "ICON_SRC=%CONFIG_DIR%\%APP_ICON%"
if exist "%ICON_SRC%" (
    echo Resizing icon: %APP_ICON%
    powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%SCRIPT_ANDROID_DIR%\resize_icon.ps1' -inputPath '%ICON_SRC%' -outputPath '%ANDROID_DIR%\app\src\main\res\drawable\ic_launcher.png' -maxSize 512"
    if errorlevel 1 (
        echo WARNING: Icon processing failed.
    ) else (
        echo Icon processed: %APP_ICON%
    )
) else (
    echo WARNING: Icon file not found: %ICON_SRC%
)

REM Copy web assets (resolve path relative to config directory)
set "WEB_SRC=%CONFIG_DIR%\%APP_WEB%"
if exist "%WEB_SRC%" (
    echo Copying web assets from %APP_WEB%...
    REM Ensure assets directory exists
    if not exist "%ANDROID_DIR%\app\src\main\assets" mkdir "%ANDROID_DIR%\app\src\main\assets"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%SCRIPT_ANDROID_DIR%\copy_assets.ps1' -sourcePath '%WEB_SRC%' -destPath '%ANDROID_DIR%\app\src\main\assets'"
    if errorlevel 1 (
        echo ERROR: Failed to copy web assets.
        exit /b 1
    )
    echo Web assets copied.
) else (
    echo ERROR: Web folder not found: %WEB_SRC%
    echo.
    echo Please ensure the 'web' path in andro.yml points to a valid folder.
    echo Current web path: %APP_WEB%
    echo Expected location: %WEB_SRC%
    exit /b 1
)

REM Generate keystore if not exists (in android directory)
if not exist "%ANDROID_DIR%\keystore.jks" (
    echo Generating keystore...
    call :generate_keystore
) else (
    echo Keystore found.
)

REM Generate source files using PowerShell
echo Generating source files...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%SCRIPT_ANDROID_DIR%\generate_project.ps1' -title '%APP_TITLE%' -version '%APP_VERSION%' -package '%APP_PACKAGE%' -icon '%APP_ICON%' -web '%APP_WEB%' -ads '%APP_ADS%' -output '%ANDROID_DIR%'"

if errorlevel 1 (
    echo ERROR: Failed to generate source files.
    exit /b 1
)

REM Update local.properties with actual SDK path (use forward slashes to avoid escaping issues)
if exist "D:\Android\Sdk" (
    echo sdk.dir=D:/Android/Sdk> "%ANDROID_DIR%\local.properties"
)

REM Copy andro.md to output directory if it exists
if exist "%SCRIPT_ANDROID_DIR%\..\andro.md" (
    copy /Y "%SCRIPT_ANDROID_DIR%\..\andro.md" "%CONFIG_DIR%\andro.md" >nul
    echo andro.md copied to %CONFIG_DIR%.
)

REM Build with Gradle
echo.
echo ============================================
echo   Building APK and AAB...
echo ============================================
echo.

cd /d "%ANDROID_DIR%"

REM Run Gradle build
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

REM Rename APK and AAB files using the app title
echo Renaming output files...
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_ANDROID_DIR%\rename_output.ps1" -title "%APP_TITLE%" -androidDir "%ANDROID_DIR%"
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

REM Try to get SDK path from local.properties first
set "SDK_DIR="
if exist "%ANDROID_DIR%\local.properties" (
    for /f "tokens=2 delims==" %%a in ('findstr /c:"sdk.dir=" "%ANDROID_DIR%\local.properties"') do set "SDK_DIR=%%a"
)

REM Trim trailing whitespace and normalize path separators
if defined SDK_DIR (
    call :trim_string "SDK_DIR"
    set "SDK_DIR=%SDK_DIR:/=\%"
)

REM Fall back to ANDROID_HOME
if "%SDK_DIR%"=="" set "SDK_DIR=%ANDROID_HOME%"

REM Fall back to default location
if "%SDK_DIR%"=="" if exist "D:\Android\Sdk" set "SDK_DIR=D:\Android\Sdk"

if "%SDK_DIR%"=="" (
    echo WARNING: Android SDK not found. Skipping license acceptance.
    goto :eof
)

if not exist "%SDK_DIR%" (
    echo WARNING: SDK directory not found: %SDK_DIR%
    goto :eof
)

REM Create licenses directory
set "LICENSES_DIR=%SDK_DIR%\licenses"
if not exist "%LICENSES_DIR%" mkdir "%LICENSES_DIR%"

REM Create license files directly
echo Creating license files...
echo 24333f8a63b6825ea9c5514f83c2829b004d1fee > "%LICENSES_DIR%\android-sdk-license"
echo 8933bad161af4178b1185d1a37fbf41ea5269c55 >> "%LICENSES_DIR%\android-sdk-license"
echo d56f5187479451eabf01fb78af6dfcb131a6481e >> "%LICENSES_DIR%\android-sdk-license"
echo 24333f8a63b6825ea9c5514f83c2829b004d1fee >> "%LICENSES_DIR%\android-sdk-license"

echo Licenses accepted.
goto :eof

:trim_string
REM Helper function to trim leading/trailing whitespace from a variable
setlocal enabledelayedexpansion
set "varName=%~1"
set "varValue=!%varName%!"
:trim_lead
if "!varValue:~0,1!"==" " set "varValue=!varValue:~1!" & goto trim_lead
:trim_trail
if "!varValue:~-1!"==" " set "varValue=!varValue:~0,-1!" & goto trim_trail
endlocal & set "%varName%=%varValue%"
goto :eof
