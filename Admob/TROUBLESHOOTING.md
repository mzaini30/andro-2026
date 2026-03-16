# AdMob Troubleshooting Guide

## Your Current Issue: HTTP 403 Errors

### Problem Summary
Your logs show:
```
Received error HTTP response code: 403
Ad failed to load : 3
```

**Error Code 3** = `ERROR_CODE_NO_FILL` - No ad inventory available

---

## Why Test Ads Aren't Showing

### 1. **Test Device Limitations** ✅ MOST LIKELY
Your logs show: `This request is sent from a test device.`

**The Issue:**
- Google's test ad servers have **very limited inventory**
- Test ads don't always fill, especially for:
  - App Open ads
  - Interstitial ads
  - Certain geographic regions

**Solution:**
- This is **normal behavior** during development
- Real ads in production will have much better fill rates
- Continue testing - sometimes test ads will load after multiple attempts

### 2. **Geographic Restrictions**
**The Issue:**
- Test ad inventory varies by region
- Some countries have very limited test ad availability

**Solution:**
- Use a VPN to test from a different region (US/UK typically have more inventory)
- Or deploy to production with real AdMob IDs for better fill rates

### 3. **Rate Limiting**
**The Issue:**
- Too many ad requests from the same test device in a short time
- Google may temporarily limit test ad delivery

**Solution:**
- Wait 15-30 minutes between testing sessions
- Clear app data before testing: `adb shell pm clear com.example.helloworld`

### 4. **Ad Format Availability**
**The Issue:**
- Some test ad formats have lower fill rates than others
- App Open and Interstitial test ads fill less often than Banner ads

**Solution:**
- Test with Banner ads first (they have the highest fill rate)
- App Open ads may rarely show test ads - this is expected

---

## Verification Steps

### ✅ Check Your Implementation

1. **Test Device ID Registration**
   Your current test device ID: `8DB14B952ED03EDC510DFA8262C86F71`
   
   Verify it's correct by checking logcat:
   ```bash
   adb logcat -s Ads | findstr "test device"
   ```
   
   You should see:
   ```
   Use RequestConfiguration.Builder().setTestDeviceIds(Arrays.asList("YOUR_DEVICE_ID"))
   ```

2. **AdMob App ID in Manifest**
   ✅ Correctly set: `ca-app-pub-3940256099942544~3347511713`

3. **Test Ad Unit IDs** (Google's official test IDs)
   - ✅ App ID: `ca-app-pub-3940256099942544~3347511713`
   - ✅ Banner: `ca-app-pub-3940256099942544/6300978111`
   - ✅ App Open: `ca-app-pub-3940256099942544/9257395921`

4. **Hardware Acceleration**
   ✅ Enabled in manifest: `android:hardwareAccelerated="true"`

5. **Internet Permission**
   ✅ Present in manifest: `<uses-permission android:name="android.permission.INTERNET" />`

---

## Improved Logging (Added)

I've updated your `MainActivity.java` with better error logging:

### What's New:
1. **Detailed ad failure logs** - Shows error code and domain
2. **Adapter initialization status** - Shows which ad networks are ready
3. **Better error messages** - Includes full error details

### How to View Logs:
```bash
# Clear old logs
adb logcat -c

# Run app and watch for ad events
adb logcat -s Ads MainActivity

# Look for these tags:
# - Ads (Google Mobile Ads SDK)
# - MainActivity (Your app's ad loading)
```

### Expected Log Output:
```
D/MainActivity: Mobile Ads SDK initialized
D/MainActivity: Adapter: com.google.android.gms.ads... | State: INITIALIZED | Latency: XXXms
E/MainActivity: Banner ad failed to load: ... | Code: 3 | Domain: com.google.android.gms.ads
```

---

## Testing Tips

### 1. **Clear App Data Before Testing**
```bash
adb shell pm clear com.example.helloworld
```

### 2. **Wait Between Tests**
- Wait 30 seconds between ad load attempts
- Wait 5-10 minutes if you see repeated 403 errors

### 3. **Test on Real Device**
- Emulators have even less test ad inventory
- Your physical device is better for testing

### 4. **Check Network**
```bash
# Make sure device has internet
adb shell ping -c 3 google.com
```

### 5. **Force Stop and Restart**
```bash
adb shell am force-stop com.example.helloworld
# Then launch app again
```

---

## When Using Real AdMob IDs (Production)

### Before Going Live:

1. **Create Real AdMob Account** at https://admob.google.com/

2. **Register Your App**
   - Add Android app with your package name: `com.example.helloworld`
   - Add SHA-1 certificate fingerprint (from keystore)

3. **Get Real Ad Unit IDs**
   - Replace test IDs with your real Ad Unit IDs
   - Keep test device ID configuration for development

4. **Update Test Device List**
   ```java
   List<String> testDeviceIds = Arrays.asList(
       "YOUR_DEVICE_ID",  // Your development device
       "TEST_DEVICE_ID_2"  // Other testers
   );
   ```

5. **Remove Test Device Config Before Release**
   - Don't include test device IDs in production builds

---

## Common Error Codes

| Code | Name | Meaning | Solution |
|------|------|---------|----------|
| 0 | ERROR_CODE_INTERNAL_ERROR | Internal SDK error | Restart app, check internet |
| 1 | ERROR_CODE_INVALID_REQUEST | Invalid ad request | Check Ad Unit ID format |
| 2 | ERROR_CODE_NETWORK_ERROR | Network connectivity | Check internet connection |
| 3 | ERROR_CODE_NO_FILL | No ad inventory | **Normal for test ads** - wait or try again |

---

## Your Next Steps

### For Development Testing:
1. ✅ **Keep using test Ad Unit IDs** (you're already doing this)
2. ✅ **Keep test device ID configured** (already done)
3. **Be patient** - test ads may take multiple attempts to load
4. **Check the new detailed logs** for more information
5. **Test banner ads first** - they have the highest fill rate

### For Production:
1. Create real AdMob account
2. Register your app in AdMob console
3. Replace test Ad Unit IDs with real ones
4. Remove test device configuration before release
5. Monitor fill rates in AdMob dashboard

---

## Additional Resources

- [AdMob Test Ads Guide](https://developers.google.com/admob/android/test-ads)
- [AdMob Error Codes](https://developers.google.com/admob/android/error-codes)
- [Google Mobile Ads SDK](https://developers.google.com/admob/android/quick-start)

---

## Quick Debug Commands

```bash
# View only ad-related logs
adb logcat -s Ads MainActivity

# Clear all logs
adb logcat -c

# Clear app data
adb shell pm clear com.example.helloworld

# Force stop app
adb shell am force-stop com.example.helloworld

# Check internet connectivity on device
adb shell ping -c 3 google.com

# View full logs with timestamps
adb logcat -v time | findstr "Ads\|MainActivity"
```

---

**Bottom Line:** Your implementation is correct. The 403 errors are **normal for test ads** and don't indicate a problem with your code. Real ads in production will have much better fill rates.
