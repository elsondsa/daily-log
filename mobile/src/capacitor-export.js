/*
 * capacitor-export.js — Android-only bridge (loaded ONLY in the bundled APK).
 *
 * Why: an Android WebView can't perform the browser blob-download that the
 * app's "Export" button uses, and the File System Access "Save to file"
 * feature is desktop-Chromium only (it already hides itself where unsupported).
 * So inside the app we intercept Export and write + share the backup via
 * Capacitor's Filesystem + Share plugins instead.
 *
 * It is a no-op on the web/zip build (window.Capacitor is absent there), so the
 * shipped product behaves exactly as before.
 *
 * NOTE: this path needs a real on-device test — it can't be exercised in a
 * desktop browser. If Share is unavailable it falls back to saving into app
 * storage and telling the user where it went.
 */
(function () {
  function ready(fn) {
    if (document.readyState !== "loading") fn();
    else document.addEventListener("DOMContentLoaded", fn);
  }

  ready(function () {
    var C = window.Capacitor;
    if (!(C && typeof C.isNativePlatform === "function" && C.isNativePlatform())) return;

    var P = C.Plugins || {};
    var Filesystem = P.Filesystem;
    var Share = P.Share;
    var btn = document.getElementById("exportBtn");
    if (!btn || !Filesystem) return;

    // Capture-phase listener runs before the app's own handler and cancels the
    // (non-working) blob download, then exports natively instead.
    btn.addEventListener("click", function (e) {
      e.preventDefault();
      e.stopImmediatePropagation();
      exportNative();
    }, true);

    async function exportNative() {
      try {
        var data = JSON.stringify(window.serializeBundle(), null, 2);
        var name = "daily-log-" + (window.todayKey ? window.todayKey() : "backup") + ".json";
        await Filesystem.writeFile({ path: name, data: data, directory: "CACHE", encoding: "utf8" });
        var uri = await Filesystem.getUri({ path: name, directory: "CACHE" });
        if (Share && Share.share) {
          await Share.share({ title: "Daily Log backup", text: "Your Daily Log data", url: uri.uri });
        } else {
          alert("Backup saved in app storage as " + name);
        }
      } catch (err) {
        alert("Could not export your backup: " + ((err && err.message) || err));
      }
    }
  });
})();
