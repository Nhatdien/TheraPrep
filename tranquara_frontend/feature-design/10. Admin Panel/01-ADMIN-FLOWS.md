# 🔄 Admin Panel - User Flows

## Overview

All admin flows are available only to authenticated users whose UUID matches the `ADMIN_USERS` environment variable. Regular users are redirected away.

---

## Flow A: Access Admin Panel

```mermaid
flowchart TD
    A[User navigates to /admin] --> B{Is authenticated?}
    B -->|No| C[Redirect to /login]
    B -->|Yes| D{UUID in ADMIN_USERS?}
    D -->|No| E[Redirect to / with toast: Access Denied]
    D -->|Yes| F[Show Admin Dashboard]
    F --> G[Display stats: total collections, active/inactive, by type]
    F --> H[Quick actions: New Collection, Import]
```

**Result**: Admin sees dashboard with content overview and quick actions.

---

## Flow B: Browse & Search Collections

```mermaid
flowchart TD
    A[Admin on Dashboard] --> B[Click Collections in sidebar]
    B --> C[Show collections table]
    C --> D{Apply filters?}
    D -->|Type filter| E[Filter: learn / journal / all]
    D -->|Category filter| F[Filter by category dropdown]
    D -->|Status filter| G[Filter: active / inactive / all]
    D -->|Search| H[Search by title substring]
    D -->|No filters| I[Show all collections]
    E --> I
    F --> I
    G --> I
    H --> I
    I --> J[Table: Title - Type - Category - Status - Slides - Updated - Actions]
```

**Result**: Admin sees filtered list of all collections with action buttons per row.

---

## Flow C: Create New Collection

```mermaid
flowchart TD
    A[Click New Collection] --> B[Open editor page /admin/collections/new]
    B --> C[Fill header: title, description, category, type]
    C --> D[Toggle i18n mode for EN/VI side-by-side]
    D --> E[Add first slide group]
    E --> F[Set slide group: title, description, position]
    F --> G[Add slides to group]
    G --> H{Select slide type}
    H -->|emotion_log| I[Configure: scale, labels array]
    H -->|sleep_check| J[Configure: min, max]
    H -->|journal_prompt| K[Configure: question, allowAI, minLength]
    H -->|doc| L[Tiptap editor: write HTML content]
    H -->|further_reading| M[Add link list: title + URL]
    H -->|cta| N[Configure: button text, action]
    I & J & K & L & M & N --> O{Add more slides?}
    O -->|Yes| G
    O -->|No| P{Add more slide groups?}
    P -->|Yes| E
    P -->|No| Q[Click Save]
    Q --> R{Validation passes?}
    R -->|No| S[Show inline errors, focus first error]
    R -->|Yes| T[POST /v1/admin/templates - 201 Created]
    T --> U[Redirect to collections list with success toast]
```

**Result**: New collection created and immediately available in user library (if active).

---

## Flow D: Edit Existing Collection

```mermaid
flowchart TD
    A[Click Edit on collection row] --> B[Open /admin/collections/:id]
    B --> C[Load collection data via GET /v1/admin/templates/:id]
    C --> D[Populate form with existing data]
    D --> E[Admin makes changes]
    E --> F[Drag-and-drop reorder slides/groups]
    E --> G[Edit slide content]
    E --> H[Add/remove slides or groups]
    F & G & H --> I[Click Save]
    I --> J[PUT /v1/admin/templates/:id]
    J --> K{Success?}
    K -->|Yes| L[Show success toast, stay on page]
    K -->|No| M[Show error message]
```

**Result**: Collection updated. Changes reflected immediately for users.

---

## Flow E: Preview Collection

```mermaid
flowchart TD
    A[In editor, click Preview] --> B[Open /admin/collections/preview/:id]
    B --> C[Render collection using user-facing Slide components]
    C --> D{Select language}
    D -->|English| E[Show slide_groups content]
    D -->|Vietnamese| F[Show slide_groups_vi content]
    E & F --> G[Navigate through slides like a user would]
    G --> H[Click Back to Editor to return]
```

**Result**: Admin sees exactly how content appears to users.

---

## Flow F: Duplicate Collection

```mermaid
flowchart TD
    A[Click Duplicate on collection row] --> B[POST /v1/admin/templates/:id/duplicate]
    B --> C[Backend creates copy with new UUID]
    C --> D[Title becomes Original Title - Copy]
    D --> E[New collection appears in list]
    E --> F[Admin can edit the copy]
```

**Result**: New copy of collection ready for customization.

---

## Flow G: Toggle Active/Inactive

```mermaid
flowchart TD
    A[Click toggle switch on collection row] --> B[PATCH /v1/admin/templates/:id/toggle-active]
    B --> C{Was active?}
    C -->|Yes - Now inactive| D[Hidden from user gallery]
    C -->|No - Now active| E[Visible in user gallery]
    D & E --> F[Update table row status badge]
```

**Result**: Collection visibility changed instantly.

---

## Flow H: Delete Collection

```mermaid
flowchart TD
    A[Click Delete on collection row] --> B[Show confirmation modal]
    B --> C{Has user_learned records?}
    C -->|Yes| D[Warning: X users have progress on this collection]
    C -->|No| E[Simple confirm: Delete Title?]
    D & E --> F{User confirms?}
    F -->|No| G[Close modal, no action]
    F -->|Yes| H[DELETE /v1/admin/templates/:id]
    H --> I[Remove from table, show success toast]
```

**Result**: Collection permanently deleted (with warning about user impact).

---

## Flow I: Export Collections

```mermaid
flowchart TD
    A[Click Export button] --> B{Export scope}
    B -->|All| C[GET /v1/admin/templates/export]
    B -->|Selected| D[POST /v1/admin/templates/export with IDs]
    C & D --> E[Receive JSON file]
    E --> F[Browser downloads collections.json]
```

**Result**: JSON file downloaded containing all collection data.

---

## Flow J: Import Collections

```mermaid
flowchart TD
    A[Click Import button] --> B[File picker opens]
    B --> C[Select .json file]
    C --> D[Parse and validate JSON structure]
    D --> E{Valid format?}
    E -->|No| F[Show validation errors]
    E -->|Yes| G[Preview: show collection titles + counts]
    G --> H{Conflict with existing IDs?}
    H -->|Yes| I[Option: Skip duplicates / Overwrite / Generate new IDs]
    H -->|No| J[Show import summary]
    I --> J
    J --> K[Click Confirm Import]
    K --> L[POST /v1/admin/templates/import]
    L --> M[Show results: X created, Y skipped, Z errors]
```

**Result**: Collections imported from JSON file into database.

---

## Flow Summary

| Flow | Trigger | Endpoint | Result |
|------|---------|----------|--------|
| A. Access | Navigate to /admin | — | Dashboard or redirect |
| B. Browse | Click Collections | GET /v1/admin/templates | Filtered table |
| C. Create | Click New | POST /v1/admin/templates | New collection |
| D. Edit | Click Edit row | PUT /v1/admin/templates/:id | Updated collection |
| E. Preview | Click Preview | GET /v1/admin/templates/:id | Visual preview |
| F. Duplicate | Click Duplicate | POST /v1/admin/templates/:id/duplicate | Cloned collection |
| G. Toggle | Click toggle | PATCH /v1/admin/templates/:id/toggle-active | Visibility changed |
| H. Delete | Click Delete | DELETE /v1/admin/templates/:id | Permanently removed |
| I. Export | Click Export | GET /v1/admin/templates/export | JSON file download |
| J. Import | Click Import | POST /v1/admin/templates/import | Bulk creation |

---

**Last Updated**: May 6, 2026
