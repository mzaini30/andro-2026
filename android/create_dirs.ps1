param(
    [string]$scriptDir,
    [string]$appPackage
)

# Convert package name to path (e.g., com.example.helloworld -> com\example\helloworld)
$packagePath = $appPackage -replace '\.', '\'

# Use Resolve-Path to get absolute paths and ensure they work
$scriptDir = $scriptDir.TrimEnd('\')

# Create directories using absolute paths
$dirs = @(
    "$scriptDir\app\src\main\java\$packagePath",
    "$scriptDir\app\src\main\res\drawable",
    "$scriptDir\app\src\main\res\values",
    "$scriptDir\app\src\main\assets",
    "$scriptDir\app\src\main\res\mipmap-hdpi",
    "$scriptDir\app\src\main\res\mipmap-mdpi",
    "$scriptDir\app\src\main\res\mipmap-xhdpi",
    "$scriptDir\app\src\main\res\mipmap-xxhdpi",
    "$scriptDir\app\src\main\res\mipmap-xxxhdpi",
    "$scriptDir\app\src\main\res\xml"
)

foreach ($dir in $dirs) {
    try {
        New-Item -ItemType Directory -Force -Path $dir -ErrorAction Stop | Out-Null
        Write-Host "Created: $dir"
    } catch {
        Write-Error "Failed to create directory: $dir - $_"
        exit 1
    }
}

Write-Host "All directories created successfully."
