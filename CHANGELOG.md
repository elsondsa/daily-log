# Changelog

All notable changes to **Daily Log** are documented here. The version shown in
the app footer matches the latest released entry. Format follows
[Keep a Changelog](https://keepachangelog.com/); this project uses
[Semantic Versioning](https://semver.org/).

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
