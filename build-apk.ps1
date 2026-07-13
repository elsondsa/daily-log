<#
  build-apk.ps1 — build the Daily Log Android APK via Capacitor.

  Bundles daily-log.html into a self-contained app (offline; no hosted URL
  needed) and drops the APK in site/download/ so it can be delivered like the
  buyer zip.

  PREREQUISITES (install once on the build machine):
    - Node.js (already used by the site build)
    - JDK 17            → set JAVA_HOME
    - Android Studio + Android SDK (SDK Platform + Build-Tools)
                        → set ANDROID_HOME (or ANDROID_SDK_ROOT)

  USAGE:
    Debug (quick, self-signed — fine for sideload testing):
      powershell -ExecutionPolicy Bypass -File build-apk.ps1

    Release (signed for distribution — needs your keystore):
      powershell -ExecutionPolicy Bypass -File build-apk.ps1 -Release `
        -Keystore "C:\keys\daily-log.jks" -KeyAlias dailylog `
        -StorePass ****** -KeyPass ******
#>
param(
  [switch]$Release,
  [string]$Keystore,
  [string]$KeyAlias,
  [string]$StorePass,
  [string]$KeyPass
)

$ErrorActionPreference = "Stop"
$root   = $PSScriptRoot
$mobile = Join-Path $root "mobile"
$app    = Join-Path $root "daily-log.html"
$outDir = Join-Path $root "site\download"

function Need($name, $hint) {
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) { throw "$name not found on PATH. $hint" }
}

# --- version ---
$m = Select-String -Path $app -Pattern 'const APP_VERSION\s*=\s*"([^"]+)"' | Select-Object -First 1
if (-not $m) { throw "Could not read APP_VERSION from daily-log.html" }
$version = $m.Matches[0].Groups[1].Value
Write-Host "Daily Log version: $version" -ForegroundColor Cyan

# --- prereqs ---
Need "node" "Install Node.js."
Need "npm"  "Install Node.js."
if (-not (Get-Command "java" -ErrorAction SilentlyContinue)) { Write-Warning "java not on PATH — the Gradle build will fail without a JDK 17." }
if (-not ($env:ANDROID_HOME -or $env:ANDROID_SDK_ROOT)) { Write-Warning "ANDROID_HOME / ANDROID_SDK_ROOT not set — Gradle can't find the Android SDK." }

Push-Location $mobile
try {
  # 1. deps
  if (-not (Test-Path (Join-Path $mobile "node_modules"))) {
    Write-Host "Installing npm dependencies..." -ForegroundColor Cyan
    npm install
  }

  # 2. copy the app into www/
  Write-Host "Syncing web assets..." -ForegroundColor Cyan
  node sync-web.js

  # 3. first-time Android scaffold + icons
  if (-not (Test-Path (Join-Path $mobile "android"))) {
    Write-Host "Adding Android platform (first run)..." -ForegroundColor Cyan
    npx cap add android
    Write-Host "Generating app icons..." -ForegroundColor Cyan
    npm run assets
  }

  # 4. sync web + plugins into the native project
  Write-Host "Running cap sync..." -ForegroundColor Cyan
  npx cap sync android

  # 5. gradle build
  $android = Join-Path $mobile "android"
  $gradlew = Join-Path $android "gradlew.bat"
  Push-Location $android
  try {
    if ($Release) {
      Write-Host "Building RELEASE apk..." -ForegroundColor Cyan
      & $gradlew assembleRelease
      $apk = Join-Path $android "app\build\outputs\apk\release\app-release-unsigned.apk"
      if (-not (Test-Path $apk)) { $apk = Join-Path $android "app\build\outputs\apk\release\app-release.apk" }
    } else {
      Write-Host "Building DEBUG apk..." -ForegroundColor Cyan
      & $gradlew assembleDebug
      $apk = Join-Path $android "app\build\outputs\apk\debug\app-debug.apk"
    }
  } finally { Pop-Location }

  if (-not (Test-Path $apk)) { throw "APK not produced by Gradle. Check the build output above." }

  # 6. sign release APK with your keystore (zipalign + apksigner from build-tools)
  $suffix = "debug"
  if ($Release) {
    $suffix = "release"
    if ($Keystore -and $KeyAlias) {
      $sdk = $env:ANDROID_HOME; if (-not $sdk) { $sdk = $env:ANDROID_SDK_ROOT }
      $bt = Get-ChildItem (Join-Path $sdk "build-tools") -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
      if (-not $bt) { throw "Could not find Android build-tools under $sdk for signing." }
      $zipalign  = Join-Path $bt.FullName "zipalign.exe"
      $apksigner = Join-Path $bt.FullName "apksigner.bat"
      $aligned = [IO.Path]::ChangeExtension($apk, ".aligned.apk")
      Write-Host "Signing with $($bt.Name) build-tools..." -ForegroundColor Cyan
      & $zipalign -f -p 4 $apk $aligned
      $signArgs = @("sign","--ks",$Keystore,"--ks-key-alias",$KeyAlias)
      if ($StorePass) { $signArgs += @("--ks-pass","pass:$StorePass") }
      if ($KeyPass)   { $signArgs += @("--key-pass","pass:$KeyPass") }
      $signArgs += $aligned
      & $apksigner @signArgs
      $apk = $aligned
    } else {
      Write-Warning "Release APK is UNSIGNED (no -Keystore/-KeyAlias given). It won't install until signed."
    }
  }

  # 7. deploy: copy to site/download so it can be served like the zip
  New-Item -ItemType Directory -Force -Path $outDir | Out-Null
  $dest = Join-Path $outDir "daily-log-v$version-$suffix.apk"
  Copy-Item $apk $dest -Force
  $size = "{0:N1} MB" -f ((Get-Item $dest).Length / 1MB)

  Write-Host ""
  Write-Host "Built APK: $dest ($size)" -ForegroundColor Green
  if ($suffix -eq "debug") {
    Write-Host "This is a DEBUG build — good for sideload testing. Use -Release + keystore for distribution." -ForegroundColor Yellow
  }
} finally { Pop-Location }
