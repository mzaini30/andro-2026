param(
    [string]$sourcePath,
    [string]$destPath
)

# Validate source path
if (!(Test-Path $sourcePath)) {
    Write-Error "Source path does not exist: $sourcePath"
    exit 1
}

# Ensure destination exists
if (!(Test-Path $destPath)) {
    New-Item -ItemType Directory -Force -Path $destPath -ErrorAction Stop | Out-Null
}

# Get absolute paths
$sourcePath = (Resolve-Path $sourcePath).Path.TrimEnd('\', '/')
$destPath = (Resolve-Path $destPath).Path

# Copy all files and folders recursively
$copyCount = 0
Get-ChildItem $sourcePath -Recurse -File | ForEach-Object {
    $relativePath = $_.FullName.Substring($sourcePath.Length)
    $destFile = $destPath + $relativePath
    
    # Ensure destination directory exists
    $destDir = Split-Path $destFile -Parent
    if (!(Test-Path $destDir)) {
        New-Item -ItemType Directory -Force -Path $destDir -ErrorAction Stop | Out-Null
    }
    
    Copy-Item $_.FullName $destFile -Force -ErrorAction Stop
    $copyCount++
}

Write-Host "Assets copied successfully: $copyCount files from $sourcePath to $destPath"
