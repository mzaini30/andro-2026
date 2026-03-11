@echo off
echo ============================================
echo Installing Android SDK Command-line Tools
echo ============================================
echo.

set SDK_ROOT=%CD%\android-sdk
set CMDLINE_TOOLS_URL=https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip
set CMDLINE_TOOLS_ZIP=%TEMP%\commandlinetools.zip

echo Downloading Android SDK Command-line Tools...
powershell -Command "Invoke-WebRequest -Uri '%CMDLINE_TOOLS_URL%' -OutFile '%CMDLINE_TOOLS_ZIP%'"

if errorlevel 1 (
    echo Download failed!
    exit /b 1
)

echo Extracting...
if exist "%SDK_ROOT%" rmdir /s /q "%SDK_ROOT%"
mkdir "%SDK_ROOT%\cmdline-tools"

powershell -Command "Expand-Archive -Path '%CMDLINE_TOOLS_ZIP%' -DestinationPath '%TEMP%\cmdline-tools' -Force"

move "%TEMP%\cmdline-tools\cmdline-tools" "%SDK_ROOT%\cmdline-tools\latest"

del "%CMDLINE_TOOLS_ZIP%"

echo.
echo Installing required SDK components...
echo.

set PATH=%PATH%;%SDK_ROOT%\cmdline-tools\latest\bin

yes | sdkmanager --sdk_root=%SDK_ROOT% "platform-tools" "platforms;android-34" "build-tools;34.0.0"

if errorlevel 1 (
    echo.
    echo Installing components...
    sdkmanager --sdk_root=%SDK_ROOT% "platform-tools" "platforms;android-34" "build-tools;34.0.0"
)

echo.
echo Updating local.properties...
echo sdk.dir=%SDK_ROOT% > local.properties

echo.
echo ============================================
echo Android SDK installed successfully!
echo Location: %SDK_ROOT%
echo ============================================
echo.
echo Now you can run: andro build
echo.
