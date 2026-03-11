@echo off
echo ============================================
echo Installing Android SDK Command-line Tools
echo ============================================
echo.

set SDK_ROOT=%CD%\android-sdk
set CMDLINE_TOOLS_ZIP=%CD%\commandlinetools-win-11076708_latest (1).zip

if not exist "%CMDLINE_TOOLS_ZIP%" (
    echo ZIP file not found!
    exit /b 1
)

echo Extracting from %CMDLINE_TOOLS_ZIP%...
if exist "%SDK_ROOT%" rmdir /s /q "%SDK_ROOT%"
mkdir "%SDK_ROOT%\cmdline-tools\latest"

powershell -NoProfile -Command "Add-Type -Assembly System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%CMDLINE_TOOLS_ZIP%', '%SDK_ROOT%\cmdline-tools\latest')"

echo.
echo Accepting licenses...
echo y | "%SDK_ROOT%\cmdline-tools\latest\bin\sdkmanager.bat" --sdk_root="%SDK_ROOT%" --licenses 2>nul

echo.
echo Installing SDK components (this may take a while)...
"%SDK_ROOT%\cmdline-tools\latest\bin\sdkmanager.bat" --sdk_root="%SDK_ROOT%" "platform-tools" "platforms;android-34" "build-tools;34.0.0"

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
