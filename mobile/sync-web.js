/*
 * sync-web.js — copy the product into the Capacitor web dir.
 *
 * daily-log.html stays the single source of truth. This copies it to
 * www/index.html and injects a tiny Android bridge script (capacitor-export.js)
 * ONLY into the bundled copy — the shipped/web version is never modified.
 */
const fs = require("fs");
const path = require("path");

const root = __dirname;
const src = path.join(root, "..", "daily-log.html");
const wwwDir = path.join(root, "www");
const bridge = path.join(root, "src", "capacitor-export.js");

fs.mkdirSync(wwwDir, { recursive: true });

let html = fs.readFileSync(src, "utf8");

// bring the bridge into the web dir and reference it (idempotent)
fs.copyFileSync(bridge, path.join(wwwDir, "capacitor-export.js"));
if (!html.includes("capacitor-export.js")) {
  html = html.replace("</body>", '<script src="capacitor-export.js"></script>\n</body>');
}
fs.writeFileSync(path.join(wwwDir, "index.html"), html);

const m = html.match(/const APP_VERSION\s*=\s*"([^"]+)"/);
console.log(`Synced daily-log.html -> www/index.html (v${m ? m[1] : "?"})`);
