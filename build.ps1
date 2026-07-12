<#
  build.ps1 — package Daily Log for buyers.

  Produces  site/download/daily-log-v<VERSION>.zip  containing:
    - daily-log.html      (the app; version read from its APP_VERSION const)
    - START-HERE.html     (setup guide)
    - daily-system.pdf    (method guide; rendered from daily-system.html via Chrome,
                           falls back to copying the .html if Chrome isn't found)

  Run from the repo root:   powershell -ExecutionPolicy Bypass -File build.ps1
#>

$ErrorActionPreference = "Stop"
$root  = $PSScriptRoot
$app   = Join-Path $root "daily-log.html"
$pkg   = Join-Path $root "package"
$stage = Join-Path $root "dist\package"
$outDir = Join-Path $root "site\download"

# --- version from APP_VERSION ---
$m = Select-String -Path $app -Pattern 'const APP_VERSION\s*=\s*"([^"]+)"' | Select-Object -First 1
if (-not $m) { throw "Could not find APP_VERSION in daily-log.html" }
$version = $m.Matches[0].Groups[1].Value
Write-Host "Daily Log version: $version" -ForegroundColor Cyan

# --- fresh staging ---
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force -Path $stage | Out-Null
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

Copy-Item $app                              (Join-Path $stage "daily-log.html")
Copy-Item (Join-Path $pkg "START-HERE.html") (Join-Path $stage "START-HERE.html")

# --- method guide -> PDF (needs Chrome/Edge) ---
# NOTE: Chrome's --print-to-pdf is run from a space-free temp dir via
# Start-Process -Wait. This avoids two Windows/PowerShell gotchas: `&` does not
# wait for Chrome (a GUI-subsystem app) to finish, and args with spaces get
# split ("Multiple targets"). We render to temp, then copy the PDF into staging.
$guideHtml = Join-Path $pkg "daily-system.html"
$guidePdf  = Join-Path $stage "daily-system.pdf"
$chrome = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

$madePdf = $false
if ($chrome) {
  $work = Join-Path $env:TEMP ("dl-build-" + [guid]::NewGuid().ToString("N").Substring(0,8))
  New-Item -ItemType Directory -Force -Path $work | Out-Null
  $tmpHtml = Join-Path $work "guide.html"
  $tmpPdf  = Join-Path $work "guide.pdf"
  Copy-Item $guideHtml $tmpHtml
  $url = "file:///" + ($tmpHtml -replace '\\','/')
  Write-Host "Rendering method guide -> PDF via $(Split-Path $chrome -Leaf)"
  Start-Process -FilePath $chrome -Wait -NoNewWindow -ArgumentList @(
    "--headless=new","--disable-gpu","--no-pdf-header-footer","--virtual-time-budget=5000",
    "--print-to-pdf=$tmpPdf", $url)
  if (Test-Path $tmpPdf) { Copy-Item $tmpPdf $guidePdf -Force; $madePdf = $true }
  Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
}
if (-not $madePdf) {
  Write-Warning "PDF not produced (Chrome/Edge missing or failed); including the HTML method guide instead."
  Copy-Item $guideHtml (Join-Path $stage "daily-system.html")
}

# --- zip ---
$zip = Join-Path $outDir "daily-log-v$version.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $stage "*") -DestinationPath $zip
$size = "{0:N0} KB" -f ((Get-Item $zip).Length / 1KB)

Write-Host ""
Write-Host "Built: $zip ($size)" -ForegroundColor Green
Get-ChildItem $stage | ForEach-Object { Write-Host "  - $($_.Name)" }
Write-Host ""
Write-Host "Reminder: the thank-you page links to /download/daily-log-v$version.zip" -ForegroundColor Yellow
