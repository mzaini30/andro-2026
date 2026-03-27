# Andro: CLI Android Build Tool

## Overview
**Andro** is a zero-configuration CLI build tool that generates high-performance Android APK and AAB files from a simple YAML configuration. It focuses on wrapping web assets (HTML/CSS/JS) into a modern, permission-rich Android WebView with integrated **Start.io (formerly StartApp)** monetization.

**No Android Studio required** — uses Gradle wrapper and PowerShell scripts to automate the entire build process.

## Core Features
- **Zero Android Studio Required:** Uses Gradle wrapper and PowerShell scripts to automate the entire build process.
- **Modern WebView:** Chromium-based WebView with full ES6+ support, local storage, geolocation, and hardware acceleration.
- **Native JavaScript Bridge:** Exposes device information, battery status, native UI features (toast, vibration) to the web context via the `Android` object.
- **Integrated Monetization:** Built-in support for **Start.io (StartApp)** Banner ads and Interstitial ads.
- **Signed Releases:** Automatically handles keystore generation and release signing.

## Project Architecture
- `andro.bat`: The entry point for all commands (`build`, `clean`, `help`).
- `andro.yml`: The primary configuration file (YAML format).
- `android/generate_project.ps1`: The core engine that templates and generates the Android project source code.
- `android/app/`: The temporary/generated Android project directory.
- `android/ai/ads.txt`: Complete Start.io SDK integration documentation.

## Configuration Specification (`andro.yml`)
The configuration uses a list of key-value pairs:

```yaml
- title: "Hello World"
- version: "1"
- package: "com.example.helloworld"
- icon: "round.png"
- web: "html"
- ads: "202843390"
```

| Field | Description |
|-------|-------------|
| `title` | Application display name |
| `version` | Version string (used for both `versionCode` and `versionName`) |
| `package` | Unique Android package ID (e.g., `com.example.app`) |
| `icon` | Path to the launcher icon (PNG) |
| `web` | Directory containing the web assets |
| `ads` | Start.io App ID for monetization. **Leave empty** (`ads: ""`) to disable ads completely |

### Conditional Ads Feature

When `ads` is set to an empty string (`""`), the build system automatically:
- Excludes Start.io SDK dependencies from `build.gradle`
- Removes Start.io SDK initialization code from `MainActivity.java`
- Removes banner and interstitial ad implementations
- Excludes Start.io Maven repository from `settings.gradle`
- Removes Start.io ProGuard rules

This produces a cleaner, smaller APK without any ad-related code when monetization is not needed.

## Building and Running

### Prerequisites
- **Java JDK 11+** (required)
- **Android SDK** (optional, for system Gradle)
- **ANDROID_HOME** environment variable (recommended)

### Commands

```bash
# Build APK and AAB
andro
# or
andro build

# Clean build artifacts
andro clean

# Show help
andro help
```

### Output Files
- `android/app/build/outputs/apk/debug/app-debug.apk`
- `android/app/build/outputs/apk/release/app-release.apk`
- `android/app/build/outputs/bundle/release/app-release.aab`

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

## Key Features

### Modern WebView
- Full JavaScript (ES6+) support
- localStorage & sessionStorage
- Camera access
- File upload/download
- Hardware acceleration
- Mixed content support

### Auto-Requested Permissions
- Camera
- Storage (Read/Write)
- Microphone
- Bluetooth
- Battery stats

### Start.io Ads Integration
- SDK v5.1.0
- Automatic initialization via `AndroidManifest.xml`
- **Banner ads** displayed at the bottom of the screen
- **Interstitial ads** shown on back press (exit)
- Configurable via `ads` field in `andro.yml`
- **Set `ads: ""` to completely disable ads** (no SDK included)
- See `android/ai/ads.txt` for complete Start.io SDK documentation

### Signed Releases
- Auto-generated keystore at `android/keystore.jks`
- Ready for Google Play upload

## Keystore Details

| Field | Value |
|-------|-------|
| **CN** | Muhammad Zaini |
| **L** | Samarinda |
| **E** | muhzaini30@gmail.com |
| **Alias** | andro |
| **Store Password** | 0809894kali |
| **Key Password** | 0809894kali |
| **Validity** | 10000 days |

⚠️ **Backup `android/keystore.jks` securely** — required for all app updates!

## Internal Build Steps
1. **Parse Config:** `parse_yaml.ps1` extracts configurations from `andro.yml`.
2. **Create Directories:** `create_dirs.ps1` sets up the Android project structure.
3. **Generate Project:** `generate_project.ps1` creates:
   - `AndroidManifest.xml` with Start.io SDK configuration
   - `build.gradle` with dependencies
   - `MainActivity.java` with WebView and ad integration
   - Resource files (themes, strings, colors, file_paths)
4. **Compile:** `gradlew.bat` compiles the project into APK/AAB.

## Development Conventions

### Web Assets
- Place HTML/CSS/JS in the `html/` folder (or configured `web` path)
- Use relative paths: `<a href="about.html">`
- Include viewport meta tag for mobile: `<meta name="viewport" content="width=device-width, initial-scale=1.0">`
- All assets are copied to `android/app/src/main/assets/`

### MainActivity Features
- `configureWebView()` - Sets up WebView with all modern features
- `requestPermissions()` - Auto-requests all needed permissions
- `WebAppInterface` - JavaScript bridge for native features
- `onBackPressed()` - Shows interstitial ad on exit

### Gradle Configuration
- Compile SDK: 34
- Min SDK: 21
- Target SDK: 34
- AndroidX enabled

## File Descriptions

| File | Purpose |
|------|---------|
| `andro.bat` | Main build orchestrator (in root) |
| `android/generate_project.ps1` | Generates Android project structure |
| `android/bootstrap-gradle.bat` | Downloads Gradle wrapper JAR |
| `android/gradlew.bat` | Gradle wrapper script |
| `android/keystore.jks` | Release signing key |
| `android/app/build.gradle` | App-level Gradle configuration |
| `android/settings.gradle` | Root Gradle settings |
| `android/AndroidManifest.xml` | App permissions and configuration |
| `android/MainActivity.java` | WebView activity with native features and ads |
| `android/ai/ads.txt` | Complete Start.io SDK integration guide |

## Troubleshooting

### Common Issues

1. **"Java not found"**
   - Install JDK 11+ from https://adoptium.net/
   - Add to PATH: `setx PATH "%PATH%;%JAVA_HOME%\bin"`

2. **"ANDROID_HOME not set"**
   - Set environment variable to Android SDK location

3. **Build fails**
   - Run `andro clean` then `andro build`
   - Check internet connection (Gradle downloads dependencies)

4. **Ads not showing**
   - Verify App ID in Start.io dashboard
   - Test on real device (emulator has limited ad inventory)
   - Ensure internet connection is available

## Dependencies

### Android Libraries
- `androidx.appcompat:appcompat:1.6.1`
- `com.google.android.material:material:1.9.0`
- `androidx.constraintlayout:constraintlayout:2.1.4`
- `androidx.webkit:webkit:1.8.0`

### Start.io SDK
- `com.startapp:inapp-sdk:5.1.0`

### Build Tools
- Gradle 8.0
- Android Gradle Plugin 8.1.0

## Related Files

- `ai/ads.txt` - Complete Start.io SDK integration guide
- `README.md` - User-facing documentation
- `QWEN.md` - Project context and development notes
- `perintah.txt` - Original requirements (in Indonesian)

## Maintenance Notes

### Updating Generate Project
When making changes to the Android project structure, also update `android/generate_project.ps1` to ensure future builds include the changes.

### Start.io Ads
- **Banner ads** are added programmatically at the bottom of the screen in `MainActivity.java`
- **Interstitial ads** are triggered via `StartAppAd.onBackPressed(this)` when the user presses back
- SDK is initialized automatically via `AndroidManifest.xml` meta-data
- See `android/ai/ads.txt` for advanced integration options

### Assets
Web assets are served from `https://appassets.androidplatform.net/assets/` to bypass CORS and mixed-content issues.

---

**Built with ❤️ for rapid Android app development**
