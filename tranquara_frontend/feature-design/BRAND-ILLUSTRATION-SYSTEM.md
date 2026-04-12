# Plan: Tranquara Brand Illustration System
> **Status**: ✅ COMPLETE — All 7 phases implemented + additional items

## Design Decisions
- **Personality**: Warm & Nurturing — amber warmth, safe, cozy
- **Illustration style**: Flat color shapes, bold silhouettes
- **Palette**: 3 colors max — amber (`#F59E0B`), white (`#FFFFFF`), dark background (`#18181b` zinc-900)
- **Brand mark**: Abstract leaf/petal geometry grown from rectangles
- **Collection card**: Portrait card — illustration top half, text/progress bottom half
- **Slide content**: Per-slide illustrations via `illustration` field — content-descriptive, not every slide
- **Completion screen**: Brand mark + CSS particle confetti
- **Home hero**: Subtle CSS particle/wave animation (no JS library)
- **Icons**: Custom SVG Vue components for tab bar icons
- **Implementation**: Inline Vue SVG components, AI-generated + cleaned SVGs

---

## Phase 1: Brand Identity System ✅

### 1.1 — Brand Mark SVG Component ✅
- **Created** `components/Brand/LogoMark.vue` — abstract leaf/petal (5 rotated rounded rects converging at center)
  - Props: `size`, `color` (default: amber `#F59E0B`), `variant: 'full' | 'mark'`
- **Replaced** `assets/img/logo.svg` with new brand mark geometry
- **Wired** into `layouts/auth.vue` (login/register), `components/Common/SidebarNavigation.vue`, `pages/profile/index.vue` footer

### 1.2 — Illustration Color Tokens ✅
- **Updated** `tailwind.config.js` with `illus: { amber: '#F59E0B', cream: '#FEF3C7', dark: '#18181b' }`

---

## Phase 2: Collection Illustration Components ✅

### 2.1 — Individual Illustration SVGs ✅
All 10 created in `components/Illustrations/`:
| Component | Status |
|-----------|--------|
| `IlluJournaling.vue` | ✅ |
| `IlluSleep.vue` | ✅ |
| `IlluAnxiety.vue` | ✅ |
| `IlluMindfulness.vue` | ✅ |
| `IlluBrain.vue` | ✅ |
| `IlluTherapy.vue` | ✅ |
| `IlluDaily.vue` | ✅ |
| `IlluBreathing.vue` | ✅ |
| `IlluProgress.vue` | ✅ |
| `IlluFallback.vue` | ✅ |

### 2.2 — Illustration Resolver ✅
- **Created** `components/Illustrations/index.ts` — `getIllustrationComponent(text)` keyword fuzzy matcher

---

## Phase 3: Collection Card Redesign ✅

### 3.1 — Portrait Card Component ✅
- **Created** `components/Learn/CollectionCard.vue` — dark-bg illustration tile (top) + title/chapters/progress (bottom)

### 3.2 — Library Page Updates ✅
- **Modified** `pages/learn_and_prepare/index.vue` — 2-col portrait grid + illustration-backed featured tiles
- **Modified** `pages/learn_and_prepare/collections.vue` — both Learn and Journal sections use `CollectionCard`

### 3.3 — Collection Detail Header ✅
- **Modified** `components/Journal/TemplateListV2.vue` — full-width illustration banner at top (uses `getIllustrationComponent` from collection category/title)

---

## Phase 4: Per-Slide Illustrations ✅

### 4.1 — Per-Slide Illustration Support ✅
- **Modified** `components/Journal/ModalContents.vue` — illustration band rendered when slide has `illustration` field
  - Any slide type (`doc`, `journal_prompt`, etc.) can have an optional `illustration` keyword string
  - Keyword resolved via `getIllustrationComponent()` (same keyword-matching system as collection cards)
  - No illustration = no band (clean text-only slide)
  - Works for both Learn and Toolkit slide groups
  - **Removed** previous "hero on first slide always" behavior — illustrations are now content-descriptive, placed on slides where they add value

**Slide data example:**
```json
{
  "type": "doc",
  "illustration": "adhd focus",
  "header": "ADHD Challenges",
  "body": "<p>ADHD can impact your behavior...</p>"
}
```

**Available illustration keywords:** `sleep`, `adhd/brain/focus`, `breathing/grounding`, `anxiety/stress`, `mindfulness/meditation`, `therapy/relationship`, `daily/routine`, `progress/growth`, `journal/reflect`

---

## Phase 5: Completion Screen ✅

### 5.1 — CompletionSlide Redesign ✅
- **Modified** `components/Slide/CompletionSlide.vue`
  - `BrandLogoMark` (80px) centered
  - 18 CSS `@keyframes rise-fade` particles (amber + white, staggered delays)
  - `prefers-reduced-motion` disables animation
  - Preserved `recommendedNext` logic

---

## Phase 6: Home Hero Animation ✅

### 6.1 — DailyCheckIn Animated Background ✅
- **Modified** `components/HomePage/DailyCheckIn.vue`
  - 5 CSS orbs with `@keyframes orb-drift` (amber, blurred, slow drift)
  - `prefers-reduced-motion` disables animation
  - All existing check-in content preserved

---

## Phase 7: Custom Tab Bar Icons ✅

### 7.1 — Icon SVG Components ✅
All 6 created in `components/Icons/` (plus 9 additional for toolkit/profile):

**Navigation Icons:**
| Component | Usage |
|-----------|-------|
| `IconToday.vue` | Home tab (journal page + dot) |
| `IconInspirations.vue` | Toolkit tab (heart hands) |
| `IconLibrary.vue` | Library tab (book + leaf mark) |
| `IconHistory.vue` | History tab (calendar + arc) |
| `IconProgress.vue` | Progress tab (ascending bars) |
| `IconProfile.vue` | Profile link (person silhouette) |

**Toolkit Grounding Icons:**
| Component | Usage |
|-----------|-------|
| `IconBreathing.vue` | Breathing exercise |
| `IconFiveSenses.vue` | 5-senses grounding |
| `IconBodyScan.vue` | Body scan exercise |
| `IconAffirmations.vue` | Affirmations |
| `IconQuickJournal.vue` | Quick journal / sidebar new-journal button |

**Profile Settings Icons:**
| Component | Usage |
|-----------|-------|
| `IconPalette.vue` | Theme/personalize |
| `IconPersonCircle.vue` | About you |
| `IconBell.vue` | Notifications |
| `IconDatabase.vue` | Your data |

### 7.2 — Navigation Update ✅
- **Modified** `components/Common/navIcons.ts` — custom `IconToday/Inspirations/Library/History` wired; `active` prop passed through
- **Modified** `components/Common/BottomNavigation.vue` — amber `text-[#F59E0B]` active state
- **Modified** `components/Common/SidebarNavigation.vue` — brand mark logo, `IconProfile` for profile link, amber active state, `active` prop forwarded to all icons
- **Modified** `pages/toolkit/index.vue` — grounding tools use custom icons
- **Modified** `pages/profile/index.vue` — settings nav items use custom icons

---

## Verification Checklist
- [x] `npm run dev` — no TypeScript errors
- [x] Auth layout — brand mark displayed on login/register
- [x] Library page — collection cards render in 2-col portrait grid
- [x] Collection detail — full-width illustration banner at top
- [x] Slidegroup — slides with `illustration` field show contextual illustration; others are text-only
- [x] Completion screen — brand mark + floating amber/white particles
- [x] Home page — ambient CSS orbs animate in background of check-in card
- [x] Tab bar (mobile) — custom icons, amber fill on active
- [x] Sidebar (desktop) — brand mark logo, amber highlight on active
- [x] Toolkit grounding — 5 custom icons
- [x] Profile settings — 4 custom icons
- [x] `prefers-reduced-motion` — CompletionSlide particles + DailyCheckIn orbs both disable

## Files Changed / Created
| File | Action |
|------|--------|
| `tailwind.config.js` | Modified — illus color tokens |
| `assets/img/logo.svg` | Replaced — new brand mark SVG |
| `components/Brand/LogoMark.vue` | Created |
| `components/Illustrations/*.vue` (×10) | Created |
| `components/Illustrations/index.ts` | Created |
| `components/Learn/CollectionCard.vue` | Created |
| `components/Icons/*.vue` (×15) | Created |
| `components/Common/navIcons.ts` | Modified |
| `components/Common/BottomNavigation.vue` | Modified |
| `components/Common/SidebarNavigation.vue` | Modified |
| `components/Journal/ModalContents.vue` | Modified |
| `components/Journal/TemplateListV2.vue` | Modified |
| `components/Slide/CompletionSlide.vue` | Modified |
| `components/HomePage/DailyCheckIn.vue` | Modified |
| `layouts/auth.vue` | Modified |
| `pages/learn_and_prepare/index.vue` | Modified |
| `pages/learn_and_prepare/collections.vue` | Modified |
| `pages/toolkit/index.vue` | Modified |
| `pages/profile/index.vue` | Modified |
