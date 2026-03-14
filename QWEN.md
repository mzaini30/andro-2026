# Andro Project

## Project Overview

**Andro** is a CLI build tool that generates Android APK and AAB files from a simple YAML configuration—**without requiring Android Studio**. It creates a complete Android project with a modern WebView for displaying web assets and integrated Start.io (formerly StartApp) ads for monetization.

## Project Structure

```
D:\Andro\
├── andro.yml              # Main configuration file (root)
├── andro.md               # User documentation (root)
├── andro.bat              # Main build script (run this)
├── html/                  # Web assets (or configured path)
│   ├── index.html         # Home page
│   └── about.html         # About page
├── round.png              # Application icon
├── perintah.txt           # Original requirements document
├── QWEN.md                # This file - project context
├── README.md              # User documentation
└── android/               # All Android build files and scripts
    ├── accept-licenses.bat
    ├── bootstrap-gradle.bat
    ├── build.gradle
    ├── create_dirs.ps1
    ├── generate_project.ps1
    ├── gradle.properties
    ├── gradlew.bat
    ├── install-packages.bat
    ├── install-sdk.bat
    ├── keystore.jks           # Signing key (auto-generated)
    ├── parse_yaml.ps1
    ├── settings.gradle
    ├── ai/
    │   └── ads.txt            # Start.io SDK documentation
    ├── gradle/
    │   └── wrapper/
    │       └── gradle-wrapper.properties
    └── app/                   # Generated Android project
        ├── build.gradle
        ├── proguard-rules.pro
        └── src/main/
            ├── AndroidManifest.xml
            ├── java/.../MainActivity.java
            ├── res/
            └── assets/
```

## Configuration (`andro.yml`)

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
| `title` | App display name |
| `version` | Version code and name |
| `package` | Android package name |
| `icon` | Path to launcher icon |
| `web` | Path to web assets folder |
| `ads` | Start.io App ID |

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

## Key Features

### Modern WebView
- Full JavaScript (ES6+) support
- localStorage & sessionStorage
- Geolocation API
- Camera access
- File upload/download
- Hardware acceleration
- Mixed content support

### Native JavaScript Interface
```javascript
// Device info
Android.getDeviceInfo()  // {"brand":"...", "model":"...", ...}

// Battery status
Android.getBatteryInfo() // {"level":85, "charging":true}

// Toast notification
Android.showToast("Hello!")

// Vibrate
Android.vibrate(1000)
```

### Auto-Requested Permissions
- Camera
- Location (GPS)
- Storage (Read/Write)
- Microphone
- Bluetooth
- Battery stats

### Start.io Ads Integration
- SDK v5.1.0
- Automatic initialization
- Interstitial ads on back press
- Configurable via `ads` field

### Signed Releases
- Auto-generated keystore
- Stored at `android/keystore.jks`
- Ready for Google Play

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

⚠️ **Backup `android/keystore.jks` securely**—required for all app updates!

## Development Conventions

### Web Assets
- Place HTML/CSS/JS in the `html/` folder (or configured `web` path)
- Use absolute paths: `<a href="/about.html">`
- Include viewport meta tag for mobile
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
- ProGuard enabled for release builds

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
| `android/MainActivity.java` | WebView activity with native features |

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

## Dependencies

### Android Libraries
- `androidx.appcompat:appcompat:1.6.1`
- `com.google.android.material:material:1.9.0`
- `androidx.webkit:webkit:1.8.0`

### Start.io SDK
- `com.startapp:inapp-sdk:5.1.0`

### Build Tools
- Gradle 8.0
- Android Gradle Plugin 8.1.0

## Related Files

- `ai/ads.txt` - Complete Start.io SDK integration guide
- `README.md` - User-facing documentation
- `perintah.txt` - Original requirements (in Indonesian)

## Iklan 

- Untuk iklan, hanya gunakan Admob
- Untuk cara menggunakan Admob, cek ./Admob/Persiapan.txt, ./Admob/Banner.txt, ./Admob/AppOpen.txt

## Update Generate Project

- Ketika ada perubahan di project Android, update juga file ./android/generate_project.ps1