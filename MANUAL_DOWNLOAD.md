# Manual SDK Package Downloads

If the automatic installation fails, you can download these packages manually.

## Start.io (formerly StartApp) SDK

**No manual download required!** The Start.io SDK is automatically downloaded via Gradle/Maven during the build process.

**Dependencies (automatic):**
- `com.startapp:inapp-sdk:5.1.0`

This is fetched from Start.io's Maven repository (`https://s3.amazonaws.com/startapp/`) automatically.

### Important: SDK Configuration

The project has been configured with:

- **Android Gradle Plugin:** 8.1.0
- **Gradle:** 8.0
- **minSdk:** 21
- **compileSdk:** 34
- **targetSdk:** 34

---

## Required SDK Packages

### 1. Android SDK Command-line Tools
**Download:** https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip

**Installation:**
1. Extract to `D:\Android\Sdk\cmdline-tools\latest\`
2. The `bin\sdkmanager.bat` should be at `D:\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat`

---

### 2. Android SDK Platform 34 (Android 14) - Compile SDK
**Download:** https://dl.google.com/android/repository/platform-34-ext8_r01.zip

**Alternative:** https://dl.google.com/android/repository/platform-34-ext8.zip

**Installation:**
1. Extract to `D:\Android\Sdk\platforms\android-34\`

---

### 3. Android SDK Platform 33 (Android 13)
**Download:** https://dl.google.com/android/repository/platform-33-ext4_r01.zip

**Installation:**
1. Extract to `D:\Android\Sdk\platforms\android-33\`

---

### 4. Android SDK Platform 23 (Android 6.0) - Minimum SDK
**Download:** https://dl.google.com/android/repository/platform-23_r03.zip

**Alternative:** https://dl-l.google.com/android/repository/platform-23_r03.zip

**Installation:**
1. Extract to `D:\Android\Sdk\platforms\android-23\`

---

### 5. Android SDK Build-Tools 34.0.0
**Download:** https://dl.google.com/android/repository/build-tools_r34-windows.zip

**Installation:**
1. Extract to `D:\Android\Sdk\build-tools\34.0.0\`

---

### 6. Android SDK Build-Tools 33.0.1
**Download:** https://dl.google.com/android/repository/build-tools_r33.0.1-windows.zip

**Installation:**
1. Extract to `D:\Android\Sdk\build-tools\33.0.1\`

---

### 7. Android SDK Build-Tools 30.0.2
**Download:** https://dl.google.com/android/repository/build-tools_r30.0.2-windows.zip (link mati)

**Installation:**
1. Extract to `D:\Android\Sdk\build-tools\30.0.2\`

---

### 8. Android SDK Platform 33 (Android 13)
**Download:** https://dl.google.com/android/repository/platform-33-ext4_r01.zip

**Installation:**
1. Extract to `D:\Android\Sdk\platforms\android-33\`

---

### 9. Platform-Tools (ADB & Fastboot)
**Download:** https://dl.google.com/android/repository/platform-tools-latest-windows.zip

**Installation:**
1. Extract to `D:\Android\Sdk\platform-tools\`

---

## Alternative Download Sources

If Google's direct links don't work, try these alternatives:

### SDK Platforms
- Platform 34: https://dl.google.com/android/repository/platform-34-ext8_r01.zip
- Platform 33: https://dl.google.com/android/repository/platform-33-ext4_r01.zip
- Platform 23: https://dl.google.com/android/repository/platform-23_r03.zip

### Build Tools
- Build-Tools 34.0.0: https://dl.google.com/android/repository/build-tools_r34-windows.zip
- Build-Tools 33.0.1: https://dl.google.com/android/repository/build-tools_r33.0.1-windows.zip
- Build-Tools 30.0.2: https://dl.google.com/android/repository/build-tools_r30.0.2-windows.zip

### Platform Tools
- https://dl.google.com/android/repository/platform-tools-latest-windows.zip

---

## Manual Installation Steps

### Option 1: Using sdkmanager (Recommended)

After downloading the command-line tools:

```bat
cd D:\Android\Sdk\cmdline-tools\latest\bin
sdkmanager.bat --sdk_root="D:\Android\Sdk" --install "platform-tools" "platforms;android-34" "platforms;android-33" "platforms;android-23" "build-tools;34.0.0" "build-tools;33.0.1" "build-tools;30.0.2"
```

### Option 2: Manual Extraction

1. Create the directory structure:
   ```
   D:\Android\Sdk\
   ├── cmdline-tools\
   │   └── latest\
   ├── platforms\
   │   ├── android-34\
   │   ├── android-33\
   │   └── android-23\
   ├── build-tools\
   │   ├── 34.0.0\
   │   ├── 33.0.1\
   │   └── 30.0.2\
   └── platform-tools\
   ```

2. Extract each ZIP file to its corresponding directory

3. Accept licenses by running:
   ```bat
   accept-licenses.bat
   ```

---

## Verify Installation

After installation, verify with:

```bat
D:\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat --sdk_root="D:\Android\Sdk" --list_installed
```

You should see:
- `platform-tools`
- `platforms;android-34`
- `platforms;android-33`
- `platforms;android-23`
- `build-tools;34.0.0`
- `build-tools;33.0.1`
- `build-tools;30.0.2`

---

## Then Build

After all packages are installed and project files are updated:

```bat
andro clean
andro build
```

---

## Project Files for Start.io

The project has already been configured with the correct settings for Start.io ads.

**Current configuration:**
- `android/app/build.gradle`: Start.io SDK 5.1.0 ✓
- `android/settings.gradle`: Start.io Maven repository ✓
- `android/generate_project.ps1`: Start.io integration ✓
- Android Gradle Plugin: 8.1.0 ✓
- Gradle: 8.0 ✓

---

## Troubleshooting

### "License not accepted" error
Run:
```bat
accept-licenses.bat
```

### "sdkmanager not found" error
Make sure command-line tools are extracted to:
`D:\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat`

### Build still fails
Clean and rebuild:
```bat
andro clean
andro build
```

### Download links not working
1. Try using a different browser
2. Clear browser cache
3. Use the `install-packages.bat` script for automatic installation
4. Check your internet connection and firewall settings

### Start.io ads not showing
1. Verify App ID in Start.io dashboard
2. Test on real device (emulator has limited ad inventory)
3. Check internet connection
4. Make sure the `ads` field in `andro.yml` contains your Start.io App ID
