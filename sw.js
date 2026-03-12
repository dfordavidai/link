// LinkHub Service Worker — v1.0
const CACHE_NAME = 'linkhub-v1';
const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/manifest.json',
  'https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Merriweather:ital,wght@0,400;0,700;1,400&display=swap',
  'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2'
];

// Install: cache static assets
self.addEventListener('install', e=>{
  e.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(STATIC_ASSETS).catch(()=>{}))
      .then(() => self.skipWaiting())
  );
});

// Activate: delete old caches
self.addEventListener('activate', e=>{
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k=>k!==CACHE_NAME).map(k=>caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

// Fetch strategy:
// - News API calls: network only (always fresh)
// - Static assets: cache first, fallback to network
// - Everything else: network first, fallback to cache
self.addEventListener('fetch', e=>{
  const url = new URL(e.request.url);

  // Always fetch news APIs fresh — never cache
  if(url.hostname.includes('gnews.io') ||
     url.hostname.includes('newsdata.io') ||
     url.hostname.includes('thenewsapi.com') ||
     url.hostname.includes('supabase.co')){
    return; // let browser handle natively
  }

  // Cache-first for static assets (fonts, scripts)
  if(url.hostname.includes('fonts.googleapis') ||
     url.hostname.includes('fonts.gstatic') ||
     url.hostname.includes('jsdelivr')){
    e.respondWith(
      caches.match(e.request).then(cached =>
        cached || fetch(e.request).then(res=>{
          const clone = res.clone();
          caches.open(CACHE_NAME).then(c=>c.put(e.request, clone));
          return res;
        })
      )
    );
    return;
  }

  // Network-first for HTML pages
  e.respondWith(
    fetch(e.request)
      .then(res=>{
        if(res.ok){
          const clone = res.clone();
          caches.open(CACHE_NAME).then(c=>c.put(e.request, clone));
        }
        return res;
      })
      .catch(()=> caches.match(e.request).then(cached => cached || caches.match('/')))
  );
});

// Background sync — refresh news when back online
self.addEventListener('sync', e=>{
  if(e.tag === 'news-refresh'){
    e.waitUntil(
      self.clients.matchAll().then(clients =>
        clients.forEach(client => client.postMessage({type:'REFRESH_NEWS'}))
      )
    );
  }
});
