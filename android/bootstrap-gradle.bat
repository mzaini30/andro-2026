@echo off
setlocal

:: Bootstrap script to download Gradle wrapper
set "GRADLE_VERSION=8.0"
set "WRAPPER_JAR=%~dp0gradle\wrapper\gradle-wrapper.jar"

if exist "%WRAPPER_JAR%" (
    echo Gradle wrapper already exists.
    goto :eof
)

echo Downloading Gradle Wrapper...

:: Create directory if it doesn't exist
if not exist "%~dp0gradle\wrapper" mkdir "%~dp0gradle\wrapper"

:: Download gradle-wrapper.jar from GitHub (official Gradle releases)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/gradle/gradle/v8.0.0/gradle/wrapper/gradle-wrapper.jar' -OutFile '%WRAPPER_JAR%' -UseBasicParsing"

if exist "%WRAPPER_JAR%" (
    echo Gradle wrapper downloaded successfully.
) else (
    echo WARNING: Could not download gradle-wrapper.jar
    echo Please install Gradle manually or download the wrapper JAR from:
    echo https://github.com/gradle/gradle/raw/v8.0.0/gradle/wrapper/gradle-wrapper.jar
)
