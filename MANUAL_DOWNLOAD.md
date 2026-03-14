# Manual SDK Package Downloads

If the automatic installation fails, you can download these packages manually.

## AdMob (Google Mobile Ads SDK)

**No manual download required!** The Google Mobile Ads SDK is automatically downloaded via Gradle/Maven during the build process.

**Dependencies (automatic):**
- `com.google.android.gms:play-services-ads:25.0.0`
- `androidx.lifecycle:lifecycle-process:2.8.3`

These are fetched from Google's Maven repository and Maven Central automatically.

### Important: Minimum SDK Version Requirement

AdMob SDK v25.0.0 requires **minimum SDK version 23** (Android 6.0). The project has been configured with:

- **Android Gradle Plugin:** 8.3.0
- **Gradle:** 8.4
- **minSdk:** 23 (required for AdMob)
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

### 3. Android SDK Platform 23 (Android 6.0) - Minimum SDK for AdMob
**Download:** https://dl.google.com/android/repository/platform-23_r03.zip

**Alternative:** https://dl-l.google.com/android/repository/platform-23_r03.zip

**Installation:**
1. Extract to `D:\Android\Sdk\platforms\android-23\`

**Note:** Required because AdMob SDK v25.0.0 requires minSdkVersion 23 or higher.

---

### 4. Android SDK Build-Tools 34.0.0
**Download:** https://dl.google.com/android/repository/build-tools_r34-windows.zip

**Installation:**
1. Extract to `D:\Android\Sdk\build-tools\34.0.0\`

---

### 5. Android SDK Build-Tools 33.0.1
**Download:** https://dl.google.com/android/repository/build-tools_r33.0.1-windows.zip

**Installation:**
1. Extract to `D:\Android\Sdk\build-tools\33.0.1\`

---

### 6. Platform-Tools (ADB & Fastboot)
**Download:** https://dl.google.com/android/repository/platform-tools-latest-windows.zip

**Installation:**
1. Extract to `D:\Android\Sdk\platform-tools\`

---

## Alternative Download Sources

If Google's direct links don't work, try these alternatives:

### SDK Platform 34
- https://redirector.gvt1.com/edgedl/android/repository/platform-34-ext8_r01.zip
- https://dl-l.google.com/android/repository/platform-34-ext8_r01.zip

### SDK Platform 23 (Required for AdMob minSdk)
- https://dl.google.com/android/repository/platform-23_r03.zip
- https://dl-l.google.com/android/repository/platform-23_r03.zip

### Build Tools
- Build-Tools 34.0.0: https://dl.google.com/android/repository/build-tools_r34-windows.zip
- Build-Tools 33.0.1: https://dl.google.com/android/repository/build-tools_r33.0.1-windows.zip

### Platform Tools
- https://dl.google.com/android/repository/platform-tools-latest-windows.zip

---

## Manual Installation Steps

### Option 1: Using sdkmanager (Recommended)

After downloading the command-line tools:

```bat
cd D:\Android\Sdk\cmdline-tools\latest\bin
sdkmanager.bat --sdk_root="D:\Android\Sdk" --install "platform-tools" "platforms;android-34" "platforms;android-23" "build-tools;34.0.0" "build-tools;33.0.1"
```

### Option 2: Manual Extraction

1. Create the directory structure:
   ```
   D:\Android\Sdk\
   ├── cmdline-tools\
   │   └── latest\
   ├── platforms\
   │   ├── android-34\
   │   └── android-23\
   ├── build-tools\
   │   ├── 34.0.0\
   │   └── 33.0.1\
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
- `platforms;android-23`
- `build-tools;34.0.0`
- `build-tools;33.0.1`

---

## Then Build

After all packages are installed and project files are updated:

```bat
andro clean
andro build
```

---

## Project Files to Update for AdMob

The project has already been configured with the correct settings. No manual updates needed!

**Current configuration:**
- `android/app/build.gradle`: minSdk 23 ✓
- `android/generate_project.ps1`: minSdk 23 ✓
- Android Gradle Plugin: 8.3.0 ✓
- Gradle: 8.4 ✓

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
