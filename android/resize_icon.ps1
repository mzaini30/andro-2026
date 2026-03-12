param(
    [string]$inputPath,
    [string]$outputPath,
    [int]$maxSize = 512
)

# Load the image
try {
    $image = [System.Drawing.Image]::FromFile($inputPath)
} catch {
    Write-Host "ERROR: Failed to load image: $inputPath"
    Write-Host $_.Exception.Message
    exit 1
}

$originalWidth = $image.Width
$originalHeight = $image.Height

Write-Host "Icon loaded: $($originalWidth)x$($originalHeight) px"

# Check if resizing is needed
if ($originalWidth -le $maxSize -and $originalHeight -le $maxSize) {
    Write-Host "Icon size is OK (no resizing needed). Copying as-is..."
    Copy-Item $inputPath $outputPath -Force
    $image.Dispose()
    exit 0
}

Write-Host "Icon too large. Resizing to max $maxSize x $maxSize..."

# Calculate new dimensions (maintain aspect ratio)
if ($originalWidth -gt $originalHeight) {
    $newWidth = $maxSize
    $newHeight = [int]($originalHeight * ($maxSize / $originalWidth))
} else {
    $newHeight = $maxSize
    $newWidth = [int]($originalWidth * ($maxSize / $originalHeight))
}

Write-Host "New size: $($newWidth)x$($newHeight) px"

# Create a new bitmap with the resized image
$bitmap = New-Object System.Drawing.Bitmap $newWidth, $newHeight
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

# Set high-quality interpolation
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Draw the resized image
$graphics.DrawImage($image, 0, 0, $newWidth, $newHeight)

# Save the resized image
$bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

Write-Host "Icon resized and saved to: $outputPath"

# Clean up
$graphics.Dispose()
$bitmap.Dispose()
$image.Dispose()

exit 0
