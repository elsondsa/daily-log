# Changelog

All notable changes to **Daily Log** are documented here. The version shown in
the app footer matches the latest released entry. Format follows
[Keep a Changelog](https://keepachangelog.com/); this project uses
[Semantic Versioning](https://semver.org/).

## [1.2.0] — 2026-07-17

Full UI redesign. **UI layer only** — the single-file architecture, localStorage
keys, data-migration path, and the v5 export/import bundle are all unchanged and
byte-compatible; existing data renders untouched.

### Added
- **Light theme, now the default** — a warm "paper" look (bg `#FAF9F5`, white
  cards, warm-tinted soft shadows) tuned to be calm and screenshot-worthy. This
  delivers the light-theme toggle deferred in 1.1.0.
- **Theme toggle** in the header, persisted to `localStorage["dailyLogTheme"]`
  (UI-only — not part of the data bundle). First load follows the OS
  `prefers-color-scheme`; an inline head script applies it before paint (no flash)
  and live-follows the OS until the user picks a theme.
- **Glanceable day-status line** under the header (mono): habits done / open tasks
  for the current day.
- **Android app (Capacitor).** `mobile/` wraps the product into a self-contained,
  offline APK; `build-apk.ps1` builds (debug/release), optionally signs, and
  deploys it to `site/download/`. The product is unchanged — `daily-log.html`
  stays the single source; `mobile/sync-web.js` copies it into `www/` and injects
  an Android-only export bridge (`capacitor-export.js`) that saves/shares backups
  via native plugins (a WebView can't do the browser blob-download). Distribute
  as a direct download, not via Play Store (Play Billing would conflict with the
  Razorpay one-time-purchase model). *APK compile + Export bridge need on-device
  testing — not verifiable on the build host without the Android SDK.*

### Changed
- **Complete visual overhaul** of `daily-log.html` while preserving every feature
  and behaviour:
  - Two token-driven themes (light default + dark). Dark rebuilt with higher
    card/background separation to fix the old muddiness; hairlines raised to
    `rgba(255,255,255,0.10)`. No pure `#000`/`#FFF` for ink/background.
  - Accent palette retuned to `#E4572E #C8871E #2667FF #2FA36B #8B5CF6 #E24A78
    #0FA3A3` (coral/amber/blue/green/violet/pink/teal). Stored as mid-tones for
    fills/dots/bars; accent *text* is derived per-theme via `color-mix` so it
    passes WCAG AA on both light and dark surfaces.
  - Mobile (<640px) uses a fixed **bottom tab bar**, single column, ≥44px tap
    targets, safe-area insets. Desktop content is centred (max 920px), never
    full-bleed. Tablet capped at 720px.
  - Denser chip-like habit cards; kanban columns as recessed wells with
    hover-reveal actions (always-visible on touch); 12px heatmap cells; goal cards
    with a 3px accent border + thin 4px progress bar.
  - Tightened type scale (display 28–32px, the date is no longer the hero), one
    radius language (12px cards / 8px controls / 999px pills), two button styles,
    focus-visible rings, and a single 250ms page fade replacing the staggered
    load animation. `prefers-reduced-motion` still fully honoured.

### Notes
- The marketing **site pages still use the old dark look** — restyle them to match
  the app's new light system before launch.

## [1.1.0] — 2026-07-12

Product-polish release. All changes preserve the single-file architecture and
the localStorage data-migration path.

### Added
- **Save to file** (File System Access API, Chromium): connect a
  `daily-log-data.json` file that auto-saves as you work. The file handle is
  remembered across sessions; localStorage remains the cache. Manual
  Export/Import stay as the universal fallback. `Open data file` reconnects an
  existing file on a new device.
- **PWA support**: runtime-generated web manifest, app icon, and iOS/Android
  meta tags, plus a stale-while-revalidate service worker (`sw.js`) for hosted
  (https) deployments. Enables Install / Add to Home Screen. (A locally-opened
  file can't run a service worker, but it is already fully offline.)
- **First-run welcome overlay** for brand-new users — a one-time intro that
  nudges adding the first habit and points to Save-to-file / Install.
- **Weekly review** tab: habits-per-weekday grid, tasks grouped by category,
  long-term momentum for the week, and an editable per-week note. Week
  navigation with ‹ / › .
- **Keyboard shortcuts**: `1`–`9` toggle habits (Habits tab), `n` starts a new
  task, `←` / `→` move between days.
- **Perfect-day micro-celebration** when every habit is completed for a day.
- **Version footer** showing the current app version.

### Changed
- The original three habits (`exercise`, `protein`, `learning`) are seeded for
  every new install — as migration for upgrading users and as editable worked
  examples for brand-new users. The first-run welcome overlay introduces the app
  and its "Make them yours" button opens Manage habits to customise them.
- Export/Import refactored around a shared `serializeBundle` / `mergeBundle`
  core. Bundle **version bumped to 5** with a new `weekNotes` field. Import
  remains backward-compatible with v1–v4 files.

### Notes / deferred
- Deferred to a later release (from the Tier-1 "if time" list): light-theme
  toggle and recurring task templates.

## [1.0.0] — 2026-07-11

- Initial release. Single-file habit tracker with configurable habits
  (add/edit/reorder/archive), daily habit cards with streaks and a 10-week
  heatmap, per-day task kanban with categories and carry-over, long-term goals
  with linked-task progress, past/future date navigation, and versioned
  JSON Export/Import.
