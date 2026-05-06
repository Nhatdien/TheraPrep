# 05 — Admin Panel Testing Guide

Step-by-step verification of every capability added in the Admin Panel feature.

---

## Table of Contents

1. [Prerequisites & Setup](#1-prerequisites--setup)
2. [Auth & Access Control](#2-auth--access-control)
3. [Backend API (curl)](#3-backend-api-curl)
4. [Dashboard](#4-dashboard)
5. [Collections List](#5-collections-list)
6. [Collection Editor — Create](#6-collection-editor--create)
7. [Collection Editor — Edit](#7-collection-editor--edit)
8. [Collection Preview](#8-collection-preview)
9. [Import / Export](#9-import--export)
10. [End-to-End Smoke Test](#10-end-to-end-smoke-test)
11. [Edge Cases & Negative Tests](#11-edge-cases--negative-tests)

---

## 1. Prerequisites & Setup

### 1.1 Required tools
- Docker Desktop running
- Node.js 22 + yarn (for frontend hot-reload)
- `curl` + `jq` (for API tests)

### 1.2 Start the dev stack

```bash
# From workspace root
cp .env.example .env          # if not done yet
docker compose -f docker-compose.dev.yml up -d
```

### 1.3 Set admin environment variables

In `.env` (or `docker-compose.dev.yml` environment section):

```env
# Backend — comma-separated Keycloak user UUIDs
ADMIN_USERS=<your-keycloak-user-uuid>

# Frontend — same list, read by nuxt.config.ts
NUXT_PUBLIC_ADMIN_USERS=<your-keycloak-user-uuid>
```

> **How to find your UUID**: Log in and call `GET /v1/users/profile`, or decode your JWT at [jwt.io](https://jwt.io) and copy the `sub` claim.

### 1.4 Obtain a JWT for API testing

```bash
# Replace with actual Keycloak credentials
TOKEN=$(curl -s -X POST \
  "http://localhost:8080/realms/tranquara_auth/protocol/openid-connect/token" \
  -d "grant_type=password" \
  -d "client_id=tranquara_app" \
  -d "username=<your-username>" \
  -d "password=<your-password>" \
  | jq -r '.access_token')

echo $TOKEN   # should be a long JWT string
```

---

## 2. Auth & Access Control

### 2.1 Backend — non-admin JWT gets 403

```bash
# Use a JWT for a non-admin user
curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $NON_ADMIN_TOKEN" \
  http://localhost:4000/v1/admin/templates
# Expected: 403
```

### 2.2 Backend — admin JWT gets 200

```bash
curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $TOKEN" \
  http://localhost:4000/v1/admin/templates
# Expected: 200
```

### 2.3 Backend — missing ADMIN_USERS env var returns 403

Temporarily unset `ADMIN_USERS` on the core service container and replay the request.  
Expected: `403 Forbidden` even for a valid JWT.

### 2.4 Frontend — non-admin redirect

1. Log in as a non-admin user.
2. Navigate to `http://localhost:3000/admin`.
3. Expected: redirected to `/` (home page).

### 2.5 Frontend — admin page loads

1. Log in as the admin user (UUID in `NUXT_PUBLIC_ADMIN_USERS`).
2. Navigate to `http://localhost:3000/admin`.
3. Expected: Admin dashboard renders with sidebar navigation (Collections, Import/Export).

### 2.6 Frontend — direct URL guard

1. Log out first.
2. Manually type `http://localhost:3000/admin/collections` in the browser.
3. Expected: redirected to `/login` (or `/`), not a blank/broken page.

---

## 3. Backend API (curl)

All examples use `$TOKEN` set in section 1.4.

### 3.1 List templates

```bash
curl -s \
  -H "Authorization: Bearer $TOKEN" \
  http://localhost:4000/v1/admin/templates | jq .
```

**Expected:**
```json
{
  "templates": [...] // array, may be empty if no seed data
}
```

### 3.2 Create template

```bash
curl -s -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Collection EN",
    "title_vi": "Bộ sưu tập thử nghiệm",
    "description": "A test collection",
    "description_vi": "Một bộ sưu tập thử nghiệm",
    "category": "anxiety",
    "type": "journal",
    "slide_groups": [
      {
        "id": "grp-1",
        "title": "Intro",
        "order": 1,
        "slides": [
          {
            "id": "slide-1",
            "type": "journal_prompt",
            "order": 1,
            "config": {
              "question": "How are you feeling?",
              "allow_ai": true,
              "min_length": 50
            }
          }
        ]
      }
    ],
    "slide_groups_vi": null,
    "is_active": true
  }' \
  http://localhost:4000/v1/admin/templates | jq .
```

**Expected:** `201 Created` with the full template object including a generated `id` UUID.

> Save `TEMPLATE_ID` from the response for subsequent steps:
> ```bash
> TEMPLATE_ID=$(... | jq -r '.template.id')
> ```

### 3.3 Get single template

```bash
curl -s \
  -H "Authorization: Bearer $TOKEN" \
  http://localhost:4000/v1/admin/templates/$TEMPLATE_ID | jq .
```

**Expected:** The template object created in 3.2.

### 3.4 Update template

```bash
curl -s -X PUT \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated Title", "category": "stress", "type": "journal", "is_active": true}' \
  http://localhost:4000/v1/admin/templates/$TEMPLATE_ID | jq .
```

**Expected:** Updated template with `title: "Updated Title"` and `category: "stress"`.

### 3.5 Toggle active status

```bash
curl -s -X PATCH \
  -H "Authorization: Bearer $TOKEN" \
  http://localhost:4000/v1/admin/templates/$TEMPLATE_ID/toggle-active | jq .
```

**Expected:** Template returned with `is_active` flipped from previous value. Run twice to confirm round-trip.

### 3.6 Duplicate template

```bash
curl -s -X POST \
  -H "Authorization: Bearer $TOKEN" \
  http://localhost:4000/v1/admin/templates/$TEMPLATE_ID/duplicate | jq .
```

**Expected:** New template with identical content, different UUID, title prefixed with `"Copy of "`.

> Save `DUPLICATE_ID` for the delete test.

### 3.7 Delete template

```bash
curl -s -X DELETE \
  -H "Authorization: Bearer $TOKEN" \
  http://localhost:4000/v1/admin/templates/$DUPLICATE_ID | jq .
# Expected: 200 or 204, duplicate gone
```

Verify it's gone:
```bash
curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $TOKEN" \
  http://localhost:4000/v1/admin/templates/$DUPLICATE_ID
# Expected: 404
```

### 3.8 Export templates

```bash
curl -s \
  -H "Authorization: Bearer $TOKEN" \
  http://localhost:4000/v1/admin/templates-export | jq . > /tmp/templates_export.json
cat /tmp/templates_export.json | jq 'keys'
# Expected: ["exported_at", "templates", "version"]
```

### 3.9 Import templates

Edit `/tmp/templates_export.json` — change one title to something unique. Then:

```bash
curl -s -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"templates\": $(jq '.templates' /tmp/templates_export.json), \"conflict_strategy\": \"skip\"}" \
  http://localhost:4000/v1/admin/templates-import | jq .
# Expected: {"imported": N, "skipped": N, "errors": []}
```

Repeat with `"conflict_strategy": "overwrite"` and `"replace_all"` to verify all three modes.

### 3.10 Validation errors

```bash
# Missing required field: title
curl -s -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"category": "anxiety", "type": "journal"}' \
  http://localhost:4000/v1/admin/templates | jq .error
# Expected: "title is required"

# Invalid type
curl -s -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "X", "category": "anxiety", "type": "invalid"}' \
  http://localhost:4000/v1/admin/templates | jq .error
# Expected: "type must be 'learn' or 'journal'"
```

---

## 4. Dashboard

Navigate to `http://localhost:3000/admin`.

| Check | Expected |
|-------|----------|
| Page loads without console errors | ✅ |
| Stats cards appear (Total, Active, Inactive, Categories) | Numbers match DB state |
| Category breakdown list renders | Each category shows count |
| "Manage Collections" button navigates to `/admin/collections` | ✅ |
| "Export All" quick action triggers file download | JSON file with all templates |

---

## 5. Collections List

Navigate to `http://localhost:3000/admin/collections`.

### 5.1 Table renders
- All templates created in section 3 appear in the table.
- Columns: Title, Category, Type, Status (Active badge), Slides count, Created At, Actions.

### 5.2 Search filter
1. Type part of the test collection title in the search box.
2. Expected: list narrows to matching results in real time.
3. Clear the input — full list returns.

### 5.3 Category filter
1. Select "anxiety" from the category dropdown.
2. Expected: only collections with `category = "anxiety"` shown.

### 5.4 Type filter
1. Select "journal" — only journal-type visible.
2. Select "learn" — only learn-type visible.
3. Select "All" — all visible.

### 5.5 Row action — Edit
Click **Edit** on a collection → navigates to `/admin/collections/<id>` (editor).

### 5.6 Row action — Duplicate
Click **Duplicate** → success toast → new `Copy of …` entry appears in the list.

### 5.7 Row action — Toggle Active
1. Note current badge colour on a row.
2. Click **Deactivate** (or **Activate**).
3. Expected: badge flips immediately without page reload.

### 5.8 Row action — Delete
1. Click **Delete** on the duplicated row.
2. Confirm the modal.
3. Expected: row removed, success toast shown.

### 5.9 New Collection button
Click **+ New Collection** → navigates to `/admin/collections/new`.

---

## 6. Collection Editor — Create

Navigate to `http://localhost:3000/admin/collections/new`.

### 6.1 Required field validation
Click **Save** without filling anything.  
Expected: error toast / validation highlighting on Title and Category fields.

### 6.2 Fill metadata
| Field | Value |
|-------|-------|
| Title (EN) | `My Test Collection` |
| Title (VI) | `Bộ sưu tập của tôi` |
| Description (EN) | `Description in English` |
| Description (VI) | `Mô tả bằng tiếng Việt` |
| Category | `anxiety` |
| Type | `journal` |
| Active | toggle ON |

### 6.3 Add a slide group
1. Click **+ Add Group**.
2. Edit the group title to `"Group 1"`.
3. Expected: group card appears in the editor.

### 6.4 Add one slide of each type

For each slide type below, click **+ Add Slide** inside the group and select the type:

| Slide type | Config to fill | Expected component |
|------------|---------------|-------------------|
| `journal_prompt` | Question: "How do you feel?", Allow AI: on | `AdminSlideJournalPrompt` |
| `emotion_log` | Labels: ["Happy", "Sad", "Angry", "Fear", "Calm", "Curious", "Joy", "Disgust", "Shame", "Surprise"] | `AdminSlideEmotionLog` |
| `sleep_check` | Min: 0, Max: 12 | `AdminSlideSleepCheck` |
| `doc` | HTML: `<p>Hello world</p>` — verify live preview updates | `AdminSlideDoc` |
| `further_reading` | Add 2 links (title + URL + description) | `AdminSlideFurtherReading` |
| `cta` | Action: `complete`, Button text: "Done!" | `AdminSlideCta` |

### 6.5 Drag-and-drop slides
1. Grab a slide by its drag handle (≡ icon).
2. Drag it to a different position within the group.
3. Release — order updates visually.

### 6.6 Drag-and-drop groups
1. Grab a group header by its handle.
2. Drag it above/below another group.
3. Release — order updates.

### 6.7 Delete a slide
Click the **Delete** (trash) icon on one slide.  
Expected: slide removed, group slide count decreases.

### 6.8 EN/VI language toggle
1. Switch to **VI** tab in the editor.
2. Expected: labels/inputs switch to Vietnamese variant.
3. Edit a prompt in VI mode.
4. Switch back to **EN** — EN content unchanged.

### 6.9 Save
Click **Save Collection**.  
Expected: success toast, redirect to `/admin/collections/<new-id>` (edit mode).

---

## 7. Collection Editor — Edit

Open an existing collection via the Collections list → Edit.

### 7.1 Data loads correctly
- All field values match what was saved in section 6.
- All slide groups and slides are present.
- VI content populated where entered.

### 7.2 Edit and save
1. Change the description.
2. Add a new slide group.
3. Click **Save**.
4. Expected: success toast, data persists on next reload.

### 7.3 Cancel navigation
Click browser Back or the "Back" button without saving a change.  
Expected: either a confirmation dialog or unsaved changes are discarded gracefully (no broken state).

---

## 8. Collection Preview

From the editor, click **Preview**, or navigate directly to `/admin/collections/preview/<id>`.

### 8.1 Phone frame renders
- A mobile-style frame appears showing the first slide.

### 8.2 Slide navigation
- Click **Next** — advances to the next slide.
- Click **Back** — returns to previous slide.
- All slides in all groups are reachable.

### 8.3 Language toggle
1. Toggle to **VI**.
2. Expected: slide content switches to Vietnamese text.
3. Toggle back to **EN** — English text restored.

### 8.4 Inactive template
Set a collection to inactive (toggle in editor or via API).  
Open its preview — preview should still work (admin can preview inactive content).

---

## 9. Import / Export

Navigate to `http://localhost:3000/admin/import-export`.

### 9.1 Export

1. Click **Export All Templates**.
2. Expected: JSON file downloads named `tranquara-templates-<date>.json`.
3. Open the file and verify structure:
```json
{
  "version": "1.0",
  "exported_at": "<ISO timestamp>",
  "templates": [...]
}
```

### 9.2 Import — skip strategy

1. Take the exported file.
2. Drag-and-drop (or select) it in the import drop zone.
3. Expected: file validates, preview summary appears (N templates detected).
4. Select **Skip** strategy.
5. Click **Import**.
6. Expected: toast showing `Imported: 0, Skipped: N` (all already exist).

### 9.3 Import — overwrite strategy

1. Manually edit the JSON file — change one template's `title` to `"Overwritten Title"`.
2. Re-import with **Overwrite** strategy.
3. Expected: `Imported: 1, Skipped: N-1` (or similar).
4. Go to Collections list — verify the modified title now shows `"Overwritten Title"`.

### 9.4 Import — replace all strategy

> ⚠️ This deletes all existing templates. Use with care — use a test environment.

1. Export fresh backup first.
2. Import a file with 2 templates using **Replace All**.
3. Expected: Collections list now shows exactly those 2 templates.
4. Re-import the full backup to restore.

### 9.5 Invalid file rejection

1. Try to import a plain `.txt` file or malformed JSON.
2. Expected: validation error displayed, import button stays disabled.

### 9.6 Missing fields rejection

Import a JSON file where one template has `title: ""`.  
Expected: import response shows that template in the `errors` array, others succeed.

---

## 10. End-to-End Smoke Test

This verifies the full pipeline: admin creates → active content → user-facing API.

```
Admin creates collection (active=true)
        ↓
Template saved in PostgreSQL journal_templates table
        ↓
User-facing endpoint returns it in the gallery
```

### Steps

1. Create a new collection in the admin UI with `is_active = true`.
2. Note the template `id` from the URL (`/admin/collections/<id>`).
3. Use a **non-admin** user token and call the user-facing template gallery:

```bash
curl -s \
  -H "Authorization: Bearer $USER_TOKEN" \
  http://localhost:4000/v1/template-gallary | jq '.templates[] | select(.id == "<template-id>")'
```

4. Expected: the newly created template appears in the user gallery response.

5. Deactivate the template (toggle in admin UI).
6. Repeat the user-facing call.
7. Expected: template no longer appears in the gallery (inactive templates excluded from user view).

---

## 11. Edge Cases & Negative Tests

| Scenario | Steps | Expected |
|----------|-------|----------|
| Delete non-existent template | `DELETE /v1/admin/templates/<random-uuid>` | `404 Not Found` |
| Get non-existent template | `GET /v1/admin/templates/<random-uuid>` | `404 Not Found` |
| Invalid UUID in URL | `GET /v1/admin/templates/not-a-uuid` | `400 Bad Request` |
| Empty ADMIN_USERS on backend | Remove env var, restart core service, make admin API call | `403 Forbidden` |
| Admin UUID not in list | Set `ADMIN_USERS` to a different UUID | `403 Forbidden` |
| Expired JWT | Wait for token expiry (or set `exp` in past) and call API | `401 Unauthorized` |
| slide_groups with invalid JSON | POST with `"slide_groups": "not-json"` | `400 Bad Request` or `422` |
| Import with unknown conflict_strategy | `"conflict_strategy": "destroy"` | `400 Bad Request` |
| Frontend admin route without auth | Open `/admin/collections` in incognito | Redirect to login |
| Very large collection (50+ slides) | Create via API, open editor | Editor loads without freezing |

---

## Checklist Summary

| Section | Pass | Notes |
|---------|------|-------|
| 2. Auth & Access Control | ☐ | |
| 3. Backend API | ☐ | |
| 4. Dashboard | ☐ | |
| 5. Collections List | ☐ | |
| 6. Editor — Create | ☐ | |
| 7. Editor — Edit | ☐ | |
| 8. Preview | ☐ | |
| 9. Import / Export | ☐ | |
| 10. End-to-End | ☐ | |
| 11. Edge Cases | ☐ | |
