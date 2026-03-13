param(
    [string]$title,
    [string]$androidDir
)

# Sanitize title - remove invalid filename characters
$safeTitle = $title -replace '[<>:"/\\|?*]', ''

$debugApk = "$androidDir\app\build\outputs\apk\debug\app-debug.apk"
$releaseApk = "$androidDir\app\build\outputs\apk\release\app-release.apk"
$releaseUnsignedApk = "$androidDir\app\build\outputs\apk\release\app-release-unsigned.apk"
$releaseAab = "$androidDir\app\build\outputs\bundle\release\app-release.aab"

if (Test-Path $debugApk) {
    $destPath = Join-Path (Split-Path $debugApk) "$safeTitle.apk"
    Copy-Item $debugApk -Destination $destPath -Force
    Write-Host "   APK [Debug]:  $destPath"
}

if (Test-Path $releaseApk) {
    $destPath = Join-Path (Split-Path $releaseApk) "$safeTitle.apk"
    Copy-Item $releaseApk -Destination $destPath -Force
    Write-Host "   APK [Release]: $destPath"
} elseif (Test-Path $releaseUnsignedApk) {
    $destPath = Join-Path (Split-Path $releaseUnsignedApk) "$safeTitle.apk"
    Copy-Item $releaseUnsignedApk -Destination $destPath -Force
    Write-Host "   APK [Release]: $destPath"
}

if (Test-Path $releaseAab) {
    $destPath = Join-Path (Split-Path $releaseAab) "$safeTitle.aab"
    Copy-Item $releaseAab -Destination $destPath -Force
    Write-Host "   AAB [Release]: $destPath"
}
