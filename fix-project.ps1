# Andro Fix Script for D:\Aplikasi-Android\learning-kana
# Run this from PowerShell to fix the build issue

$targetProject = "D:\Aplikasi-Android\learning-kana"
$sourceDir = "D:\Andro\android"

Write-Host "============================================"
Write-Host "  Andro Fix Script"
Write-Host "============================================"
Write-Host ""
Write-Host "Target project: $targetProject"
Write-Host ""

# Check if target exists
if (!(Test-Path $targetProject)) {
    Write-Error "Target project directory not found: $targetProject"
    exit 1
}

$targetAndroidDir = Join-Path $targetProject "android"

if (!(Test-Path $targetAndroidDir)) {
    Write-Error "android folder not found in target project!"
    exit 1
}

# Copy updated files
Write-Host "Copying updated scripts..."
Write-Host ""

Copy-Item -Path (Join-Path $sourceDir "create_dirs.ps1") -Destination (Join-Path $targetAndroidDir "create_dirs.ps1") -Force
Write-Host "  Updated: android\create_dirs.ps1"

Copy-Item -Path (Join-Path $sourceDir "copy_assets.ps1") -Destination (Join-Path $targetAndroidDir "copy_assets.ps1") -Force
Write-Host "  Updated: android\copy_assets.ps1"

Copy-Item -Path (Join-Path $sourceDir "..\andro.bat") -Destination $targetProject -Force
Write-Host "  Updated: andro.bat"

Write-Host ""
Write-Host "============================================"
Write-Host "  Fix Complete!"
Write-Host "============================================"
Write-Host ""
Write-Host "Updated files:"
Write-Host "  - andro.bat (in project root)"
Write-Host "  - android\create_dirs.ps1"
Write-Host "  - android\copy_assets.ps1"
Write-Host ""
Write-Host "Now try running: andro build"
Write-Host ""
