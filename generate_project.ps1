param(
    [string]$title,
    [string]$version,
    [string]$package,
    [string]$ads,
    [string]$output
)

# Convert package name to path (e.g., com.example.helloworld -> com\example\helloworld)
$packagePath = $package -replace '\.', '\'

# Create settings.gradle
$settingsGradle = @"
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "$title"
include ':app'
"@
Set-Content -Path "$output\settings.gradle" -Value $settingsGradle -Encoding UTF8

# Create root build.gradle
$rootBuildGradle = @"
// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    id 'com.android.application' version '8.1.0' apply false
}
"@
Set-Content -Path "$output\build.gradle" -Value $rootBuildGradle -Encoding UTF8

# Create gradle.properties
$gradleProperties = @"
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
"@
Set-Content -Path "$output\gradle.properties" -Value $gradleProperties -Encoding UTF8

# Create app/build.gradle
$appBuildGradle = @"
plugins {
    id 'com.android.application'
}

android {
    namespace '$package'
    compileSdk 34

    defaultConfig {
        applicationId '$package'
        minSdk 21
        targetSdk 34
        versionCode $version
        versionName '$version'

        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            signingConfig signingConfigs.release
        }
        debug {
            minifyEnabled false
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    signingConfigs {
        release {
            storeFile file('../keystore.jks')
            storePassword '0809894kali'
            keyAlias 'andro'
            keyPassword '0809894kali'
        }
    }
}

dependencies {
    // AndroidX
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.9.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.webkit:webkit:1.8.0'

    // Start.io SDK (formerly StartApp)
    implementation 'com.startapp:inapp-sdk:5.1.0'

    // Testing
    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.1.5'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
}
"@
Set-Content -Path "$output\app\build.gradle" -Value $appBuildGradle -Encoding UTF8

# Create proguard-rules.pro
$proguardRules = @"
# Start.io SDK
-keep class com.startapp.** { *; }
-keep class com.truenet.** { *; }
-keepattributes Exceptions, InnerClasses, Signature, Deprecated, SourceFile, LineNumberTable, *Annotation*, EnclosingMethod
-dontwarn android.webkit.JavascriptInterface
-dontwarn com.startapp.**
-dontwarn org.jetbrains.annotations.**
"@
Set-Content -Path "$output\app\proguard-rules.pro" -Value $proguardRules -Encoding UTF8

# Create AndroidManifest.xml
$androidManifest = @"
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <!-- Internet and Network -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" tools:node="remove"/>

    <!-- Location/GPS -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

    <!-- Camera -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />

    <!-- Storage -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
        android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
        android:maxSdkVersion="32" 
        tools:ignore="ScopedStorage" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

    <!-- Battery and Power -->
    <uses-permission android:name="android.permission.BATTERY_STATS" />

    <!-- Bluetooth -->
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />

    <!-- Advertising ID (Android 12+) -->
    <uses-permission android:name="android.permission.AD_ID" />

    <!-- Vibration -->
    <uses-permission android:name="android.permission.VIBRATE" />

    <!-- Application -->
    <application
        android:allowBackup="true"
        android:icon="@drawable/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@drawable/ic_launcher"
        android:supportsRtl="true"
        android:theme="@style/Theme.Andro"
        android:usesCleartextTraffic="true"
        android:hardwareAccelerated="true">

        <!-- Start.io SDK Configuration -->
        <meta-data
            android:name="com.startapp.sdk.APPLICATION_ID"
            android:value="$ads" />
        <meta-data
            android:name="com.startapp.sdk.RETURN_ADS_ENABLED"
            android:value="true" />

        <!-- Main Activity -->
        <activity
            android:name=".MainActivity"
            android:configChanges="orientation|screenSize|keyboard|keyboardHidden"
            android:exported="true"
            android:theme="@style/Theme.Andro">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <!-- File Provider for file uploads/downloads -->
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths" />
        </provider>

    </application>
</manifest>
"@
Set-Content -Path "$output\app\src\main\AndroidManifest.xml" -Value $androidManifest -Encoding UTF8

# Create strings.xml
$stringsXml = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">$title</string>
</resources>
"@
Set-Content -Path "$output\app\src\main\res\values\strings.xml" -Value $stringsXml -Encoding UTF8

# Create colors.xml
$colorsXml = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="purple_200">#FFBB86FC</color>
    <color name="purple_500">#FF6200EE</color>
    <color name="purple_700">#FF3700B3</color>
    <color name="teal_200">#FF03DAC5</color>
    <color name="teal_700">#FF018786</color>
    <color name="black">#FF000000</color>
    <color name="white">#FFFFFFFF</color>
</resources>
"@
Set-Content -Path "$output\app\src\main\res\values\colors.xml" -Value $colorsXml -Encoding UTF8

# Create themes.xml
$themesXml = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.Andro" parent="Theme.MaterialComponents.DayNight.NoActionBar">
        <item name="android:statusBarColor">@color/purple_700</item>
        <item name="android:windowFullscreen">false</item>
    </style>
"@
Set-Content -Path "$output\app\src\main\res\values\themes.xml" -Value $themesXml -Encoding UTF8

# Create file_paths.xml
$filePathsXml = @"
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path name="external_files" path="." />
    <cache-path name="cache_files" path="." />
    <files-path name="files" path="." />
    <external-files-path name="external_app_files" path="." />
    <external-cache-path name="external_cache" path="." />
</paths>
"@
Set-Content -Path "$output\app\src\main\res\xml\file_paths.xml" -Value $filePathsXml -Encoding UTF8

# Create MainActivity.java
$mainActivity = @"
package $package;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.provider.Settings;
import android.view.View;
import android.webkit.CookieManager;
import android.webkit.GeolocationPermissions;
import android.webkit.JavascriptInterface;
import android.webkit.PermissionRequest;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;

import com.startapp.sdk.AppUpdate;
import com.startapp.sdk.StartAppSDK;
import com.startapp.sdk.adsbase.StartAppAd;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class MainActivity extends AppCompatActivity {

    private WebView webView;
    private ValueCallback<Uri[]> fileUploadCallback;
    private static final int FILE_CHOOSER_REQUEST = 1;
    private static final int PERMISSION_REQUEST_CODE = 100;
    private String currentPhotoPath;

    private static final String[] REQUIRED_PERMISSIONS = {
        Manifest.permission.CAMERA,
        Manifest.permission.READ_EXTERNAL_STORAGE,
        Manifest.permission.WRITE_EXTERNAL_STORAGE,
        Manifest.permission.ACCESS_FINE_LOCATION,
        Manifest.permission.ACCESS_COARSE_LOCATION,
        Manifest.permission.RECORD_AUDIO,
        Manifest.permission.BLUETOOTH,
        Manifest.permission.BLUETOOTH_CONNECT,
        Manifest.permission.BLUETOOTH_SCAN
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Initialize Start.io SDK
        StartAppSDK.init(this, "$ads", true);
        StartAppSDK.setDeviceId(Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID));
        AppUpdate.update(this);

        // Request permissions
        requestPermissions();

        // Create WebView
        webView = new WebView(this);
        setContentView(webView);

        // Configure WebView
        configureWebView();

        // Load the main page
        webView.loadUrl("file:///android_asset/index.html");
    }

    private void requestPermissions() {
        List<String> permissionsToRequest = new ArrayList<>();
        
        for (String permission : REQUIRED_PERMISSIONS) {
            if (ContextCompat.checkSelfPermission(this, permission) 
                    != PackageManager.PERMISSION_GRANTED) {
                permissionsToRequest.add(permission);
            }
        }

        if (!permissionsToRequest.isEmpty()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION.M) {
                requestPermissions(
                    permissionsToRequest.toArray(new String[0]), 
                    PERMISSION_REQUEST_CODE
                );
            }
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, 
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        
        if (requestCode == PERMISSION_REQUEST_CODE) {
            boolean allGranted = true;
            for (int result : grantResults) {
                if (result != PackageManager.PERMISSION_GRANTED) {
                    allGranted = false;
                    break;
                }
            }
            
            if (!allGranted) {
                Toast.makeText(this, "Some permissions were denied. Some features may not work.", 
                    Toast.LENGTH_LONG).show();
            }
        }
    }

    private void configureWebView() {
        WebSettings webSettings = webView.getSettings();
        
        // Enable JavaScript
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true);
        webSettings.setDatabaseEnabled(true);
        
        // Enable modern web features
        webSettings.setJavaScriptCanOpenWindowsAutomatically(true);
        webSettings.setMediaPlaybackRequiresUserGesture(false);
        webSettings.setAllowFileAccess(true);
        webSettings.setAllowContentAccess(true);
        webSettings.setAllowFileAccessFromFileURLs(true);
        webSettings.setAllowUniversalAccessFromFileURLs(true);
        
        // Enable localStorage and sessionStorage
        webSettings.setDomStorageEnabled(true);
        
        // Enable geolocation
        webSettings.setGeolocationEnabled(true);
        
        // Enable zoom
        webSettings.setSupportZoom(true);
        webSettings.setBuiltInZoomControls(true);
        webSettings.setDisplayZoomControls(false);
        
        // Cache settings
        webSettings.setCacheMode(WebSettings.LOAD_DEFAULT);
        webSettings.setAppCacheEnabled(true);
        
        // Modern web support
        webSettings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
        
        // Hardware acceleration
        webView.setLayerType(View.LAYER_TYPE_HARDWARE, null);
        
        // JavaScript Interface for native features
        webView.addJavascriptInterface(new WebAppInterface(), "Android");
        
        // WebViewClient for handling page navigation
        webView.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                if (url.startsWith("http://") || url.startsWith("https://") || 
                    url.startsWith("file://")) {
                    view.loadUrl(url);
                    return true;
                }
                // Handle other URL schemes
                try {
                    Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
                    startActivity(intent);
                } catch (Exception e) {
                    // URL scheme not supported
                }
                return true;
            }
        });
        
        // WebChromeClient for advanced features
        webView.setWebChromeClient(new WebChromeClient() {
            // Geolocation permissions
            @Override
            public void onGeolocationPermissionsShowPrompt(String origin, 
                    GeolocationPermissions.Callback callback) {
                callback.invoke(origin, true, false);
            }
            
            // File upload handling
            @Override
            public boolean onShowFileChooser(WebView webView, ValueCallback<Uri[]> filePathCallback, 
                    FileChooserParams fileChooserParams) {
                if (fileUploadCallback != null) {
                    fileUploadCallback.onReceiveValue(null);
                }
                fileUploadCallback = filePathCallback;
                openFilePicker(fileChooserParams.getAcceptTypes(), 
                    fileChooserParams.isCaptureEnabled());
                return true;
            }
            
            // Permission requests (camera, microphone, etc.)
            @Override
            public void onPermissionRequest(PermissionRequest request) {
                if (Build.VERSION.SDK_INT >= Build.VERSION.LOLLIPOP) {
                    request.grant(request.getResources());
                }
            }
        });
    }

    private void openFilePicker(String[] acceptTypes, boolean isCaptureEnabled) {
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        
        if (acceptTypes != null && acceptTypes.length > 0 && !acceptTypes[0].isEmpty()) {
            intent.setType(acceptTypes[0]);
        } else {
            intent.setType("*/*");
        }
        
        // Add camera option if capture is enabled
        if (isCaptureEnabled) {
            Intent cameraIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
            Intent chooser = Intent.createChooser(intent, "Select File");
            chooser.putExtra(Intent.EXTRA_INITIAL_INTENTS, new Intent[] { cameraIntent });
            startActivityForResult(chooser, FILE_CHOOSER_REQUEST);
        } else {
            startActivityForResult(Intent.createChooser(intent, "Select File"), 
                FILE_CHOOSER_REQUEST);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        
        if (requestCode == FILE_CHOOSER_REQUEST) {
            if (fileUploadCallback == null) return;
            
            Uri[] results = null;
            
            if (resultCode == Activity.RESULT_OK && data != null) {
                String dataString = data.getDataString();
                if (dataString != null) {
                    results = new Uri[] { Uri.parse(dataString) };
                }
            }
            
            fileUploadCallback.onReceiveValue(results);
            fileUploadCallback = null;
        }
    }

    @Override
    public void onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack();
        } else {
            // Show interstitial ad on exit
            StartAppAd.onBackPressed(this);
            super.onBackPressed();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        webView.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        webView.onPause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        webView.destroy();
    }

    // JavaScript Interface for native features
    public class WebAppInterface {
        
        @JavascriptInterface
        public String getDeviceInfo() {
            return "{\"brand\":\"" + Build.BRAND + 
                   "\",\"model\":\"" + Build.MODEL + 
                   "\",\"version\":\"" + Build.VERSION.RELEASE + 
                   "\",\"sdk\":" + Build.VERSION.SDK_INT + "}";
        }
        
        @JavascriptInterface
        public String getBatteryInfo() {
            android.os.BatteryManager bm = 
                (android.os.BatteryManager) getSystemService(BATTERY_SERVICE);
            int level = bm.getIntProperty(android.os.BatteryManager.BATTERY_PROPERTY_CAPACITY);
            boolean charging = bm.isCharging();
            return "{\"level\":" + level + ",\"charging\":" + charging + "}";
        }
        
        @JavascriptInterface
        public void showToast(String message) {
            runOnUiThread(() -> Toast.makeText(MainActivity.this, message, 
                Toast.LENGTH_SHORT).show());
        }
        
        @JavascriptInterface
        public void vibrate(long milliseconds) {
            android.os.Vibrator vibrator = 
                (android.os.Vibrator) getSystemService(VIBRATOR_SERVICE);
            if (vibrator != null) {
                vibrator.vibrate(milliseconds);
            }
        }
    }
}
"@
Set-Content -Path "$output\app\src\main\java\$packagePath\MainActivity.java" -Value $mainActivity -Encoding UTF8

# Create gradle-wrapper.properties
$gradleWrapperProps = @"
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
"@
if (!(Test-Path "$output\gradle\wrapper")) {
    New-Item -ItemType Directory -Force -Path "$output\gradle\wrapper" | Out-Null
}
Set-Content -Path "$output\gradle\wrapper\gradle-wrapper.properties" -Value $gradleWrapperProps -Encoding UTF8

Write-Host "Project files generated successfully."
