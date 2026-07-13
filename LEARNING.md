# Understanding Daily Log — a learning guide

You had the idea; this doc helps you understand what was built so you can
maintain and debug it yourself. Read Part 0 and Part 1 first — the rest is
reference you come back to. Nothing here needs an AI to follow.

---

## Part 0 — The one big idea

**Everything in this project is just files that a web browser reads.** There is
no program "running on a server" doing logic (with one optional exception noted
later). When someone visits your site, Cloudflare hands their browser some
`.html`, `.css`, and `.js` files, and the *browser* runs them. The habit
tracker itself is a single `.html` file — open it and the browser does
everything, offline.

Once that clicks, the whole thing gets much less scary: to change how something
looks or works, you edit a text file and re-open it in a browser.

Three "places" your project lives:
1. **Your computer** — where you edit the files.
2. **GitHub** — a website that stores your files and their history (a backup +
   a record of every change). Also runs the APK build for you.
3. **Cloudflare Pages** — takes the files from GitHub and serves them to the
   public at your web address.

The flow: *edit on your computer → push to GitHub → Cloudflare publishes.*

---

## Part 1 — The stack at a glance

| Layer | Technology | In your project | Where |
|---|---|---|---|
| Structure | **HTML** | The app + every site page | `daily-log.html`, `site/*.html` |
| Styling | **CSS** | The dark "evening ledger" look | inside `<style>` in each file |
| Logic | **JavaScript** | Habits, tasks, saving, everything | inside `<script>` in each file |
| Data storage | **localStorage** (browser memory) | Your habits/tasks live here | browser, per device |
| Data (extra) | **File System Access API** + **IndexedDB** | "Save to file" auto-save | `daily-log.html` |
| Version control | **Git** | Tracks every change; lets you undo | `.git/` folder |
| Code host | **GitHub** | Stores the repo `elsondsa/daily-log` | github.com |
| Web hosting | **Cloudflare Pages** | Publishes `site/` to the internet | cloudflare dashboard |
| Payments | **Razorpay** | The Buy button / checkout | dashboard + a link in the site |
| Ads tracking | **Meta Pixel** | Measures ad → purchase | `<script>` in landing + thank-you |
| Mobile app | **Capacitor** + **Android** | Wraps the app into an APK | `mobile/` |
| Automation | **GitHub Actions** | Builds the APK in the cloud | `.github/workflows/` |

You do **not** need to master all of these. The next part orders them by what
actually matters for you.

---

## Part 2 — The learning curve (in order)

Each stage says *what* to learn, *why it matters here*, and *what to practice on
in your own repo*. Don't rush — Stage 1–3 already let you handle 90% of changes.

### Stage 1 — HTML & CSS (the look and content)  ⭐ start here
- **Learn:** what tags are (`<div>`, `<h1>`, `<button>`, `<a href>`), and how
  CSS rules style them (selectors, colors, spacing, flexbox). Just enough to
  read and tweak.
- **Why here:** changing wording, prices, colors, or layout on your site is
  pure HTML/CSS. E.g. the pricing text and the FAQ in `site/index.html`.
- **Practice:** open `site/index.html` in Chrome, right-click → *Inspect*, and
  watch which HTML makes which part of the page. Change a headline, save,
  refresh.
- **Resources:** MDN "HTML basics" and "CSS first steps"; freeCodeCamp's
  Responsive Web Design course.

### Stage 2 — Browser DevTools (your #1 debugging tool)  ⭐
- **Learn:** the **Console** (shows JavaScript errors), **Elements** (the live
  HTML/CSS), **Application → Local Storage** (see your saved data), **Network**
  (what files loaded).
- **Why here:** when *anything* looks wrong in the app, the Console usually
  tells you why. This is the single most useful skill.
- **Practice:** open `daily-log.html`, press **F12**, add a habit, then look in
  **Application → Local Storage** — you'll literally see `habitTrackerData`
  change. Break something on purpose (mistype a word in the `<script>`) and read
  the red error in the Console.
- **Resources:** "Chrome DevTools" docs; search "Chrome DevTools console
  tutorial".

### Stage 3 — JavaScript basics (the logic)
- **Learn:** variables, functions, `if`/loops, arrays/objects, and how JS
  changes the page (`document.getElementById`, event listeners for clicks).
- **Why here:** all app behavior is here. In `daily-log.html`, functions like
  `renderHabits()`, `addTask()`, `serializeBundle()` are plain JS.
- **Practice:** find `function addTask()` in `daily-log.html` and read it
  top-to-bottom. It's short and named clearly. Change the default category
  `"General"` to something else and watch it work.
- **Resources:** **javascript.info** (best free deep course) — first chapters;
  or freeCodeCamp "JavaScript Algorithms and Data Structures".

### Stage 4 — Git & GitHub (save, undo, publish)
- **Learn:** `commit` (save a snapshot with a message), `push` (send to GitHub),
  `pull` (get changes), `log` (history), and how to **undo** (`git restore`,
  `git revert`). Branches can come later.
- **Why here:** this is your safety net and your publish button. Every change
  you push is what Cloudflare publishes. If you break something, git lets you go
  back.
- **Practice:** run `git log --oneline` to see your history. Make a tiny edit,
  then `git status`, `git add`, `git commit -m "test"`, `git push`. Watch it go
  live.
- **Resources:** "Git and GitHub for Beginners" (freeCodeCamp video); the
  official Git Book (Chapters 1–3); GitHub's own "Hello World" guide.

### Stage 5 — How it gets online (Cloudflare Pages)
- **Learn:** Cloudflare Pages watches your GitHub repo and republishes `site/`
  on every push. Understand its **Deployments** tab and build log.
- **Why here:** if a change isn't showing up live, this is where you look. (You
  already hit one gotcha: a commit message containing `[skip ci]` makes
  Cloudflare *skip* publishing — see the troubleshooting map below.)
- **Practice:** in the Cloudflare dashboard, open your project → **Deployments**,
  and watch a new deployment appear after you push.

### Stage 6 — The extras (learn only when you touch them)
- **Razorpay** — payments. Mostly configured in *their* dashboard, not code.
  Learn: Payment Pages/Links, and the redirect-after-payment setting.
- **Meta Pixel** — one script that reports events (`ViewContent`,
  `InitiateCheckout`, `Purchase`) to Facebook for ads. Learn: what a "pixel" and
  an "event" are; test with the *Meta Pixel Helper* Chrome extension.
- **Capacitor / Android / GitHub Actions** — only when you rebuild the APK.
  Learn: what "signing" is (see the keystore section of `mobile/README.md`) and
  how to read a **GitHub Actions** run log.
- **Cloudflare Workers** — the *only* place server-side code would run, and only
  if/when you add the Level-1 payment verification. Ignore until then.

---

## Part 3 — Your repo, file by file

Open these and skim them; they're all readable text.

- **`daily-log.html`** — the whole product. HTML at top, one big `<style>`, one
  big `<script>`. The script is organized in labelled sections (STORAGE KEYS,
  HABITS, TASKS, LONG TERM, etc.). Start reading at the bottom (`renderAll()`)
  and follow the function names.
- **`site/index.html`** — the sales/landing page (hero, features, pricing, FAQ).
- **`site/dl-<random>/index.html`** — the thank-you + download page buyers reach
  after paying. `noindex` = hidden from Google.
- **`site/terms.html` / `privacy.html` / `refunds.html`** — legal pages (fill
  the `[placeholders]`).
- **`site/404.html`** — shown for bad URLs; redirects home.
- **`site/download/`** — the buyer files that get served (the `.zip`, and the
  `.apk` once built).
- **`package/`** — sources for the buyer zip (START-HERE guide, method guide).
- **`build.ps1`** — makes the buyer `.zip`. `build-apk.ps1` — makes the APK
  locally.
- **`mobile/`** — the Capacitor project that turns the app into an Android APK.
- **`.github/workflows/`** — the cloud automation (build the APK, make a
  keystore).
- **`CLAUDE.md`** — the full project brief and every decision made. **Read this
  first when you forget how something works.** `CHANGELOG.md` — what changed in
  each version.

---

## Part 4 — Your debugging toolkit

1. **Browser Console (F12 → Console)** — red text = a JavaScript error, with the
   file and line number. Read it literally; paste it into a search engine.
2. **Application → Local Storage** — see/inspect your actual saved data
   (`habitTrackerData`, `dailyTasksData`, `habitsConfig`, `longTermTasks`,
   `weekNotes`). This is where "my data" physically is.
3. **Network tab** — shows every file the page tried to load and whether it
   failed (red / 404 = "file not found at that path").
4. **GitHub → Actions tab** — click a run, click the failed (red ✗) step, read
   the log bottom-up. The real error is usually near the last red lines.
5. **Cloudflare → Deployments** — see if a deploy ran, succeeded, or was skipped,
   and read its build log.
6. **Git undo** — `git restore <file>` (throw away un-committed edits to a file),
   `git revert <commit>` (safely undo a pushed commit by making a new one).

---

## Part 5 — Troubleshooting map (symptom → look here)

| Symptom | Likely cause | Where to look / fix |
|---|---|---|
| Site change not showing online | Cloudflare didn't deploy; or `[skip ci]` in the commit message; or you didn't `push` | Cloudflare **Deployments**; check `git log` / that you pushed |
| App shows a blank/broken screen | A JavaScript error | Browser **Console** (F12) — read the red error's file+line |
| "My data disappeared" | Different browser/device, or browser cleared site data | Data is per-browser in **Local Storage**; restore via **Import** or the saved `.json` file |
| Buy button does nothing / wrong page | The Razorpay link/redirect | The Razorpay dashboard settings; the `href` in `site/index.html` |
| No purchase shows in Facebook | Pixel not set, or no redirect to thank-you page | Replace `PIXEL_ID`; ensure payment redirects to `/dl-<random>/`; test with Meta Pixel Helper |
| APK build fails (red in Actions) | Missing signing secrets, or a build step error | GitHub **Actions** → the failed step's log |
| APK "app not installed" on phone | Unsigned/mismatched key, or an older version installed with a different key | Use a **signed release** build; uninstall the old one first |
| Download link 404s | The file isn't in `site/download/`, or wrong filename | Check `site/download/`; match the filename in the thank-you page |

---

## Part 6 — Curated resources (free, high quality)

- **HTML/CSS:** MDN Web Docs (`developer.mozilla.org`) — the reference every pro
  uses. freeCodeCamp "Responsive Web Design".
- **JavaScript:** `javascript.info` — thorough and beginner-friendly.
- **Browser DevTools:** Google "Chrome DevTools" docs.
- **Git/GitHub:** freeCodeCamp "Git & GitHub for Beginners" (YouTube); the Git
  Book (`git-scm.com/book`).
- **Cloudflare Pages:** Cloudflare Pages docs (short).
- **Razorpay:** Razorpay Docs → Payment Pages / Payment Links.
- **Meta Pixel:** Meta Business Help Center "About Meta Pixel"; install the
  **Meta Pixel Helper** Chrome extension to debug.
- **Capacitor:** `capacitorjs.com/docs`.

Tip: you don't study these front-to-back. When you need to change something,
learn *just* the piece that touches it.

---

## Part 7 — A safe way to make changes (habits that prevent disasters)

1. **Edit → open in browser → check it works** before anything else. For the
   app, just double-click `daily-log.html`. For site pages, double-click them.
2. **Commit small, with clear messages.** One change per commit. If it breaks,
   you know which commit to undo.
3. **Look at the live site after pushing.** Give Cloudflare a minute, then check.
4. **Never edit the localStorage keys or the data format** carelessly — real
   users have data. `CLAUDE.md` explains why and how migration works.
5. **When unsure, branch:** `git checkout -b my-experiment`, try things, and
   only merge to `main` when happy. `main` is what goes live.
6. **Keep backups of secrets** (the Android keystore, passwords) somewhere safe
   and *out* of the repo (they're git-ignored for a reason).

---

## Part 8 — Mini glossary (terms used in this project)

- **Repo / repository** — the project folder tracked by Git.
- **Commit** — a saved snapshot of changes with a message.
- **Push / pull** — send to / get from GitHub.
- **Branch** — a parallel copy of the code to experiment on; `main` is the live one.
- **Deploy** — publish the files to the internet (Cloudflare does this).
- **localStorage** — a small storage box each browser keeps per website; where
  the app saves your data.
- **PWA** — a website that can be "installed" and works offline.
- **Capacitor** — a tool that wraps a web app into a real mobile app (APK).
- **Signing / keystore** — proving an APK is genuinely from you; required to
  install and update Android apps.
- **CI / GitHub Actions** — automation that runs tasks (like building the APK)
  on GitHub's servers.
- **Pixel / event** — a tracking script and the things it reports (page view,
  checkout started, purchase) for ads.
- **`[skip ci]`** — a phrase in a commit message that tells build systems (incl.
  Cloudflare) *not* to build that commit.

---

*Start with Stages 1–3 and DevTools. That alone makes you able to read, change,
and fix most of Daily Log. Everything else you learn the day you need it.*
