param (
    [string]$OutputFolder = (Join-Path $PSScriptRoot "Day_Delivery\NSE"),
    [datetime]$StartDate = [datetime]::ParseExact("10-Jul-2026", "dd-MMM-yyyy", [cultureinfo]::InvariantCulture),
    [datetime]$EndDate = (Get-Date).Date
)

$ErrorActionPreference = "Stop"
$OutputFolder = [System.IO.Path]::GetFullPath($OutputFolder)
$StartDate = $StartDate.Date
$EndDate = $EndDate.Date

if ($StartDate -gt $EndDate) {
    throw "StartDate ($StartDate) must not be after EndDate ($EndDate)."
}

if (-not (Test-Path -LiteralPath $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
}

$Headers = @{
    "accept" = "*/*"
    "accept-encoding" = "gzip, deflate"
    "accept-language" = "en-US,en;q=0.9,hi;q=0.8"
    "referer" = "https://www.nseindia.com/all-reports"
    "user-agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36"
    "x-requested-with" = "XMLHttpRequest"
}

$BaseUrl = "https://www.nseindia.com/api/reports?archives=%5B%7B%22name%22%3A%22Full%20Bhavcopy%20and%20Security%20Deliverable%20data%22%2C%22type%22%3A%22daily-reports%22%2C%22category%22%3A%22capital-market%22%2C%22section%22%3A%22equities%22%7D%5D&type=equities&mode=single&date="

$targetDates = @(
    for ($date = $StartDate; $date -le $EndDate; $date = $date.AddDays(1)) {
        if ($date.DayOfWeek -notin @([DayOfWeek]::Saturday, [DayOfWeek]::Sunday)) {
            $date
        }
    }
)

$missingDates = @($targetDates | Where-Object {
    $name = "delivery_{0}.csv" -f $_.ToString("dd-MMM-yyyy", [cultureinfo]::InvariantCulture)
    -not (Test-Path -LiteralPath (Join-Path $OutputFolder $name))
})

$successCount = 0
$failCount = 0
$unavailableCount = 0
$failDates = @()
$unavailableDates = @()

Write-Host "[INFO] Output folder: $OutputFolder"
Write-Host "[INFO] Configured range: $($StartDate.ToString('dd-MMM-yyyy')) to $($EndDate.ToString('dd-MMM-yyyy'))"
Write-Host "[INFO] Missing weekday files: $($missingDates.Count)"

for ($i = 0; $i -lt $missingDates.Count; $i++) {
    $targetDate = $missingDates[$i]
    $dateStr = $targetDate.ToString("dd-MMM-yyyy", [cultureinfo]::InvariantCulture)
    $csvFile = Join-Path $OutputFolder "delivery_$dateStr.csv"
    $tempFile = "$csvFile.download"
    $url = $BaseUrl + $dateStr

    Write-Host "[INFO] ($($i + 1)/$($missingDates.Count)) Downloading $dateStr ..."
    try {
        Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
        Invoke-WebRequest -Uri $url -Headers $Headers -TimeoutSec 30 -OutFile $tempFile -UseBasicParsing

        $lines = @(Get-Content -LiteralPath $tempFile -TotalCount 2)
        if ($lines.Count -lt 2 -or $lines[0] -notmatch '^SYMBOL\s*,\s*SERIES\s*,\s*DATE1\s*,') {
            throw "NSE returned content that is not a delivery CSV"
        }

        $dataDateText = ($lines[1] -split ',')[2].Trim()
        $dataDate = [datetime]::MinValue
        $isExpectedDate = [datetime]::TryParseExact(
            $dataDateText,
            "dd-MMM-yyyy",
            [cultureinfo]::InvariantCulture,
            [Globalization.DateTimeStyles]::None,
            [ref]$dataDate
        ) -and $dataDate.Date -eq $targetDate

        if (-not $isExpectedDate) {
            Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
            Write-Host "    -> UNAVAILABLE: NSE returned data for '$dataDateText' instead of '$dateStr' (likely a market holiday)" -ForegroundColor DarkYellow
            $unavailableCount++
            $unavailableDates += $dateStr
            continue
        }

        Move-Item -LiteralPath $tempFile -Destination $csvFile -Force
        Write-Host "    -> Saved to $csvFile" -ForegroundColor Green
        $successCount++
    } catch {
        Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
        Write-Host "    -> SKIPPED: $($_.Exception.Message)" -ForegroundColor Yellow
        $failCount++
        $failDates += $dateStr
    }

    Start-Sleep -Seconds 1
}

Write-Host "[SUMMARY] Downloaded: $successCount   Unavailable: $unavailableCount   Failed: $failCount   Missing checked: $($missingDates.Count)"
if ($unavailableDates.Count -gt 0) {
    Write-Host "  Unavailable dates: $($unavailableDates -join ', ')"
}
if ($failDates.Count -gt 0) {
    Write-Host "  Failed dates: $($failDates -join ', ')"
}
Write-Host "Done. Files saved in $OutputFolder"

if ($failCount -gt 0) { exit 2 }
