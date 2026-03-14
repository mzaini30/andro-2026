param(
    [string]$configFile
)

$yaml = Get-Content $configFile -Raw
$title = ''
$version = ''
$package = ''
$icon = ''
$web = ''
$ads_id = ''
$ads_banner = ''
$ads_open = ''

$in_ads_section = $false

foreach ($line in $yaml -split "`n") {
    if ($line -match '^\s*-\s*title:\s*["\x27]?(.*?)["\x27]?\s*$') {
        $title = $matches[1].Trim()
        $in_ads_section = $false
    }
    elseif ($line -match '^\s*-\s*version:\s*["\x27]?(.*?)["\x27]?\s*$') {
        $version = $matches[1].Trim()
        $in_ads_section = $false
    }
    elseif ($line -match '^\s*-\s*package:\s*["\x27]?(.*?)["\x27]?\s*$') {
        $package = $matches[1].Trim()
        $in_ads_section = $false
    }
    elseif ($line -match '^\s*-\s*icon:\s*["\x27]?(.*?)["\x27]?\s*$') {
        $icon = $matches[1].Trim()
        $in_ads_section = $false
    }
    elseif ($line -match '^\s*-\s*web:\s*["\x27]?(.*?)["\x27]?\s*$') {
        $web = $matches[1].Trim()
        $in_ads_section = $false
    }
    elseif ($line -match '^\s*-\s*ads:\s*$') {
        $in_ads_section = $true
    }
    elseif ($in_ads_section -and $line -match '^\s*-\s*id:\s*["\x27]?(.*?)["\x27]?\s*$') {
        $ads_id = $matches[1].Trim()
    }
    elseif ($in_ads_section -and $line -match '^\s*-\s*banner:\s*["\x27]?(.*?)["\x27]?\s*$') {
        $ads_banner = $matches[1].Trim()
    }
    elseif ($in_ads_section -and $line -match '^\s*-\s*open:\s*["\x27]?(.*?)["\x27]?\s*$') {
        $ads_open = $matches[1].Trim()
    }
    elseif ($line -match '^\s*-\s*\w+:') {
        $in_ads_section = $false
    }
}

Write-Output "APP_TITLE=$title"
Write-Output "APP_VERSION=$version"
Write-Output "APP_PACKAGE=$package"
Write-Output "APP_ICON=$icon"
Write-Output "APP_WEB=$web"
Write-Output "APP_ADS_ID=$ads_id"
Write-Output "APP_ADS_BANNER=$ads_banner"
Write-Output "APP_ADS_OPEN=$ads_open"
