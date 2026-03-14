package com.example.helloworld;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.provider.Settings;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.GeolocationPermissions;
import android.webkit.JavascriptInterface;
import android.webkit.PermissionRequest;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.ProcessLifecycleOwner;
import androidx.webkit.WebViewAssetLoader;
import androidx.webkit.WebViewAssetLoader.AssetsPathHandler;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.appopen.AppOpenAd;
import com.google.android.gms.ads.appopen.AppOpenAd.AppOpenAdLoadCallback;

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

    // AdMob variables
    private AdView adView;
    private AppOpenAd appOpenAd = null;
    private AppOpenAdManager appOpenAdManager;
    private boolean isShowingAd = false;
    private static final String TAG = "MainActivity";

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

        // Initialize Google Mobile Ads SDK
        MobileAds.initialize(this, initializationStatus -> {
            Log.d(TAG, "Mobile Ads SDK initialized");
        });

        // Initialize App Open Ad Manager
        appOpenAdManager = new AppOpenAdManager();

        // Request permissions
        requestPermissions();

        // Create Layout
        RelativeLayout layout = new RelativeLayout(this);
        layout.setLayoutParams(new RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT));

        // Create WebView
        webView = new WebView(this);
        RelativeLayout.LayoutParams webViewParams = new RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT);

        // Create AdMob Banner
        if (!"ca-app-pub-2408628281705149/3796086104".isEmpty()) {
            FrameLayout adContainerView = new FrameLayout(this);
            adContainerView.setId(View.generateViewId());
            RelativeLayout.LayoutParams bannerParams = new RelativeLayout.LayoutParams(
                    RelativeLayout.LayoutParams.WRAP_CONTENT,
                    RelativeLayout.LayoutParams.WRAP_CONTENT);
            bannerParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
            bannerParams.addRule(RelativeLayout.CENTER_HORIZONTAL);

            // Align WebView above Banner
            webViewParams.addRule(RelativeLayout.ABOVE, adContainerView.getId());

            // Create AdView
            adView = new AdView(this);
            adView.setAdUnitId("ca-app-pub-2408628281705149/3796086104");
            adView.setAdSize(AdSize.getLargeAnchoredAdaptiveBannerAdSize(this, AdSize.FULL_WIDTH));

            adContainerView.addView(adView);
            layout.addView(adContainerView, bannerParams);

            // Load banner ad
            loadBannerAd();
        }

        layout.addView(webView, webViewParams);
        setContentView(layout);

        // Configure WebView
        configureWebView();

        // Load the main page
        webView.loadUrl("https://appassets.androidplatform.net/assets/index.html");

        // Register lifecycle observer for App Open ads
        ProcessLifecycleOwner.get().getLifecycle().addObserver(new DefaultLifecycleObserver() {
            @Override
            public void onStart(@NonNull LifecycleOwner owner) {
                // Show app open ad when app comes to foreground
                if (!"ca-app-pub-2408628281705149/3832944231".isEmpty()) {
                    appOpenAdManager.showAdIfAvailable(MainActivity.this);
                }
            }
        });
    }

    private void loadBannerAd() {
        if (adView != null) {
            AdRequest adRequest = new AdRequest.Builder().build();
            adView.loadAd(adRequest);
            adView.setAdListener(new AdListener() {
                @Override
                public void onAdLoaded() {
                    Log.d(TAG, "Banner ad loaded");
                }

                @Override
                public void onAdFailedToLoad(@NonNull LoadAdError adError) {
                    Log.d(TAG, "Banner ad failed to load: " + adError.getMessage());
                    adView = null;
                }

                @Override
                public void onAdClicked() {
                    Log.d(TAG, "Banner ad clicked");
                }

                @Override
                public void onAdImpression() {
                    Log.d(TAG, "Banner ad impression");
                }
            });
        }
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
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
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

        final WebViewAssetLoader assetLoader = new WebViewAssetLoader.Builder()
            .addPathHandler("/assets/", new AssetsPathHandler(this))
            .build();

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

        // Modern web support
        webSettings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);

        // Hardware acceleration
        webView.setLayerType(View.LAYER_TYPE_HARDWARE, null);

        // JavaScript Interface for native features
        webView.addJavascriptInterface(new WebAppInterface(), "Android");

        // WebViewClient for handling page navigation
        webView.setWebViewClient(new WebViewClient() {
            @Override
            public WebResourceResponse shouldInterceptRequest(WebView view, WebResourceRequest request) {
                return assetLoader.shouldInterceptRequest(request.getUrl());
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                if (url.startsWith("https://appassets.androidplatform.net")) {
                    return false;
                }

                if (url.startsWith("http://") || url.startsWith("https://")) {
                    try {
                        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
                        startActivity(intent);
                    } catch (Exception e) {
                        // URL scheme not supported
                    }
                    return true;
                }
                return false;
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
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
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
            super.onBackPressed();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        webView.onResume();
        if (adView != null) {
            adView.resume();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        webView.onPause();
        if (adView != null) {
            adView.pause();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        webView.destroy();
        if (adView != null) {
            adView.destroy();
            adView = null;
        }
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

    // App Open Ad Manager class
    private class AppOpenAdManager {
        private static final String LOG_TAG = "AppOpenAdManager";
        private long loadTime = 0;

        public AppOpenAdManager() {}

        public void loadAd() {
            if (isLoadingAd || isAdAvailable()) {
                return;
            }

            isLoadingAd = true;
            AppOpenAd.load(
                MainActivity.this,
                "ca-app-pub-2408628281705149/3832944231",
                new AdRequest.Builder().build(),
                new AppOpenAdLoadCallback() {
                    @Override
                    public void onAdLoaded(@NonNull AppOpenAd ad) {
                        Log.d(LOG_TAG, "App open ad loaded.");
                        appOpenAd = ad;
                        isLoadingAd = false;
                        loadTime = (new Date()).getTime();
                    }

                    @Override
                    public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
                        Log.d(LOG_TAG, "App open ad failed to load with error: " + loadAdError.getMessage());
                        isLoadingAd = false;
                    }
                });
        }

        public void showAdIfAvailable(@NonNull Activity activity) {
            if (isShowingAd) {
                Log.d(TAG, "The app open ad is already showing.");
                return;
            }

            if (!isAdAvailable()) {
                Log.d(TAG, "The app open ad is not ready yet.");
                loadAd();
                return;
            }

            isShowingAd = true;
            appOpenAd.show(activity);
            appOpenAd.setFullScreenContentCallback(new FullScreenContentCallback() {
                @Override
                public void onAdDismissedFullScreenContent() {
                    Log.d(TAG, "Ad dismissed fullscreen content.");
                    appOpenAd = null;
                    isShowingAd = false;
                    loadAd();
                }

                @Override
                public void onAdFailedToShowFullScreenContent(@NonNull AdError adError) {
                    Log.d(TAG, "Ad failed to show: " + adError.getMessage());
                    appOpenAd = null;
                    isShowingAd = false;
                    loadAd();
                }

                @Override
                public void onAdShowedFullScreenContent() {
                    Log.d(TAG, "Ad showed fullscreen content.");
                }
            });
        }

        private boolean isAdAvailable() {
            return appOpenAd != null && wasLoadTimeLessThanNHoursAgo(4);
        }

        private boolean wasLoadTimeLessThanNHoursAgo(long numHours) {
            long dateDifference = (new Date()).getTime() - loadTime;
            long numMilliSecondsPerHour = 3600000;
            return (dateDifference < (numMilliSecondsPerHour * numHours));
        }
    }
}