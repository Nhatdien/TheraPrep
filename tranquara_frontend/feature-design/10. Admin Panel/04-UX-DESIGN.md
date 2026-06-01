# 🎨 Admin Panel - UX Design

## Overview

The admin panel uses a desktop-focused layout with a fixed sidebar, data tables, and form-based editors. It prioritizes efficiency for a single power-user (developer/owner) over visual polish.

**Design System**: Nuxt UI 3 components (dark mode compatible)

---

## 🖼️ Page Layouts

### Admin Layout (Shell)

```
┌─────────────────────────────────────────────────────────────┐
│  🛠️ TheraPrep Admin          [← Back to App]  [👤 Admin]   │
├────────────┬────────────────────────────────────────────────┤
│            │                                                │
│  SIDEBAR   │              MAIN CONTENT                      │
│            │                                                │
│  📊 Dashboard │                                             │
│  📚 Collections│                                            │
│  📦 Import/Export│                                          │
│            │                                                │
│            │                                                │
│            │                                                │
│            │                                                │
│            │                                                │
│            │                                                │
├────────────┴────────────────────────────────────────────────┤
│  Sidebar: 240px fixed │ Content: flex-1                     │
└─────────────────────────────────────────────────────────────┘
```

**Sidebar**: Fixed 240px, dark background, icon + label navigation  
**Header**: Sticky top, breadcrumb, back-to-app link  
**Content**: Full remaining width, scrollable, max-width 1400px centered

---

## 📊 Dashboard Page

```
┌─────────────────────────────────────────────────────────────┐
│  Dashboard                                                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │    12    │  │     8    │  │     4    │  │     2    │   │
│  │  Total   │  │  Active  │  │ Inactive │  │ Missing  │   │
│  │Collections│  │          │  │          │  │   VI     │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│                                                              │
│  ┌─────────────────────────┐  ┌─────────────────────────┐  │
│  │ By Type                 │  │ Quick Actions            │  │
│  │ ● Learn: 7              │  │                          │  │
│  │ ● Journal: 5            │  │  [+ New Collection]     │  │
│  │                         │  │  [📦 Import JSON]       │  │
│  │ By Category             │  │  [📤 Export All]        │  │
│  │ ● self_care: 3          │  │                          │  │
│  │ ● mental_health: 2      │  │                          │  │
│  │ ● therapy_prep: 2       │  │                          │  │
│  │ ● anxiety: 2            │  │                          │  │
│  │ ● ...                   │  │                          │  │
│  └─────────────────────────┘  └─────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Components used**: `UCard` for stat boxes, `UButton` for actions

---

## 📚 Collections List Page

```
┌─────────────────────────────────────────────────────────────┐
│  Collections                              [+ New Collection] │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Filters: [Type ▼] [Category ▼] [Status ▼]  🔍 Search...   │
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ Title          │ Type   │ Category    │ Status │ Slides ││
│  │                │        │             │        │ Count  ││
│  ├─────────────────────────────────────────────────────────┤│
│  │ Daily          │ journal│ self_care   │🟢Active│  12   ││
│  │ Reflection     │        │             │        │       ││
│  │                │        │             │        │ [⋮]   ││
│  ├─────────────────────────────────────────────────────────┤│
│  │ Therapy        │ learn  │ therapy_prep│🟢Active│   8   ││
│  │ Preparation    │        │             │        │       ││
│  │                │        │             │        │ [⋮]   ││
│  ├─────────────────────────────────────────────────────────┤│
│  │ Stress         │ learn  │ self_care   │🔴Inact.│   6   ││
│  │ Management     │        │             │        │       ││
│  │                │        │             │        │ [⋮]   ││
│  └─────────────────────────────────────────────────────────┘│
│                                                              │
│  Showing 1-10 of 12                    [← Prev] [Next →]   │
│                                                              │
└─────────────────────────────────────────────────────────────┘

Row Action Menu [⋮]:
┌──────────────────┐
│ ✏️ Edit          │
│ 👁️ Preview       │
│ 📋 Duplicate     │
│ 🔄 Toggle Active │
│ ──────────────── │
│ 🗑️ Delete        │
└──────────────────┘
```

**Components**: `UTable` (sortable columns), `USelect` (filters), `UInput` (search), `UDropdown` (row actions), `UBadge` (status)

---

## ✏️ Collection Editor Page

### Header Section

```
┌─────────────────────────────────────────────────────────────┐
│  ← Back to Collections    Edit: "Daily Reflection"          │
│                                    [Preview] [Save]         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─ Collection Details ────────────────────────────────────┐│
│  │                                                          ││
│  │  Title (EN)*         Title (VI)                         ││
│  │  ┌─────────────────┐ ┌─────────────────┐               ││
│  │  │ Daily Reflection│ │ Suy ngẫm hàng   │               ││
│  │  └─────────────────┘ └─────────────────┘               ││
│  │                                                          ││
│  │  Description (EN)    Description (VI)                   ││
│  │  ┌─────────────────┐ ┌─────────────────┐               ││
│  │  │ Simple daily... │ │ Các câu hỏi...  │               ││
│  │  └─────────────────┘ └─────────────────┘               ││
│  │                                                          ││
│  │  Type*              Category*          Active            ││
│  │  [journal ▼]       [self_care ▼]      [✓]              ││
│  │                                                          ││
│  │                          [Show Vietnamese ☐ → ☑]        ││
│  └──────────────────────────────────────────────────────────┘│
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Slide Groups Section

```
┌─────────────────────────────────────────────────────────────┐
│  Slide Groups                          [+ Add Slide Group]  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─ ⠿ Group 1: "Morning" ──────────────── [▼] [×] ───────┐│
│  │  Title: [Morning_____________]                          ││
│  │  Description: [Start your day with mindful journaling]  ││
│  │                                                          ││
│  │  Slides:                            [+ Add Slide]       ││
│  │  ┌─────────────────────────────────────────────────────┐││
│  │  │ ⠿ 1. emotion_log: "How are you feeling this..."   │││
│  │  │      [Edit] [×]                                     │││
│  │  ├─────────────────────────────────────────────────────┤││
│  │  │ ⠿ 2. sleep_check: "How many hours did you..."     │││
│  │  │      [Edit] [×]                                     │││
│  │  ├─────────────────────────────────────────────────────┤││
│  │  │ ⠿ 3. journal_prompt: "What is on my mind..."      │││
│  │  │      [Edit] [×]                                     │││
│  │  └─────────────────────────────────────────────────────┘││
│  └──────────────────────────────────────────────────────────┘│
│                                                              │
│  ┌─ ⠿ Group 2: "Evening" ──────────────── [▼] [×] ───────┐│
│  │  Title: [Evening_____________]                          ││
│  │  ...                                                    ││
│  └──────────────────────────────────────────────────────────┘│
│                                                              │
└─────────────────────────────────────────────────────────────┘

Legend:
  ⠿ = Drag handle
  [▼] = Collapse/Expand toggle
  [×] = Remove (with confirmation)
```

### Slide Editor Modal

When clicking "Edit" on a slide or "Add Slide":

```
┌─────────────────────────────────────────────────────────────┐
│  Edit Slide                                          [×]    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Slide ID: [morning-mood________]                           │
│  Type: [emotion_log ▼]                                      │
│                                                              │
│  ─── Configuration (emotion_log) ─────────────────────────  │
│                                                              │
│  Question (EN)*: [How are you feeling this morning?_____]   │
│  Question (VI):  [Bạn cảm thấy thế nào sáng nay?______]   │
│                                                              │
│  Scale: [1-10]  (fixed)                                     │
│                                                              │
│  Labels (10 required):                                      │
│  ┌────┬──────────────┬──────────────────┐                   │
│  │ 1  │ [Storm______]│ [Bão___________] │                   │
│  │ 2  │ [Heavy Rain_]│ [Mưa lớn______] │                   │
│  │ 3  │ [Rain_______]│ [Mưa___________] │                   │
│  │ 4  │ [Cloudy_____]│ [Nhiều mây_____] │                   │
│  │ 5  │ [Partly Clo.]│ [Có mây________] │                   │
│  │ ...│              │                   │                   │
│  │ 10 │ [Blissful___]│ [Hạnh phúc_____] │                   │
│  └────┴──────────────┴──────────────────┘                   │
│                                                              │
│                              [Cancel]  [Save Slide]         │
└─────────────────────────────────────────────────────────────┘
```

### Slide Type Variants

**sleep_check:**
```
│  Question*: [How many hours did you sleep?___]              │
│  Min: [0___]   Max: [12__]                                  │
```

**journal_prompt:**
```
│  Question*: [What is on my mind this morning?___]           │
│  Allow AI follow-up: [✓]                                    │
│  Minimum length: [20__] characters                          │
```

**doc (Rich Text):**
```
│  Title: [Morning Mindfulness Tip_____]                      │
│                                                              │
│  Content (EN):                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ B I U  H1 H2 H3  • ─  🔗  📷                     │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ <h3>Morning Mindfulness</h3>                        │   │
│  │ <p>Start your day by taking three deep breaths...</p>│   │
│  │                                                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  Content (VI):                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ [Tiptap editor with Vietnamese content]              │   │
│  └─────────────────────────────────────────────────────┘   │
```

**further_reading:**
```
│  Links:                                    [+ Add Link]     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 1. Title: [Understanding Mindfulness___]             │   │
│  │    URL:   [https://example.com/mindfulness]          │   │
│  │    Desc:  [A beginner's guide to... (optional)]  [×] │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ 2. Title: [CBT Basics_________________]             │   │
│  │    URL:   [https://example.com/cbt____]             │   │
│  │    Desc:  [________________________________]     [×] │   │
│  └─────────────────────────────────────────────────────┘   │
```

**cta:**
```
│  Title: [Take a Deep Breath___________]                     │
│  Description: [Pause and try this exercise___]              │
│  Action: [breathing_exercise ▼]                             │
│  Button Text: [Start Exercise___]                           │
```

---

## 📦 Import/Export Page

```
┌─────────────────────────────────────────────────────────────┐
│  Import / Export                                             │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─ Export ────────────────────────────────────────────────┐│
│  │                                                          ││
│  │  Export all collections as a JSON file for backup        ││
│  │  or transfer between environments.                       ││
│  │                                                          ││
│  │  [📤 Export All Collections]  [📤 Export Active Only]   ││
│  │                                                          ││
│  └──────────────────────────────────────────────────────────┘│
│                                                              │
│  ┌─ Import ────────────────────────────────────────────────┐│
│  │                                                          ││
│  │  ┌─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┐    ││
│  │  │                                                │    ││
│  │  │   📁 Drop JSON file here or click to browse   │    ││
│  │  │                                                │    ││
│  │  └─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘    ││
│  │                                                          ││
│  │  After upload, shows:                                    ││
│  │  ┌──────────────────────────────────────────────────┐   ││
│  │  │ ✅ Valid JSON — 5 collections found              │   ││
│  │  │                                                   │   ││
│  │  │  1. Daily Reflection (journal/self_care) — NEW   │   ││
│  │  │  2. Therapy Prep (learn/therapy_prep) — EXISTS   │   ││
│  │  │  3. Stress Mgmt (learn/self_care) — NEW          │   ││
│  │  │  ...                                              │   ││
│  │  │                                                   │   ││
│  │  │  Conflict Strategy:                               │   ││
│  │  │  ○ Skip duplicates                               │   ││
│  │  │  ○ Overwrite existing                            │   ││
│  │  │  ● Generate new IDs                              │   ││
│  │  │                                                   │   ││
│  │  │              [Cancel]  [Confirm Import]          │   ││
│  │  └──────────────────────────────────────────────────┘   ││
│  └──────────────────────────────────────────────────────────┘│
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 👁️ Preview Page

```
┌─────────────────────────────────────────────────────────────┐
│  Preview: "Daily Reflection"    [EN | VI]  [← Back to Edit] │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│         ┌─────────────────────────────┐                     │
│         │  ┌───────────────────────┐  │                     │
│         │  │                       │  │                     │
│         │  │    📱 Mobile Frame    │  │                     │
│         │  │                       │  │                     │
│         │  │  ┌─────────────────┐  │  │                     │
│         │  │  │ Morning         │  │  │                     │
│         │  │  │ Slide 1 of 4    │  │  │                     │
│         │  │  │                 │  │  │                     │
│         │  │  │ How are you     │  │  │                     │
│         │  │  │ feeling this    │  │  │                     │
│         │  │  │ morning?        │  │  │                     │
│         │  │  │                 │  │  │                     │
│         │  │  │  😢 ────●──── 😊 │  │  │                     │
│         │  │  │      7/10       │  │  │                     │
│         │  │  │                 │  │  │                     │
│         │  │  │    [Next →]     │  │  │                     │
│         │  │  └─────────────────┘  │  │                     │
│         │  │                       │  │                     │
│         │  └───────────────────────┘  │                     │
│         │                             │                     │
│         │  Chapter: [Morning ▼]       │                     │
│         └─────────────────────────────┘                     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Note**: Preview renders using the same `<Slide*>` components from `components/Slide/` used in the user-facing app. The phone frame is an optional cosmetic wrapper.

---

## 🎯 Interaction Patterns

### Drag-and-Drop

| Element | Behavior | Visual Feedback |
|---------|----------|-----------------|
| Slide Group | Drag to reorder groups | Blue highlight on drop zone, ghost element |
| Slide | Drag within group to reorder | Indent indicator, insertion line |
| Slide across groups | NOT supported (simplicity) | — |

### Validation Feedback

| Trigger | Behavior |
|---------|----------|
| Save with missing required field | Red border on field, error text below, scroll to first error |
| Invalid URL in further_reading | Red border + "Invalid URL format" |
| Labels count != 10 for emotion_log | Red text: "Exactly 10 labels required (currently: N)" |
| Empty slide_groups | Block save, show: "At least one slide group required" |

### Confirmation Dialogs

| Action | Dialog Content |
|--------|---------------|
| Delete collection | "Delete 'title'? This cannot be undone. N users have progress on this collection." |
| Remove slide group | "Remove 'group.title' and all its slides?" |
| Remove slide | "Remove this slide?" (no modal — instant with undo toast) |
| Import overwrite | "This will overwrite N existing collections. Continue?" |
| Navigate away unsaved | "You have unsaved changes. Leave anyway?" |

### Toast Notifications

| Action | Toast |
|--------|-------|
| Collection saved | ✅ "Collection saved successfully" |
| Collection created | ✅ "Collection created" |
| Collection deleted | ✅ "Collection deleted" |
| Collection duplicated | ✅ "Collection duplicated as 'title (Copy)'" |
| Toggle active | ✅ "Collection is now active/inactive" |
| Import complete | ✅ "N collections imported" |
| Validation error | ❌ "Please fix errors before saving" |
| Network error | ❌ "Failed to save. Check connection." |

---

## 🎨 Visual Design Tokens

| Element | Appearance |
|---------|-----------|
| Sidebar background | `bg-gray-900` (dark) / `bg-gray-50` (light) |
| Active nav item | `bg-primary-500/10 text-primary-500` border-left accent |
| Status badge (active) | `UBadge color="success"` — green |
| Status badge (inactive) | `UBadge color="neutral"` — gray |
| Type badge (learn) | `UBadge color="info"` — blue |
| Type badge (journal) | `UBadge color="warning"` — amber |
| Drag handle | `⠿` icon, `cursor-grab`, `text-gray-400` |
| Error state | `ring-red-500`, error text `text-red-500` |
| i18n VI column | Subtle `bg-blue-50/5` background to distinguish |

---

## 📱 Responsive Behavior

The admin panel is **desktop-first** (single admin user, power-user workflow):

| Breakpoint | Behavior |
|------------|----------|
| >= 1024px (lg) | Full sidebar + content |
| 768-1023px (md) | Collapsible sidebar (hamburger) |
| < 768px (sm) | Not optimized — show warning: "Admin best on desktop" |

---

## ♿ Accessibility

| Pattern | Implementation |
|---------|---------------|
| Keyboard reorder | Tab to drag handle, Space to grab, Arrow keys to move, Space to drop |
| Focus management | After modal close, return focus to trigger button |
| ARIA labels | Drag handles: `aria-label="Reorder item-title"` |
| Error announcements | `aria-live="polite"` on validation error region |
| Color contrast | All text meets WCAG AA (4.5:1 ratio) |

---

**Last Updated**: May 6, 2026
