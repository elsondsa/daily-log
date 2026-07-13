# Daily Log — Android app (Capacitor)

Bundles the single-file product (`../daily-log.html`) into a **self-contained,
offline Android APK**. The app is stored *inside* the APK — no hosted URL, no
server. `daily-log.html` stays the single source of truth; `sync-web.js` copies
it into `www/` at build time.

## Prerequisites (install once)
- **Node.js** (already used by the site build)
- **JDK 17** — set `JAVA_HOME`
- **Android Studio + Android SDK** (SDK Platform + Build-Tools) — set
  `ANDROID_HOME` (or `ANDROID_SDK_ROOT`)

## Build (from the repo root)
```powershell
# Debug APK — self-signed, for sideload testing:
powershell -ExecutionPolicy Bypass -File build-apk.ps1

# Release APK — signed for distribution (needs your keystore):
powershell -ExecutionPolicy Bypass -File build-apk.ps1 -Release `
  -Keystore "C:\keys\daily-log.jks" -KeyAlias dailylog -StorePass **** -KeyPass ****
```
`build-apk.ps1` runs: `npm install` → `sync-web.js` → (first run) `cap add
android` + icon generation → `cap sync` → Gradle build → (release) sign → copies
the APK to `../site/download/daily-log-v<version>-<debug|release>.apk`.

First run scaffolds `mobile/android/` (git-ignored, regenerated as needed). To
tweak native bits, `npm run open:android` opens the project in Android Studio.

## Make a signing key (once, for release)
```
keytool -genkey -v -keystore daily-log.jks -alias dailylog \
  -keyalg RSA -keysize 2048 -validity 10000
```
Keep this file + passwords safe — every future update must use the same key.

## Distribution
Deliver the signed APK as a **direct download** from the thank-you page (add a
link to `/download/daily-log-v<version>-release.apk`). This keeps the Razorpay
one-time-purchase model — avoid Google Play, which would require Play Billing
for the sale. Users enable "install from unknown sources" to sideload.

## Known limitations (verify on a real device)
- **"Save to file"** (File System Access API) is desktop-Chromium only; the
  button hides itself on Android automatically.
- **Export** uses a browser blob-download that a WebView can't perform, so
  `src/capacitor-export.js` (injected into the bundled copy only) intercepts it
  and saves/shares the backup via the Filesystem + Share plugins. **This path
  has not been device-tested — check Export works before shipping.**
- **Import** uses a normal file input, which Capacitor's WebView supports.
