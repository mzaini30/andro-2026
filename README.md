# Andro Build Tool

Build Android APK and AAB files from a simple YAML configuration—**without Android Studio**.

## Quick Start

```bash
andro
```

That's it! This will read `andro.yml` and generate:
- `app-debug.apk` - Debug APK
- `app-release.apk` - Release APK  
- `app-release.aab` - Android App Bundle (for Google Play)

## Configuration

Create an `andro.yml` file in the project root:

```yaml
- title: "Hello World"
- version: "1"
- package: "com.example.helloworld"
- icon: "round.png"
- web: "html"
- ads: "202843390"
```

### Configuration Options

| Field | Description | Example |
|-------|-------------|---------|
| `title` | App name displayed to users | `"My App"` |
| `version` | Version number (used for versionCode and versionName) | `"1"` |
| `package` | Android package name (must be unique) | `"com.example.app"` |
| `icon` | Path to app icon image | `"icon.png"` |
| `web` | Path to web assets folder (HTML/CSS/JS) | `"www"` |
| `ads` | Start.io App ID for monetization | `"123456789"` |

## Features

### 🌐 Modern WebView
- Full JavaScript support (ES6+)
- localStorage & sessionStorage
- Geolocation API
- Camera access
- File upload/download
- Hardware acceleration

### 📱 Native Features via JavaScript Interface

Access native Android features from your web code:

```javascript
// Get device info
const device = Android.getDeviceInfo();
console.log(device); // {"brand":"Samsung","model":"Galaxy S21",...}

// Get battery status
const battery = Android.getBatteryInfo();
console.log(battery); // {"level":85,"charging":true}

// Show toast notification
Android.showToast("Hello from JavaScript!");

// Vibrate device
Android.vibrate(1000); // Vibrate for 1 second
```

### 📍 Permissions Automatically Requested
- Camera
- Location (GPS)
- Storage (Read/Write)
- Microphone
- Bluetooth
- Battery stats

### 💰 Start.io Ads Integration
- Automatic SDK initialization
- Interstitial ads on back press
- Configurable via `ads` field in `andro.yml`
- See `ai/ads.txt` for full documentation

### 🔐 Signed Release Builds
- Automatic keystore generation
- Secure key storage
- Ready for Google Play upload

## Requirements

### Required
- **Java JDK 11 or higher**
  - Download: https://adoptium.net/
  - Verify: `java -version`

### Optional (for building)
- **Android SDK** (if not using system Gradle)
- **Gradle 8.0+** (included via wrapper)
- **ANDROID_HOME** environment variable

### Setting Up Java

1. Install JDK 11 or higher from https://adoptium.net/
2. Add Java to your PATH:
   ```bash
   # Windows (PowerShell as Administrator)
   setx JAVA_HOME "C:\Program Files\Eclipse Adoptium\jdk-17.0.0"
   setx PATH "%PATH%;%JAVA_HOME%\bin"
   ```

## Commands

### Build APK and AAB
```bash
andro
# or explicitly:
andro build
```

### Clean Build Artifacts
```bash
andro clean
```

### Show Help
```bash
andro help
```

## Project Structure

After running `andro`, your project will look like:

```
D:\Andro\
├── andro.yml              # Your configuration
├── andro.bat              # Build script
├── keystore.jks           # Signing key (auto-generated)
├── round.png              # Your app icon
├── html/                  # Your web assets
│   ├── index.html
│   └── about.html
├── app/                   # Generated Android project
│   ├── build.gradle
│   ├── src/main/
│   │   ├── AndroidManifest.xml
│   │   ├── java/.../MainActivity.java
│   │   ├── res/
│   │   └── assets/        # Copied from html/
│   └── build/outputs/     # Build outputs
│       ├── apk/
│       └── bundle/
└── gradle/                # Gradle wrapper
```

## HTML/JS Best Practices

### Absolute Paths
The tool handles absolute paths automatically. Use:
```html
<a href="/about.html">About</a>
```

### Responsive Design
```html
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

### Accessing Native Features
```javascript
// Check if running in Android WebView
if (typeof Android !== 'undefined') {
    // Native features available
    const device = JSON.parse(Android.getDeviceInfo());
    console.log('Running on:', device.model);
}
```

## Troubleshooting

### "Java not found"
```bash
# Check Java installation
java -version

# If not found, install JDK and add to PATH
```

### "ANDROID_HOME not set"
```bash
# Windows (PowerShell)
$env:ANDROID_HOME="D:\Android\Sdk"

# Add to system environment variables for permanent fix
```

### Build fails with Gradle errors
```bash
# Clean and rebuild
andro clean
andro build

# Or with verbose output
gradlew.bat assembleRelease --info
```

### Ads not showing
1. Verify App ID in `andro.yml` matches Start.io dashboard
2. Check internet connection
3. Ensure `ai/ads.txt` integration steps are followed
4. Test on real device (emulator may have limited ad inventory)

## Keystore Information

The keystore is auto-generated with these details:

| Field | Value |
|-------|-------|
| **CN** | Muhammad Zaini |
| **L** | Samarinda |
| **E** | muhzaini30@gmail.com |
| **Alias** | andro |
| **Validity** | 10000 days |

⚠️ **Important**: Backup `keystore.jks` securely. You'll need it for all future app updates.

## Advanced Usage

### Custom Gradle Configuration

Edit `app/build.gradle` for advanced options:

```gradle
android {
    // Add custom build types
    buildTypes {
        staging {
            minifyEnabled true
            debuggable true
        }
    }
    
    // Add flavor dimensions
    flavorDimensions "version"
    productFlavors {
        free {
            dimension "version"
        }
        paid {
            dimension "version"
        }
    }
}
```

### ProGuard Rules

Edit `app/proguard-rules.pro` to keep specific classes:

```proguard
# Keep your JavaScript interface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
```

## License

This tool is provided as-is for building Android applications from web assets.

## Support

For issues with:
- **Start.io Ads**: See `ai/ads.txt` or contact Start.io support
- **Build errors**: Check Java/Android SDK installation
- **WebView features**: Ensure all permissions are granted

---

**Built with ❤️ for rapid Android app development**
