param(
    [string]$configFile
)

$yaml = Get-Content $configFile -Raw
$title = ''
$version = ''
$package = ''
$icon = ''
$web = ''
$ads = ''

foreach ($line in $yaml -split "`n") {
    if ($line -match '^\s*-\s*title:\s*["\x27]?(.*?)["\x27]?\s*$') {
        $title = $matches[1].Trim()
    }
    elseif ($line -match '^\s*-\s*version:\s*["\x27]?(.*?)["\x27]?\s*$') {
        $version = $matches[1].Trim()
    }
    elseif ($line -match '^\s*-\s*package:\s*["\x27]?(.*?)["\x27]?\s*$') {
        $package = $matches[1].Trim()
    }
    elseif ($line -match '^\s*-\s*icon:\s*["\x27]?(.*?)["\x27]?\s*$') {
        $icon = $matches[1].Trim()
    }
    elseif ($line -match '^\s*-\s*web:\s*["\x27]?(.*?)["\x27]?\s*$') {
        $web = $matches[1].Trim()
    }
    elseif ($line -match '^\s*-\s*ads:\s*["\x27]?(.*?)["\x27]?\s*$') {
        $ads = $matches[1].Trim()
    }
}

Write-Output "APP_TITLE=$title"
Write-Output "APP_VERSION=$version"
Write-Output "APP_PACKAGE=$package"
Write-Output "APP_ICON=$icon"
Write-Output "APP_WEB=$web"
Write-Output "APP_ADS=$ads"
