# Daily Log — project guide for Claude

**Daily Log** is a paid, single-file HTML habit tracker sold as a one-time purchase
via Instagram ads. This file is the durable context for the project; read it fully
before working. The product source is [daily-log.html](daily-log.html) (currently ~v1,
internally "v4" data format).

> **Repo note:** the git repo root is this `daily-log/` folder (remote:
> `elsondsa/daily-log`, private). Open this folder — not its parent — when working.
> `Notes` is git-ignored (it has held secrets); never commit it.

---

## Golden rules

1. **Single-file architecture is sacred.** The product is ONE self-contained
   `daily-log.html` — all CSS, JS, SVG icons inline. No build step, no external JS/CSS
   except Google Fonts (which degrade gracefully). A buyer double-clicks the file and it
   works offline. Do not split it into modules or add a bundler.
2. **Never break localStorage keys or the data migration path.** Real users have data.
   Keys: `habitTrackerData`, `dailyTasksData`, `habitsConfig`, `longTermTasks`,
   `weekNotes` (added v1.1.0). Any change to shape must migrate old data forward, not
   discard it. Confirm the migration is safe before major edits. (`daily-log`
   IndexedDB store holds the Save-to-file handle; not part of the data bundle.)
3. **Import must stay backward-compatible** with older export formats (v1 habit-only
   through the current v5 bundle). Bundle now includes `weekNotes`; the version field
   is `5`.
4. **Keep the design system consistent** (below). The landing page and all site pages
   must look like the app's sibling.
5. **Respect `prefers-reduced-motion`** — it's already wired; keep it that way.

---

## Product (current state)

Single self-contained HTML file, all data in localStorage, no backend. Three tabs:
**Habits / Tasks / Long term**, with a shared date navigator.

- **Habits:** fully configurable via the "⚙ Manage habits" panel — add / edit / reorder
  / archive. Each habit has name, color (7-swatch palette), icon (12 inline SVGs), and a
  note placeholder. Archiving keeps history. Config is seeded from the original 3 habits
  (ids `exercise`, `protein`, `learning`) so early users migrate cleanly.
- **Daily habit cards:** check toggle with a draw animation, debounced note input,
  per-habit streaks, a 10-week (70-day) heatmap ("The record"), and stats
  (30-day completion rate, perfect days, best streak).
- **Tasks:** per-day kanban (todo → doing → done). Category chips get auto-assigned
  colors. Unfinished tasks carry over from yesterday. Boards are per-day and follow the
  date navigator.
- **Long term:** goals with an optional ETA (overdue = red, ≤7 days = amber). Progress
  bar is computed from linked daily tasks (done / total), plus weekly momentum. Daily
  tasks link to a long-term goal via a dropdown that only appears when active LTs exist;
  linked tasks show an outlined ◎ chip. Deleting an LT keeps its tasks and just drops
  the link.
- **Date nav:** past and future both allowed. Future dates let you plan tasks but lock
  habits behind a "plan tasks" notice. Today / Tomorrow / Yesterday get friendly labels.
- **Export / Import:** versioned JSON bundle
  `{ version: 4, habits, tasks, habitsConfig, longTerm }`. Import is backward-compatible.

### Code map (all inside `daily-log.html`)
- Storage keys + `loadJSON` + state init + habit-config migration: near the top of
  `<script>`.
- `persistHabits / persistTasks / persistHConf / persistLT` — each writes one
  localStorage key then `flashSaved()`.
- Date helpers: `todayKey`, `dateToKey`, `keyToDate`, `shiftDate`, `uid`, `escapeHTML`.
- Habits: `entry / setEntry / streak`, `renderHabits`, settings panel (`renderSettings`,
  `buildEditor`, `moveHabit`), history (`renderGrids`, `renderStats`).
- Tasks: `tasksFor`, `catColor`, `addTask`, `moveTask`, `deleteTask`, `carryOverTasks`,
  `renderTasks`.
- Long term: `ltStats`, `etaLabel`, `addLT`, `buildLTCard`, `renderLT`.
- Orchestration: `switchTab`, `renderAll` (calls every render fn), event wiring at the
  bottom, final `renderAll()`.

---

## Design system — "evening ledger" (dark)

Keep everything visually consistent with this; site pages are siblings of the app.

- **Background** `#0E1512` with subtle radial glows (blue top, orange bottom-left),
  `background-attachment: fixed`.
- **Cards** `#151E19` (`--card`), `#1A2620` (`--card-hi`).
- **Lines** `rgba(255,255,255,0.07)` (`--line`), `rgba(255,255,255,0.14)` (`--line-strong`).
- **Text** `#EDF3EE`, **muted** `#8CA094`, **faint** `#5C6B62`.
- **Accent palette (7):** `#FF7A59 #F2B33D #7FB2FF #5ED39A #B08CFF #FF8FB1 #6FD6D0`.
- **Fonts (Google, graceful fallbacks):**
  - `Fraunces` — display / serif, italic accents (headings, numbers).
  - `Outfit` — body, weight 300.
  - `JetBrains Mono` — labels: uppercase, letter-spaced.
- **Detail:** 16px card radius (`--r`), `color-mix` glows keyed off each item's color,
  subtle `rise` / `pop` animations, `prefers-reduced-motion` fully honored.

---

## Business plan

- **Offer:** one-time purchase. Launch price **₹499** shown against a struck-through
  **₹999** anchor. **7-day, no-questions refund.** Positioning: *"pay once, own forever,
  your data is a file you own — no subscription, no cloud."*
- **Funnel:** Instagram ad (Meta Ads Manager, Reels) → landing page on **Cloudflare
  Pages** (Meta Pixel: `ViewContent` on load, `InitiateCheckout` on Buy click) →
  **Razorpay Payment Page** (KYC in review; collects email + phone; purpose code
  **P0807**) → success-redirect to an **unguessable thank-you page** `/dl-<random>/`
  (Pixel: `Purchase`; `noindex`) → download zip. The download link **also** goes in
  Razorpay's payment-confirmation email as redundancy.
- **Link-leak mitigation:**
  - *Level 0 (now):* unguessable path, `noindex`, an honesty note for non-buyers,
    rotate the path monthly.
  - *Level 1 (later):* a Cloudflare Worker verifies `razorpay_payment_id` against the
    Razorpay API server-side before serving the download. **Structure the thank-you page
    so this drops in behind the button** with minimal change.
- **Deploy:** this GitHub repo (`elsondsa/daily-log`, private) → Cloudflare Pages
  auto-deploy on push. Buyer email list maintained from Razorpay exports.

### Placeholders — ask the user when these are ready
- `PIXEL_ID` — Meta Pixel ID (landing + thank-you).
- `RAZORPAY_PAYMENT_PAGE_URL` — Buy button href.
- `dl-<random>` — the actual random thank-you path.
- Product domain / final product name confirmation.

---

## Repo layout (actual)

**Cloudflare Pages web root = `site/`.** Configure the Pages project with build output
directory `site` (no build command needed). So the landing serves at `/`, policies at
`/terms.html`, the thank-you at `/dl-<random>/`, the download at `/download/...`. The
product master `daily-log.html` stays at repo root for editing; `build.ps1` copies it
into the buyer zip under `site/download/`.

```
/daily-log.html                  product source / master (edit here; APP_VERSION lives here)
/sw.js                           service worker (only used when the app is hosted over https)
/build.ps1                       buyer-package build → site/download/daily-log-v<ver>.zip
/CHANGELOG.md
/CLAUDE.md
/.gitignore                      ignores Notes, dist/, *.zip (except site/download/*.zip)
/Notes                           personal brief (GIT-IGNORED — never commit; held a token)

/site/                           ← Cloudflare Pages web root
  index.html                     landing page (Meta Pixel: ViewContent, InitiateCheckout)
  dl-5wmuje4q889s/index.html     thank-you + download (noindex; Purchase pixel) — ROTATE PATH MONTHLY
  terms.html  privacy.html  refunds.html   policy pages (placeholders to fill before launch)
  404.html                       redirects to /
  assets/favicon.svg             app icon (og.png / demo.mp4 still TODO before launch)
  download/daily-log-v1.1.0.zip  buyer zip (COMMITTED so Pages serves it)

/package/                        buyer-package sources (not shipped as-is)
  START-HERE.html                setup guide (goes in the zip)
  daily-system.html              method guide source → rendered to daily-system.pdf in the zip

/dist/                           build staging (git-ignored)
```

**Thank-you path:** currently `dl-5wmuje4q889s`. When rotating, rename the folder AND
update the Razorpay success-redirect URL + the confirmation-email link.

### Launch checklist (before going live)
- Replace `PIXEL_ID` (landing + thank-you) and `RAZORPAY_PAYMENT_PAGE_URL` (landing, 3 buttons).
- Fill placeholders in terms/privacy/refunds: `[Seller legal name]`, `[support email]`,
  `[City, State]`. Have them reviewed.
- Add real `site/assets/og.png` (1200×630) and `site/assets/demo.mp4` (+ `demo-poster.png`).
- Run `build.ps1` after any product change so the committed zip matches the current version;
  keep the thank-you download filename in sync with `APP_VERSION`.
- **Rotate the exposed GitHub token** before any push (see brief/Notes).

---

## Task list (priority order)

1. **Product polish** (Tier 1; keep single-file + migration intact):
   - **a.** File System Access API "Save to file" — writes `daily-log-data.json`,
     auto-saves, localStorage stays as cache, manual export remains the fallback.
   - **b.** PWA: manifest + minimal service worker + icon → Add to Home Screen, offline.
     Mind single-file quirks.
   - **c.** First-run welcome overlay (one-time): add-first-habit nudge + install /
     save-to-file tip.
   - **d.** Weekly review view: habits per weekday, tasks by category, LT momentum,
     editable week note.
   - **e.** *If time:* recurring task templates (daily / specific weekdays), keyboard
     shortcuts (1–9 habits, `n` new task, ←/→ days), 100%-day micro-celebration, light
     theme toggle.
   - **f.** Version footer "Daily Log v1.x" + `CHANGELOG.md`.
2. **Landing page** (`site/index.html`): hero + looping demo placeholder, feature beats
   (habits/streaks, daily kanban, long-term goals, own-your-data), pricing block (₹999
   struck → ₹499; pay once / own forever / free updates), refund line, short FAQ
   (browser? offline? where's my data?), footer policy links. No nav, single CTA. Pixel
   snippet with placeholder `PIXEL_ID`. Buy button href placeholder
   `RAZORPAY_PAYMENT_PAGE_URL`.
3. **Thank-you page:** download button (zip), 3-line quick start, honesty note for
   non-buyers, `Purchase` pixel event, `noindex`, Worker-upgrade-ready structure.
4. **Policy pages** (terms / privacy / refunds — simple, honest, India-friendly, 7-day
   refund).
5. **Buyer package:** START-HERE guide (open in Chrome/Edge, keep the file in one folder,
   use the same browser, Export = backup, PWA install steps) + zip build script
   (`daily-log-v1.x.zip`).
6. **404 page** → redirect to landing.

When a decision genuinely needs the user (product name/domain, pixel ID, Razorpay URL),
ask — otherwise proceed with sensible defaults and placeholders.

---

## Working notes / decisions log

- Product file renamed `habit-tracker_4.html` → `daily-log.html` to match the product
  name and target repo layout.
- Added `.gitignore` excluding `Notes`, local `daily-log-*.json` data files, and build
  artifacts.
- Browser support target: **Chromium (Chrome / Edge)** is the primary/recommended
  browser — the File System Access API (task 1a) is Chromium-only, so the app must
  degrade gracefully (fall back to manual Export/Import) on Firefox/Safari.

### v1.1.0 (2026-07-12) — implementation notes
- **Task 1 (product polish) is done** except two deferred "if time" items: light-theme
  toggle and recurring task templates. See CHANGELOG for the full list.
- **Save-to-file (1a):** `serializeBundle()` / `mergeBundle()` are the shared read/write
  core (Export, Import, file sync all use them). File handle persisted in IndexedDB
  (`daily-log` → `handles` → `dataFile`). Auto-save is debounced (`scheduleFileWrite`),
  coalesced, and permission-guarded (`hasPermission` for silent writes, `verifyPermission`
  for user-gesture reconnect). On load, `initFileSync()` silently reconnects if permission
  is still granted, else shows a "Reconnect data file" button.
- **PWA (1b):** manifest + icon are generated at runtime in `setupPWA()` (data-URIs, so
  `start_url`/`scope` resolve against the real doc URL). Service worker (`sw.js`, repo
  root) only registers on https/localhost — a `file://` copy can't run one but is already
  offline. Local single-file product is therefore not a *strict* installable PWA; a
  hosted copy is.
- **First-run (1c):** the 3 habits (`exercise`/`protein`/`learning`) are seeded for
  **every** new install — migration for upgraders, editable examples for new users
  (owner's decision, 2026-07-12). The welcome overlay shows only on a genuine first run
  (`isFirstRun` = nothing in storage; computed before seeding); its "Make them yours"
  button opens the Manage-habits panel. Upgraders (have `habitTrackerData`) don't see it.
- **Weekly review (1d):** 4th tab. Uses `weekStartOf()` (Monday-based). Week nav shifts
  `currentDate` by ±7. Week notes stored in `wnotes` / `weekNotes` key.
- **Shortcuts (1e):** global keydown; guarded against typing in inputs and while the
  welcome overlay is open. Number keys act only when the Habits tab is active.
- **Mobile:** 4 tabs overflow narrow phones, so a `max-width: 520px` breakpoint hides the
  count badges and tightens the tab row. Verified no horizontal overflow down to 320px.
- **Verification:** headless-Chrome smoke/screenshot harnesses live in the session
  scratchpad (`smoke.js`, `shot.js`, `measure.js`) — not committed. Re-create as needed:
  they inject an error probe + seed localStorage, render via
  `chrome --headless=new --dump-dom` / `--screenshot`, and read state out of DOM attrs.
