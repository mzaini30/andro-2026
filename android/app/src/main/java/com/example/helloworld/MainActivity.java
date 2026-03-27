package com.example.helloworld;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.view.View;
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
import android.widget.RelativeLayout;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;
import androidx.webkit.WebViewAssetLoader;
import androidx.webkit.WebViewAssetLoader.AssetsPathHandler;

import java.util.ArrayList;
import java.util.List;
import com.startapp.sdk.adsbase.StartAppSDK;
import com.startapp.sdk.adsbase.StartAppAd;
import com.startapp.sdk.ads.banner.Banner;

public class MainActivity extends AppCompatActivity {

    private WebView webView;
    private ValueCallback<Uri[]> fileUploadCallback;
    private static final int FILE_CHOOSER_REQUEST = 1;
    private static final int PERMISSION_REQUEST_CODE = 100;

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
        if (!"202843390".isEmpty()) {
            StartAppSDK.init(this, "202843390", true);
        }

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

        // Create Banner
        Banner startAppBanner = new Banner(this);
        startAppBanner.setId(View.generateViewId());
        RelativeLayout.LayoutParams bannerParams = new RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.WRAP_CONTENT,
                RelativeLayout.LayoutParams.WRAP_CONTENT);
        bannerParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        bannerParams.addRule(RelativeLayout.CENTER_HORIZONTAL);

        // Align WebView above Banner
        webViewParams.addRule(RelativeLayout.ABOVE, startAppBanner.getId());

        // Add views to layout
        layout.addView(startAppBanner, bannerParams);
        layout.addView(webView, webViewParams);
        setContentView(layout);

        // Configure WebView
        configureWebView();

        // Load the main page
        webView.loadUrl("https://appassets.androidplatform.net/assets/index.html");
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
                /* Toast.makeText(this, "Some permissions were denied. Some features may not work.",
                    Toast.LENGTH_LONG).show(); */
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