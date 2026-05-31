# Media Upload - Technical Specification

## 🏗️ Architecture Overview

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│   Frontend   │────►│   Backend    │────►│  Cloudflare  │
│ (Nuxt+Cap)   │     │   (Go)       │     │     R2       │
│ + Nuxt UI v3 │     │              │     │              │
└──────┬───────┘     └──────────────┘     └──────────────┘
       │                    │                      │
       │  1. POST /presign  │                      │
       │ ──────────────────►│  2. Generate URL     │
       │                    │ ────────────────────►│
       │  3. presigned_url  │                      │
       │ ◄──────────────────│                      │
       │                    │                      │
       │  4. PUT file (direct to R2)               │
       │ ──────────────────────────────────────────►│
       │                    │                      │
       │  5. POST /confirm  │                      │
       │ ──────────────────►│  6. Record in DB     │
       │                    │                      │
       │  7. <img src="r2_url">                    │
       │ ──────────────────────────────────────────►│
```

## 🔧 Technology Stack

- **Storage**: Cloudflare R2 (S3-compatible)
- **Backend SDK**: `github.com/aws/aws-sdk-go-v2` (S3 compatible)
- **Frontend**: Native File API + Capacitor Camera/Filesystem plugins
- **UI Library**: Nuxt UI v3 (`@nuxt/ui`) — `UButton`, `UIcon`, `UModal`, `UProgress`
- **Database**: PostgreSQL — `media_files` table + `journal_entry_media` junction

## 🧩 Frontend Component Architecture

### Components (all use Nuxt UI v3)

| Component | Nuxt UI Primitives | Purpose |
|-----------|-------------------|---------|
| `MediaUploader.vue` | `UButton`, `UIcon`, `UProgress` | Upload zone with drag & drop, thumbnail strip, progress |
| `MediaLightbox.vue` | `UModal`, `UIcon` | Fullscreen image preview with swipe navigation (offline-capable) |
| `MediaGrid.vue` | `UIcon` | 2/3-column grid for journal preview mode (offline-capable) |
| `MediaCardPreview.vue` | `UIcon` | Compact thumbnails for homepage/history cards (offline-capable) |
| `CachedImage.vue` | `Icon` | Smart `<img>` replacement with offline cache fallback |

### Composables

| Composable | Purpose |
|-----------|---------|
| `useMediaUpload()` | Upload with progress, validation, auto-resize, delete, attach to journal |
| `useOfflineMedia()` | Offline image caching via Cache API: cache, resolve, precache, clear |

### Integration Points

| Page | Component | Location in Template |
|------|-----------|---------------------|
| `components/Journal/ModalContents.vue` | `MediaUploader` | Below `<textarea>` in `journal_prompt` slides |
| `pages/index.vue` | `MediaCardPreview` | Inside journal entry card, below text excerpt |
| `pages/history/index.vue` | `MediaCardPreview` | Inside journal list item, mode="history" |
| `pages/journal/[id].vue` | `MediaGrid` | Below slide content in view mode |

## 📡 API Endpoints

### POST /api/v1/media/presign
Request presigned upload URL.

**Request:**
```http
POST /api/v1/media/presign
Content-Type: application/json
Authorization: Bearer {token}

{
  "filename": "photo.jpg",
  "content_type": "image/jpeg",
  "size_bytes": 2048000
}
```

**Response:**
```json
{
  "media_id": "uuid",
  "upload_url": "https://abc.r2.cloudflarestorage.com/media/...?X-Amz-...",
  "download_url": "https://cdn.tranquara.com/media/...",
  "expires_at": "2026-05-31T19:00:00Z"
}
```

### POST /api/v1/media/{id}/confirm
Confirm upload completed. Returns full `MediaFile` object.

### GET /api/v1/media/{id}
Get media file metadata + URL.

### DELETE /api/v1/media/{id}
Delete media file (removes from R2 + DB). Returns 204 No Content.

### GET /api/v1/media/journal/{journalEntryId}
Get all media for a journal entry. Returns `{ "media": [...] }` with slide_index and position.

### POST /api/v1/media/attach
Attach media files to journal entry slides.

**Request:**
```json
{
  "journal_id": "uuid",
  "slides": [
    { "slide_index": 0, "media_ids": ["uuid1", "uuid2"] },
    { "slide_index": 2, "media_ids": ["uuid3"] }
  ]
}
```

## 📱 Offline Media Caching

### Architecture

Images are cached using the **browser Cache API** which works in both web and Capacitor native WebView. No additional native plugins needed.

### Components

| Component | File | Purpose |
|-----------|------|---------|
| `useOfflineMedia` composable | `composables/useOfflineMedia.ts` | Cache API wrapper: cache, resolve, precache, clear |
| `CachedImage` component | `components/Media/CachedImage.vue` | Smart `<img>` replacement with offline fallback |

### Caching Strategy

```
┌─────────────────────────────────────────────┐
│                 CachedImage                  │
├─────────────────┬───────────────────────────┤
│     Online      │         Offline           │
├─────────────────┼───────────────────────────┤
│ Load from R2 URL│ Load from Cache API       │
│ Background cache│ Return blob:// URL        │
│ for future use  │ Fallback: placeholder icon│
└─────────────────┴───────────────────────────┘
```

### Cache Lifecycle
- **Cache name**: `tranquara-media-v1`
- **Max age**: 30 days
- **Auto-cache**: Images cached in background when viewed online
- **Auto-precache**: Journal entry images precached on component mount
- **Clear on logout**: Via `clearCache()` 
- **Memory management**: Blob URLs revoked on component unmount

### Online/Offline Detection
- Uses `@capacitor/network` plugin on native (already installed)
- Falls back to `navigator.onLine` on web
- Reactive `isOnline` ref shared across all components

## 🔐 Security Considerations

- **Presigned URLs** expire after 15 minutes
- **File validation**: Backend checks content_type + size_bytes before issuing presigned URL
- **User isolation**: R2 key includes `users/{user_id}/`
- **Auth required**: All endpoints require valid JWT bearer token
- **Max limits**: 5 images per slide, 10MB per image, JPEG/PNG/WebP/GIF only

## ⚡ Performance Requirements

- Presigned URL generation: < 100ms
- Image serving: via R2 public URL or CDN — < 200ms
- Auto-resize: frontend canvas resize to max 1920px before upload
- Lazy loading: `loading="lazy"` on all card thumbnails

## Environment Configuration

```env
R2_ACCOUNT_ID=your_account_id
R2_ACCESS_KEY_ID=your_access_key
R2_SECRET_ACCESS_KEY=your_secret_key
R2_BUCKET_NAME=tranquara-media
R2_PUBLIC_URL=https://cdn.tranquara.com
```

## 📝 Implementation Checklist

- [x] Add R2 env vars to config
- [x] Install aws-sdk-go-v2
- [x] Create media storage service (`internal/media/r2_storage.go`)
- [x] Create media DB repository (`internal/media/repository.go`)
- [x] Create API handlers (`cmd/api/media.go`)
- [x] Add routes to router
- [x] Create migration (000040)
- [x] Frontend composable (`composables/useMediaUpload.ts`)
- [x] Frontend types (`types/media.ts`)
- [x] Offline media caching composable (`composables/useOfflineMedia.ts`)
- [x] CachedImage component (`components/Media/CachedImage.vue`)
- [x] MediaCardPreview with offline support
- [x] MediaLightbox with offline support
- [x] MediaGrid with offline support
- [ ] Rewrite components with Nuxt UI v3
- [ ] Integrate into ModalContents
- [ ] Integrate into Homepage cards
- [ ] Integrate into History page
- [ ] Integrate into Journal view