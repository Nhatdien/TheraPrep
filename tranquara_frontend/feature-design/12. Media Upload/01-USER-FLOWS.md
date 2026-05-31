# Media Upload - User Flows

## 🎭 User Personas

### Primary Users
- **Journaler**: User writing daily emotion journals, wants to attach mood photos

## 🔄 Main User Flow

### Flow 1: Add Image During Journal Writing

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Writing      │────►│ Tap Camera  │────►│ Choose      │
│ Journal      │     │ UButton 📷  │     │ Source      │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                                │
                           ┌────────────────────┼────────────────┐
                           ▼                    ▼                ▼
                    ┌─────────────┐     ┌─────────────┐  ┌─────────────┐
                    │ Take Photo  │     │ Choose from │  │ Cancel      │
                    │ (Camera)    │     │ Gallery     │  └─────────────┘
                    └──────┬──────┘     └──────┬──────┘
                           │                    │
                           └────────┬───────────┘
                                   ▼
                          ┌─────────────────┐
                          │ Image Preview   │
                          │ + UProgress bar │
                          └────────┬────────┘
                                   │
                           ┌───────┴───────┐
                           ▼               ▼
                    ┌─────────────┐ ┌─────────────┐
                    │ Upload OK   │ │ Upload Fail  │
                    │ Thumbnail   │ │ Retry/UButton│
                    │ appears     │ └─────────────┘
                    └─────────────┘
```

### Step-by-Step Walkthrough

1. **User is writing journal** (ModalContents slide view)
   - Sees text area with journal prompt
   - `UButton` with `UIcon="i-heroicons-camera"` visible below textarea
   - Attached images shown as thumbnail strip with `UProgress` during upload

2. **User taps camera button**
   - File picker opens (web) or action sheet with camera/gallery options (mobile)
   - Accepts: `image/jpeg`, `image/png`, `image/webp`, `image/gif`

3. **User selects/takes image**
   - Image appears in thumbnail strip with shimmer placeholder
   - `UProgress` bar (amber, `size="sm"`) shows upload progress
   - Image auto-resized to max 1920px before upload

4. **Upload completes**
   - `UProgress` fades out, full thumbnail revealed
   - User can add more images (up to 5 per slide)
   - `UButton` with `UIcon="i-heroicons-plus"` at end of strip

5. **User taps existing thumbnail**
   - Opens `UModal` lightbox (fullscreen, dark overlay)
   - Swipe between images on mobile
   - `UButton` (close, delete) overlaid

6. **User submits journal**
   - Media IDs collected per slide
   - Sent alongside journal entry data
   - Backend creates `journal_entry_media` junction records

### Flow 2: View Images on Homepage Card

1. User sees DailyCheckIn / recent entries on homepage
2. `MediaCardPreview` renders up to 2 thumbnails (64x64px)
3. If > 2 images → second thumbnail has "+N" overlay
4. No images → no change to existing card layout

### Flow 3: View Images on History Page

1. User browses history list
2. `MediaCardPreview` in history mode shows cover thumbnail (left side)
3. Text content on right side
4. Tap thumbnail → `UModal` lightbox

### Flow 4: View Images in Journal Preview

1. User opens completed journal entry
2. `MediaGrid` shows images in 2-column grid below text
3. Tap image → `UModal` lightbox
4. Swipe between images within same slide

## 🚨 Edge Cases & Error Flows

### Upload Failure
- **Scenario**: Network error during upload
- **UX**: `UIcon="i-heroicons-exclamation-triangle"` on thumbnail, `UButton` to retry
- **System**: Presigned URL expires after 15 min, user must retry

### File Too Large
- **Scenario**: Image > 10MB
- **UX**: Toast notification via `useToast()` — "Image too large (max 10MB)"
- **System**: Frontend validates before requesting presigned URL

### Unsupported Format
- **Scenario**: User selects .bmp, .tiff, etc.
- **UX**: Toast notification — "Unsupported format. Use JPEG, PNG, or WebP"
- **System**: Frontend validates file type

### Max Images Reached
- **Scenario**: 5 images already attached to slide
- **UX**: Add button hidden, "+" removed from strip
- **System**: Frontend checks count before allowing new upload

### Offline Mode — Viewing Images
- **Scenario**: User offline, viewing journal entry with previously loaded images
- **UX**: Images load from local cache via `CachedImage` component — no visual difference
- **System**: `useOfflineMedia` composable serves images from Cache API as blob:// URLs
- **Fallback**: Placeholder `image-off` icon shown for images never cached

### Offline Mode — Uploading
- **Scenario**: User offline when attempting upload
- **UX**: Toast "No internet connection"
- **System**: Queue for retry when online (future enhancement)

## 🎨 UI/UX Considerations

### Nuxt UI Components Used

| Component | Usage | Props |
|-----------|-------|-------|
| `UButton` | Add photo, delete, close, retry | `variant="ghost"`, `color="neutral"`, `size="sm"` |
| `UIcon` | Camera, plus, X, arrows, image placeholder | `name="i-heroicons-*"` |
| `UModal` | Fullscreen lightbox overlay | `v-model`, `fullscreen` on mobile |
| `UProgress` | Upload progress bar | `size="sm"`, custom amber color |

### Visual Consistency
- All media UI uses existing Zinc/Amber color palette
- Rounded corners match existing components (`rounded-lg`)
- Animations: fade-in for thumbnails, `UModal` transition for lightbox
- `prefers-reduced-motion` disables animations

### Touch Targets
- Camera `UButton`: minimum 44x44px
- Thumbnails: minimum 56x56px on mobile
- Delete `UButton`: `size="sm"` with generous padding

## 📱 Responsive Breakpoints

| Element | Mobile (<640px) | Tablet (640-1024px) | Desktop (>1024px) |
|---------|----------------|--------------------|--------------------|
| Thumbnail size | 56x56px | 72x72px | 80x80px |
| Card thumbnail | 64x64px | 80x80px | 80x80px |
| Preview grid | 2 columns | 3 columns | 3 columns |
| Camera button | 48x48px | 44x44px | 44x44px |
| Lightbox | Fullscreen | padded | padded |

## 📱 Screen Mockups

### Journal Writing (ModalContents)
```
┌─────────────────────────────────┐
│  Slide Header                    │
│  ┌───────────────────────────┐  │
│  │    Text Area / Content    │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌─── Thumbnails ───────────┐  │
│  │ [img1] [img2] [UButton+]│  │ ← horizontal scroll
│  └──────────────────────────┘  │
│  [UButton 📷 Add photo]        │ ← or inline button
└─────────────────────────────────┘
```

### Homepage Card
```
┌─────────────────────────────────┐
│  📅 Today's Check-in            │
│  "Hôm nay tôi cảm thấy..."     │
│  ┌──────┐ ┌──────┐             │
│  │ img1 │ │ img2 │  ← max 2    │
│  └──────┘ └──────┘             │
│  → Continue writing             │
└─────────────────────────────────┘
```

### History Card
```
┌─────────────────────────────────┐
│  ┌────────┐  Jan 15, 2026      │
│  │  img   │  "Hôm nay tôi..."  │
│  │ cover  │  💭 Calm  🏷️ Work  │
│  └────────┘                     │
└─────────────────────────────────┘
```

### Journal Preview (MediaGrid)
```
┌─────────────────────────────────┐
│  "What made you smile today?"   │
│  User's text response here...   │
│  ┌─────────┐ ┌─────────┐       │
│  │  img1   │ │  img2   │       │ ← 2-column grid
│  └─────────┘ └─────────┘       │
│  ┌─────────┐                   │
│  │  img3   │                   │
│  └─────────┘                   │
└─────────────────────────────────┘