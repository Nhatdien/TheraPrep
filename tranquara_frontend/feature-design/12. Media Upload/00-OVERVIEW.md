# Media Upload - Overview

## 🎯 Purpose

Allow users to attach images to their journal entries, enhancing emotional expression through visual media. The system uses **Cloudflare R2** for storage with presigned URL uploads — the Go backend never handles file bytes directly.

## 📊 Status

- **Current Status**: 🔄 In Progress
- **Priority**: High
- **Target Release**: v1.2
- **Dependencies**: Journal Feature, User Authentication

## 🎨 User Value

- Express emotions visually alongside text in journal entries
- Attach mood-related photos, artwork, or scenes to journal prompts
- View image previews in journal cards across the app
- Fullscreen lightbox preview with swipe navigation

## 🔑 Key Features

- Image upload via presigned URL to Cloudflare R2
- Drag & drop + click upload in journal writing mode
- Thumbnail strip with add/delete during writing
- Compact card previews on Homepage and History
- Lightbox fullscreen preview with pinch-to-zoom
- Auto-resize images on frontend before upload (max 1920px)
- **Offline image caching** — view previously loaded images without internet
- Responsive across mobile, tablet, desktop

## 🧩 Component Library

All Media components use **Nuxt UI v3** (`@nuxt/ui`) primitives for consistency:
- `UButton` — action buttons (add, delete, close)
- `UIcon` — all icons (camera, plus, x, arrow, image)
- `UModal` — lightbox fullscreen preview overlay
- `UProgress` — upload progress bar

## 📋 Scope v1

| Feature | Status |
|---------|--------|
| Upload images (JPEG, PNG, WebP) | ✅ Phase 1 |
| Preview in journal writing | ✅ Phase 1 |
| Thumbnails on cards | ✅ Phase 1 |
| Lightbox fullscreen preview | ✅ Phase 1 |
| Delete attachments | ✅ Phase 1 |
| Offline image caching | ✅ Phase 1 |
| Video upload | ❌ Later |
| Avatar upload | ❌ Later |
| Image compression | ❌ Later |

## 📋 Success Criteria

- [ ] User can upload up to 5 images per journal prompt slide
- [ ] Images appear as thumbnails in journal writing mode
- [ ] Homepage cards show up to 2 image previews
- [ ] History cards show cover image
- [ ] Fullscreen lightbox with swipe works on mobile
- [ ] Upload progress bar visible
- [ ] Works on web + Capacitor mobile

## 🔗 Related Features

- [Journal Feature](../02.%20Jounral%20Feature/) — primary integration point
- [User Profile](../06.%20User%20profile%20and%20Settings/) — future avatar upload
- [Data Import Export](../11.%20Data%20Import%20Export/) — export includes media

## Architecture Decision: Cloudflare R2

**Why R2:**
- Free tier: 10GB storage, 10M requests/month
- S3-compatible API — standard Go libraries work
- No egress fees — images served without bandwidth cost
- Presigned URLs — browser uploads directly to R2
- Backend only stores URLs, never handles file bytes

**Upload Flow:**
```
Frontend → POST /api/v1/media/presign → Backend returns presigned URL
Frontend → PUT file directly to R2 (presigned URL)
Frontend → POST /api/v1/media/{id}/confirm → Backend records in DB
```

## 🔧 Component Architecture

```
components/Media/
├── MediaUploader.vue       ← UButton + UIcon + UProgress (upload zone + thumbnails)
├── MediaLightbox.vue       ← UModal + UIcon (fullscreen preview with swipe + offline)
├── MediaGrid.vue           ← UIcon (2/3-column grid for journal preview + offline)
├── MediaCardPreview.vue    ← UIcon (compact thumbnails for cards + offline)
└── CachedImage.vue         ← Smart <img> with offline cache fallback

composables/
├── useMediaUpload.ts       ← Upload workflow: presign, upload, confirm, delete
└── useOfflineMedia.ts      ← Cache API wrapper: cache, resolve, precache, clear
```

## 🔌 Integration Points

| Page/Component | Media Component | Where |
|---------------|-----------------|-------|
| `components/Journal/ModalContents.vue` | `MediaUploader` | Below textarea in `journal_prompt` slides |
| `pages/index.vue` (Homepage) | `MediaCardPreview` | Inside journal entry cards |
| `pages/history/index.vue` | `MediaCardPreview` | Inside journal list items |
| `pages/journal/[id].vue` | `MediaGrid` | Completed journal preview |

**Last Updated**: May 31, 2026

---

## 📱 Offline Caching

All media display components use `CachedImage` instead of raw `<img>` tags. This provides:

- **Automatic background caching** when images are viewed online
- **Offline viewing** via Cache API when device has no internet
- **Graceful fallback** — placeholder icon shown for uncached images
- **Cache lifecycle** — 30-day max age, auto-clear on logout
- **No extra dependencies** — uses browser Cache API + existing `@capacitor/network` plugin
