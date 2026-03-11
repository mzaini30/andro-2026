# Andro: CLI Android Build Tool (LLM AI Coding Notes)

## Overview
**Andro** is a zero-configuration CLI build tool that generates high-performance Android APK and AAB files from a simple YAML configuration. It focuses on wrapping web assets (HTML/CSS/JS) into a modern, permission-rich Android WebView with integrated Start.io monetization.

## Core Features
- **Zero Android Studio Required:** Uses Gradle wrapper and PowerShell scripts to automate the entire build process.
- **Modern WebView:** Chromium-based WebView with full ES6+ support, local storage, geolocation, and hardware acceleration.
- **Native JavaScript Bridge:** Exposes device information, battery status, and native UI features (toast, vibration) to the web context via the `Android` object.
- **Integrated Monetization:** Built-in support for Start.io (formerly StartApp) Interstitial, Splash, and Banner ads.
- **Signed Releases:** Automatically handles keystore generation and release signing.

## Project Architecture
- `andro.bat`: The entry point for all commands (`build`, `clean`, `init`).
- `andro.yml`: The primary configuration file (YAML format).
- `generate_project.ps1`: The core engine that templates and generates the Android project source code.
- `app/`: The temporary/generated Android project directory.

## Configuration Specification (`andro.yml`)
The configuration uses a list of key-value pairs:
- `title`: Application name.
- `version`: Version string (used for both `versionCode` and `versionName`).
- `package`: Unique Android package ID (e.g., `com.example.app`).
- `icon`: Path to the launcher icon (PNG).
- `web`: Directory containing the web assets.
- `ads`: Start.io Application ID.

## JavaScript Interface (`Android` object)
```javascript
// Native Toasts
Android.showToast("Message from Web");

// Haptic Feedback
Android.vibrate(500); // milliseconds

// Device Information
const info = JSON.parse(Android.getDeviceInfo());
// Returns: { brand, model, version, sdk }

// Battery Status
const battery = JSON.parse(Android.getBatteryInfo());
// Returns: { level, charging }
```

## Internal Build Steps
1. **Init:** `andro init` creates a boilerplate `andro.yml`.
2. **Build:** 
   - `parse_yaml.ps1` extracts configurations.
   - `create_dirs.ps1` sets up the Android project structure.
   - `generate_project.ps1` creates `AndroidManifest.xml`, `build.gradle`, and `MainActivity.java` with injected configurations.
   - `gradlew.bat` compiles the project into APK/AAB.

## Maintenance Notes
- **Ads:** Banner ads are automatically placed at the bottom of the screen using a `RelativeLayout` that wraps the `WebView`.
- **Permissions:** The tool automatically requests common permissions (Camera, Location, Storage, Bluetooth) during `onCreate`.
- **Assets:** Web assets are served from a virtual host `https://appassets.androidplatform.net/assets/` to bypass CORS and mixed-content issues.
