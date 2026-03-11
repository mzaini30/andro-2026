param(
    [string]$scriptDir,
    [string]$appPackage
)

# Convert package name to path (e.g., com.example.helloworld -> com\example\helloworld)
$packagePath = $appPackage -replace '\.', '\'

# Create directories
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
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}
