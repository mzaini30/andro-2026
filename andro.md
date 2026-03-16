# Andro: CLI Android Build Tool

## Overview
**Andro** is a zero-configuration CLI build tool that generates high-performance Android APK and AAB files from a simple YAML configuration. It focuses on wrapping web assets (HTML/CSS/JS) into a modern, permission-rich Android WebView with integrated AdMob monetization.

## Core Features
- **Zero Android Studio Required:** Uses Gradle wrapper and PowerShell scripts to automate the entire build process.
- **Modern WebView:** Chromium-based WebView with full ES6+ support, local storage, geolocation, and hardware acceleration.
- **Native JavaScript Bridge:** Exposes device information, battery status, native UI features (toast, vibration) to the web context via the `Android` object.
- **Integrated Monetization:** Built-in support for AdMob App Open ads, Banner ads, and Rewarded ads.
- **Signed Releases:** Automatically handles keystore generation and release signing.

## Project Architecture
- `andro.bat`: The entry point for all commands (`build`, `clean`, `init`).
- `andro.yml`: The primary configuration file (YAML format).
- `android/generate_project.ps1`: The core engine that templates and generates the Android project source code.
- `android/app/`: The temporary/generated Android project directory.

## Configuration Specification (`andro.yml`)
The configuration uses a list of key-value pairs:

```yaml
- title: "Hello World"
- version: "1"
- package: "com.example.helloworld"
- icon: "round.png"
- web: "html"
- ads:
  - id: "ca-app-pub-3940256099942544~3347511713"
  - banner: "ca-app-pub-3940256099942544/6300978111"
  - open: "ca-app-pub-3940256099942544/3419835294"
  - rewarded: "ca-app-pub-3940256099942544/5224354917"
```

| Field | Description |
|-------|-------------|
| `title` | Application display name |
| `version` | Version string (used for both `versionCode` and `versionName`) |
| `package` | Unique Android package ID (e.g., `com.example.app`) |
| `icon` | Path to the launcher icon (PNG) |
| `web` | Directory containing the web assets |
| `ads.id` | AdMob App ID |
| `ads.banner` | AdMob Banner Ad Unit ID |
| `ads.open` | AdMob App Open Ad Unit ID |
| `ads.rewarded` | AdMob Rewarded Ad Unit ID |

## JavaScript Interface (`Android` object)

### Native UI & Haptics
```javascript
// Native Toasts
Android.showToast("Message from Web");

// Haptic Feedback
Android.vibrate(500); // milliseconds
```

### Device Information
```javascript
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
   - `generate_project.ps1` creates `AndroidManifest.xml`, `build.gradle`, `MainActivity.java`, `AppOpenManager.java`, `JavaScriptInterface.java`, and `activity_main.xml` with injected configurations.
   - `gradlew.bat` compiles the project into APK/AAB.

## Maintenance Notes
- **Ads:**
  - **Banner ads** are added programmatically at the bottom of the screen in `MainActivity.java`.
  - **App Open ads** are managed by `AppOpenManager.java` which shows ads when the app is foregrounded (in `onResume()`).
  - **Rewarded ads** can be loaded using the Google Mobile Ads SDK directly in your Java code.
- **Permissions:** The tool automatically requests common permissions (Camera, Location, Storage, Bluetooth) via the AndroidManifest.
- **Assets:** Web assets are served from a virtual host `https://appassets.androidplatform.net/assets/` to bypass CORS and mixed-content issues.
- **Generated Files:**
  - `AppOpenManager.java`: Handles App Open ad lifecycle with expiration checking (4-hour limit).
  - `JavaScriptInterface.java`: JavaScript bridge for native features (toast, vibrate, device info, battery info).
  - `MainActivity.java`: Main activity with WebView, Banner ads, and App Open integration.
  - `activity_main.xml`: Simple FrameLayout containing only the WebView.
