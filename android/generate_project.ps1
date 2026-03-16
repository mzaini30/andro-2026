param(
    [string]$title,
    [string]$version,
    [string]$package,
    [string]$icon,
    [string]$web,
    [hashtable]$ads,
    [string]$output
)

# Extract ads values from hashtable
$ads_id = $ads.id
$ads_banner = $ads.banner
$ads_open = $ads.open
$ads_rewarded = $ads.rewarded

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
[System.IO.File]::WriteAllText("$output\settings.gradle", $settingsGradle, [System.Text.UTF8Encoding]::new($false))

# Create root build.gradle
$rootBuildGradle = @"
// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    
    repositories {
        google()
        jcenter()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:4.2.1'
        

        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }
}

allprojects {
    repositories {
        google()
        jcenter()
        mavenCentral()
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
"@
[System.IO.File]::WriteAllText("$output\build.gradle", $rootBuildGradle, [System.Text.UTF8Encoding]::new($false))

# Create gradle.properties
$gradleProperties = @"
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
android.suppressUnsupportedCompileSdk=34
"@
[System.IO.File]::WriteAllText("$output\gradle.properties", $gradleProperties, [System.Text.UTF8Encoding]::new($false))

# Create local.properties (dummy SDK path to bypass SDK check)
$localProperties = "sdk.dir=D:/Android/Sdk"
[System.IO.File]::WriteAllText("$output\local.properties", $localProperties, [System.Text.UTF8Encoding]::new($false))

# Create app/build.gradle
$appBuildGradle = @"
apply plugin: 'com.android.application'

android {
    compileSdkVersion 33
    defaultConfig {
        applicationId "$package"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode $version
        versionName "$version"
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }
    buildTypes {
        debug {
            minifyEnabled false
        }
    }
}

dependencies {
    implementation fileTree(dir: 'libs', include: ['*.jar'])
    implementation 'androidx.appcompat:appcompat:1.0.0-alpha1'
    implementation 'androidx.constraintlayout:constraintlayout:1.1.0'
    implementation 'androidx.webkit:webkit:1.2.0'
    implementation "androidx.annotation:annotation:1.3.0"
    testImplementation 'junit:junit:4.12'
    androidTestImplementation 'androidx.test:runner:1.1.0-alpha3'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.1.0-alpha3'
    implementation 'com.google.android.gms:play-services-ads:22.1.0'
    // implementation 'com.startapp:inapp-sdk:4.9.+'
    // def lifecycle_version = "2.0.0"
    implementation "androidx.lifecycle:lifecycle-extensions:2.0.0"
    implementation "androidx.lifecycle:lifecycle-runtime:2.0.0"
    annotationProcessor "androidx.lifecycle:lifecycle-compiler:2.0.0"
}
"@
[System.IO.File]::WriteAllText("$output\app\build.gradle", $appBuildGradle, [System.Text.UTF8Encoding]::new($false))

# Create proguard-rules.pro
$proguardRules = @"
# Google Mobile Ads SDK (AdMob)
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn android.webkit.JavascriptInterface
-dontwarn com.google.android.gms.**
-keepattributes Exceptions, InnerClasses, Signature, Deprecated, SourceFile, LineNumberTable, *Annotation*, EnclosingMethod
"@
[System.IO.File]::WriteAllText("$output\app\proguard-rules.pro", $proguardRules, [System.Text.UTF8Encoding]::new($false))

# Create AndroidManifest.xml
$androidManifest = @"
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.user.app">
    <uses-permission android:name="android.permission.SET_WALLPAPER" />
    <uses-permission android:name="com.google.android.gms.permission.AD_ID"/>
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/AppTheme">
        <activity android:name=".MainActivity" android:exported="true" android:configChanges="orientation|screenSize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />

                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="$ads_id" />
    </application>

</manifest>
"@
[System.IO.File]::WriteAllText("$output\app\src\main\AndroidManifest.xml", $androidManifest, [System.Text.UTF8Encoding]::new($false))

# Create strings.xml
$stringsXml = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">$title</string>
</resources>
"@
[System.IO.File]::WriteAllText("$output\app\src\main\res\values\strings.xml", $stringsXml, [System.Text.UTF8Encoding]::new($false))

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
[System.IO.File]::WriteAllText("$output\app\src\main\res\values\colors.xml", $colorsXml, [System.Text.UTF8Encoding]::new($false))

# Create themes.xml
$themesXml = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.Andro" parent="Theme.MaterialComponents.DayNight.NoActionBar">
        <item name="android:statusBarColor">@color/purple_700</item>
        <item name="android:windowFullscreen">false</item>
    </style>
</resources>
"@
[System.IO.File]::WriteAllText("$output\app\src\main\res\values\themes.xml", $themesXml, [System.Text.UTF8Encoding]::new($false))

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
[System.IO.File]::WriteAllText("$output\app\src\main\res\xml\file_paths.xml", $filePathsXml, [System.Text.UTF8Encoding]::new($false))

# Create activity_main.xml
$activityMainXml = @"
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/content_layout"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical" >

    <com.google.android.gms.ads.AdView
        xmlns:ads="http://schemas.android.com/apk/res-auto"
        android:id="@+id/adView"
        android:layout_width="match_parent"
        android:layout_height="50dp"
        android:layout_alignParentTop="true"
        android:layout_alignParentLeft="true"
        android:layout_centerHorizontal="true"
        android:layout_alignParentStart="true" ads:adSize="BANNER"
        ads:adUnitId="$ads_banner">
    </com.google.android.gms.ads.AdView>

    <WebView  xmlns:android="http://schemas.android.com/apk/res/android"
        android:id="@+id/webview"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:layout_below="@+id/adView" />

</RelativeLayout>
"@

# Create layout directory if not exists
if (!(Test-Path "$output\app\src\main\res\layout")) {
    New-Item -ItemType Directory -Force -Path "$output\app\src\main\res\layout" | Out-Null
}
[System.IO.File]::WriteAllText("$output\app\src\main\res\layout\activity_main.xml", $activityMainXml, [System.Text.UTF8Encoding]::new($false))

# Create AppOpenManager.java
$appOpenManager = @"
package $package;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.os.Bundle;
import android.util.Log;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.appopen.AppOpenAd;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleObserver;
import androidx.lifecycle.OnLifecycleEvent;
import androidx.lifecycle.ProcessLifecycleOwner;

public class AppOpenManager  implements LifecycleObserver, Application.ActivityLifecycleCallbacks {

    private static final String LOG_TAG = "AppOpenManager";
    private static String AD_UNIT_ID;
    private static String ORIENTASI;
    private AppOpenAd appOpenAd = null;
    private static boolean isShowingAds = false;

    private AppOpenAd.AppOpenAdLoadCallback loadCallback;

    private Application myApplication;

    private Activity currentActivity;

    public AppOpenManager(Application myApplication, String adId, String orientasi) {
        AD_UNIT_ID = adId;
        ORIENTASI = orientasi;
        this.myApplication = myApplication;
        this.myApplication.registerActivityLifecycleCallbacks(this);
        ProcessLifecycleOwner.get().getLifecycle().addObserver(this);
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_START)
    public void onStart() {
        showAdIfAvailable();
    }

    /**
     * Request an ad
     */
    public void fetchAd() {

        if (isAdAvailable()) {
            return;
        }
        loadCallback = new AppOpenAd.AppOpenAdLoadCallback() {
            @Override
            public void onAdLoaded(@NonNull AppOpenAd appOpenAd) {
                super.onAdLoaded(appOpenAd);
                AppOpenManager.this.appOpenAd = appOpenAd;
            }

            @Override
            public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
                super.onAdFailedToLoad(loadAdError);
                Log.d("POENAD", "onAdFailedToLoad: " + loadAdError.getMessage());
            }
        };
        AdRequest adRequest = getAdRequest();

        if (ORIENTASI == "portrait"){
            AppOpenAd.load(myApplication,
                AD_UNIT_ID, adRequest,
                AppOpenAd.APP_OPEN_AD_ORIENTATION_PORTRAIT, loadCallback);
        } else {
            AppOpenAd.load(myApplication,
                AD_UNIT_ID, adRequest,
                AppOpenAd.APP_OPEN_AD_ORIENTATION_LANDSCAPE, loadCallback);
        }


    }

    public void showAdIfAvailable() {
        if (!isShowingAds && isAdAvailable()) {
            FullScreenContentCallback fullScreenContentCallback =
                    new FullScreenContentCallback() {
                        @Override
                        public void onAdFailedToShowFullScreenContent(@NonNull AdError adError) {
                            super.onAdFailedToShowFullScreenContent(adError);
                        }

                        @Override
                        public void onAdShowedFullScreenContent() {
                            super.onAdShowedFullScreenContent();
                            isShowingAds = true;
                        }

                        @Override
                        public void onAdDismissedFullScreenContent() {
                            super.onAdDismissedFullScreenContent();
                            AppOpenManager.this.appOpenAd = null;
                            isShowingAds = false;
                            fetchAd();
                        }

                        @Override
                        public void onAdImpression() {
                            super.onAdImpression();
                        }
                    };

            appOpenAd.setFullScreenContentCallback(fullScreenContentCallback);
            appOpenAd.show(currentActivity);
        }
        else
            fetchAd();
    }

    /**
     * Creates and returns ad request.
     */
    private AdRequest getAdRequest() {
        return new AdRequest.Builder().build();
    }

    /**
     * Utility method that checks if ad exists and can be shown.
     */
    public boolean isAdAvailable() {
        return appOpenAd != null;
    }

    @Override
    public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {

    }

    @Override
    public void onActivityStarted(@NonNull Activity activity) {
        currentActivity = activity;
    }

    @Override
    public void onActivityResumed(@NonNull Activity activity) {
        currentActivity = activity;

    }

    @Override
    public void onActivityPaused(@NonNull Activity activity) {

    }

    @Override
    public void onActivityStopped(@NonNull Activity activity) {

    }

    @Override
    public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {

    }

    @Override
    public void onActivityDestroyed(@NonNull Activity activity) {
        currentActivity = null;

    }
}
"@
[System.IO.File]::WriteAllText("$output\app\src\main\java\$packagePath\AppOpenManager.java", $appOpenManager, [System.Text.UTF8Encoding]::new($false))

# Create JavaScriptInterface.java
$javaScriptInterface = @"
package $package;

import android.app.Activity;
import android.app.WallpaperManager;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;
import android.webkit.JavascriptInterface;
import android.widget.Toast;

import androidx.annotation.NonNull;

import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.OnUserEarnedRewardListener;
import com.google.android.gms.ads.RequestConfiguration;
import com.google.android.gms.ads.rewarded.RewardItem;
import com.google.android.gms.ads.rewarded.RewardedAd;
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback;

public class JavaScriptInterface {
    private final Context context;
    private RewardedAd rewardedAd;
    // private RewardedAd rewardAd;
    private boolean isAdReady = false;
    private final String TAG = "MainActivity";
    private Activity activity;

    public void setRewardedAd(RewardedAd ad) {
        rewardedAd = ad;
        isAdReady = true;
    }

    public boolean isAdReady() {
        return isAdReady;
    }

    public JavaScriptInterface(Context context) {
        this.context = context;
        if (context instanceof Activity) {
            this.activity = (Activity) context;
        }
    }

    @JavascriptInterface
    public void set_wallpaper(String imageUrl) {
        // Di sini Anda bisa mengatur gambar wallpaper sebagai latar belakang
        // menggunakan WallpaperManager atau cara lain yang sesuai.
        try {
            WallpaperManager wallpaperManager = WallpaperManager.getInstance(context);
            InputStream inputStream = context.getAssets().open(imageUrl); // Baca gambar dari assets
            Bitmap bitmap = BitmapFactory.decodeStream(inputStream);
            wallpaperManager.setBitmap(bitmap);
            Toast.makeText(context, "Wallpaper successfully set.", Toast.LENGTH_SHORT).show();
        } catch (IOException e) {
            e.printStackTrace();
            Toast.makeText(context, "Failed to set wallpaper.", Toast.LENGTH_SHORT).show();
        }
    }

    @JavascriptInterface
    public void reward(){
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                // Code untuk menampilkan Rewarded Ads di sini
                // rewarded ads
                 AdRequest adRequest = new AdRequest.Builder().build();
                 RewardedAd.load(context, "$ads_rewarded",
                     adRequest, new RewardedAdLoadCallback() {
                         @Override
                         public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
                             // Handle the error.
                             Log.d(TAG, loadAdError.toString());
                             // Toast.makeText(context, loadAdError.toString(), Toast.LENGTH_SHORT).show();
                             rewardedAd = null;
                         }

                         @Override
                         public void onAdLoaded(@NonNull RewardedAd ad) {
                             rewardedAd = ad;
                             Log.d(TAG, "Ad was loaded.");
                             // Toast.makeText(context, "Ad was loaded.", Toast.LENGTH_SHORT).show();
                         }
                     }
                 );

                //   menjalankan ads reward
                if (isAdReady) {
                    rewardedAd.show(activity, new OnUserEarnedRewardListener() {
                        @Override
                        public void onUserEarnedReward(@NonNull RewardItem rewardItem) {
                            // Handle the reward.
                            Log.d(TAG, "The user earned the reward.");
                            // Toast.makeText(context, "The user earned the reward.", Toast.LENGTH_SHORT).show();
                            int rewardAmount = rewardItem.getAmount();
                            String rewardType = rewardItem.getType();
                        }
                    });
                } else {
                    Log.d(TAG, "The rewarded ad wasn't ready yet.");
                    // Toast.makeText(context, "The rewarded ad wasn't ready yet.", Toast.LENGTH_SHORT).show();
                }
            }
        });
       
        

        
    }
}
"@
[System.IO.File]::WriteAllText("$output\app\src\main\java\$packagePath\JavaScriptInterface.java", $javaScriptInterface, [System.Text.UTF8Encoding]::new($false))

# Create MainActivity.java
$mainActivity = @"
package $package;

import android.app.Activity;
import android.content.Intent;

import android.content.res.Configuration;
import android.net.Uri;
import android.os.Bundle;
import android.content.Context;
import android.util.Log;
import android.view.KeyEvent;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebChromeClient;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import android.webkit.ValueCallback;

import androidx.webkit.WebViewAssetLoader;
import androidx.webkit.WebViewAssetLoader.AssetsPathHandler;

import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.MobileAds;

import android.widget.RelativeLayout;
import android.view.View;
import android.widget.Toast;

import com.google.android.gms.ads.OnUserEarnedRewardListener;
import com.google.android.gms.ads.initialization.InitializationStatus;
import com.google.android.gms.ads.initialization.OnInitializationCompleteListener;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.rewarded.RewardItem;
import com.google.android.gms.ads.rewarded.RewardedAd;
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback;

public class MainActivity extends AppCompatActivity {
    // variables para manejar la subida de archivos
    private final static int FILECHOOSER_RESULTCODE = 1;
    private ValueCallback<Uri[]> mUploadMessage;
    private RewardedAd rewardedAd;
    private final String TAG = "MainActivity";
    private AdView mAdView;
    private Context context;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        MobileAds.initialize(this, new OnInitializationCompleteListener() {
            @Override
            public void onInitializationComplete(InitializationStatus initializationStatus) {
            }
        });
        int currentOrientation = getResources().getConfiguration().orientation;
        if (currentOrientation == Configuration.ORIENTATION_PORTRAIT) {
            new AppOpenManager(this.getApplication(), "$ads_open", "portrait");
        } else  {
            new AppOpenManager(this.getApplication(), "$ads_open", "landscape");
        }
        mAdView = findViewById(R.id.adView);
        AdRequest adRequest = new AdRequest.Builder().build();
        mAdView.loadAd(adRequest);

        

        
        mAdView.setAdListener(new AdListener() {
            @Override
            public void onAdLoaded() {
                // Code to be executed when an ad finishes loading.
            }

            @Override
            public void onAdFailedToLoad(LoadAdError adError) {
                // Code to be executed when an ad request fails.
                mAdView.setVisibility(View.GONE);
            }

            @Override
            public void onAdOpened() {
                // Code to be executed when an ad opens an overlay that
                // covers the screen.
            }

            @Override
            public void onAdClicked() {
                // Code to be executed when the user clicks on an ad.
            }

            @Override
            public void onAdClosed() {
                // Code to be executed when the user is about to return
                // to the app after tapping on an ad.
            }
        });

        final WebViewAssetLoader assetLoader = new WebViewAssetLoader.Builder()
            // .setDomain("api.example.com")
            .addPathHandler("/assets/", new AssetsPathHandler(this))
            .build();

        WebView webview = (WebView) findViewById(R.id.webview);

        webview.setWebViewClient(new WebViewClient() {

            @Override
            public WebResourceResponse shouldInterceptRequest(WebView view,  WebResourceRequest request) {
                return assetLoader.shouldInterceptRequest(request.getUrl());
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                if (
                    url.contains("http://") 
                    || url.contains("https://")
                    && !url.contains("https://appassets.androidplatform.net")
                ){
                    Intent i = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
                    startActivity(i);
                    return true;
                } else {
                    return false;
                }

            }
          
        });

        // establecemos el cliente chrome para seleccionar archivos
        webview.setWebChromeClient(new MyWebChromeClient());

        // Setelah iklan berhasil dimuat
        JavaScriptInterface jsInterface = new JavaScriptInterface(this);

       RewardedAd.load(this, "$ads_rewarded",
       new AdRequest.Builder().build(), new RewardedAdLoadCallback() {
           @Override
           public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
               // Handle the error.
               Log.d(TAG, loadAdError.toString());
               rewardedAd = null;
               jsInterface.setRewardedAd(rewardedAd);
           }

           @Override
           public void onAdLoaded(@NonNull RewardedAd ad) {
               rewardedAd = ad;
               jsInterface.setRewardedAd(rewardedAd);
               Log.d(TAG, "Ad was loaded.");
           }
       });

        webview.addJavascriptInterface(jsInterface, "Andro");

        WebSettings webSettings = webview.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDatabaseEnabled(true);
        String databasePath = this.getApplicationContext().getDir("database", Context.MODE_PRIVATE).getPath();
        webSettings.setDatabasePath(databasePath);
        webSettings.setDomStorageEnabled(true);


        if (savedInstanceState == null) {
            webview.loadUrl("https://appassets.androidplatform.net/assets/index.html");
        }

    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent intent) {

        // manejo de seleccion de archivo
        if (requestCode == FILECHOOSER_RESULTCODE) {

            if (null == mUploadMessage || intent == null || resultCode != RESULT_OK) {
                return;
            }

            Uri[] result = null;
            String dataString = intent.getDataString();

            if (dataString != null) {
                result = new Uri[]{ Uri.parse(dataString) };
            }

            mUploadMessage.onReceiveValue(result);
            mUploadMessage = null;
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        WebView webview = (WebView) findViewById(R.id.webview);

        if (event.getAction() == KeyEvent.ACTION_DOWN) {
            switch (keyCode) {
                case KeyEvent.KEYCODE_BACK:
                    if (webview.canGoBack()) {
                        webview.goBack();
                    } else {
                        finish();
                    }
                    return true;
            }

        }
        return super.onKeyDown(keyCode, event);
    }

    @Override
    protected void onSaveInstanceState(Bundle outState )
    {
        WebView webview = (WebView) findViewById(R.id.webview);

        super.onSaveInstanceState(outState);
        webview.saveState(outState);
    }

    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState)
    {
        WebView webview = (WebView) findViewById(R.id.webview);

        super.onRestoreInstanceState(savedInstanceState);
        webview.restoreState(savedInstanceState);
    }

    /**
     * Clase para configurar el chrome client para que nos permita seleccionar archivos
     */
    private class MyWebChromeClient extends WebChromeClient {

        // maneja la accion de seleccionar archivos
        @Override
        public boolean onShowFileChooser(WebView webView, ValueCallback<Uri[]> filePathCallback, FileChooserParams fileChooserParams) {

            // asegurar que no existan callbacks
            if (mUploadMessage != null) {
                mUploadMessage.onReceiveValue(null);
            }

            mUploadMessage = filePathCallback;

            Intent i = new Intent(Intent.ACTION_GET_CONTENT);
            i.addCategory(Intent.CATEGORY_OPENABLE);
            i.setType("*/*"); // set MIME type to filter

            MainActivity.this.startActivityForResult(Intent.createChooser(i, "File Chooser"), MainActivity.FILECHOOSER_RESULTCODE );

            return true;
        }
    }


}
"@
 

[System.IO.File]::WriteAllText("$output\app\src\main\java\$packagePath\MainActivity.java", $mainActivity, [System.Text.UTF8Encoding]::new($false))

# Create gradle-wrapper.properties
$gradleWrapperProps = @"
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.4-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
"@
if (!(Test-Path "$output\gradle\wrapper")) {
    New-Item -ItemType Directory -Force -Path "$output\gradle\wrapper" | Out-Null
}
[System.IO.File]::WriteAllText("$output\gradle\wrapper\gradle-wrapper.properties", $gradleWrapperProps, [System.Text.UTF8Encoding]::new($false))

Write-Host "Project files generated successfully."
