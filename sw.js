// يخلي الأبلكيشن يفتح بسرعة ويتثبت على الموبايل. البيانات نفسها بتيجي من Supabase دايمًا.
const CACHE='daftar-v6';
const SHELL=['./','index.html','supabase.js','manifest.webmanifest','icon-192.png','icon-512.png'];
self.addEventListener('install',e=>{e.waitUntil(caches.open(CACHE).then(c=>c.addAll(SHELL)).then(()=>self.skipWaiting()))});
self.addEventListener('activate',e=>{e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==CACHE).map(k=>caches.delete(k)))).then(()=>self.clients.claim()))});
self.addEventListener('fetch',e=>{const u=new URL(e.request.url);
  if(e.request.method!=='GET'||u.hostname.endsWith('supabase.co'))return;
  // network first for the page, cache fallback when offline
  e.respondWith(fetch(e.request).then(r=>{if(r.ok&&(u.origin===location.origin||u.hostname==='cdn.jsdelivr.net'||u.hostname.includes('fonts.g'))){const cp=r.clone();caches.open(CACHE).then(c=>c.put(e.request,cp))}return r}).catch(()=>caches.match(e.request)))});
