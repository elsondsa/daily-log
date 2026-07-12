/* Daily Log — minimal service worker.
 *
 * Only used when the app is SERVED over https (or localhost). The buyer's
 * single-file, double-clicked copy runs from file:// where service workers
 * are unavailable — but a local file is already fully offline, so nothing is
 * lost. This SW gives a hosted copy offline support after first load.
 *
 * Strategy: stale-while-revalidate. Serve from cache instantly when present,
 * refresh the cache in the background. Google Fonts + the app shell get
 * cached on first use, so subsequent loads work offline.
 */
const CACHE = "daily-log-v1";

self.addEventListener("install", () => self.skipWaiting());

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (event) => {
  const req = event.request;
  if (req.method !== "GET") return;

  event.respondWith(
    caches.open(CACHE).then((cache) =>
      cache.match(req).then((cached) => {
        const network = fetch(req)
          .then((res) => {
            if (res && res.status === 200 && (res.type === "basic" || res.type === "cors")) {
              cache.put(req, res.clone());
            }
            return res;
          })
          .catch(() => cached);
        return cached || network;
      })
    )
  );
});
