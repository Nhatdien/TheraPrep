# 🛠️ Admin Panel - Overview

## 🎯 Purpose

Provide a visual content management interface for the platform owner to create, edit, and manage library collections (micro-learning lessons and journal templates) without writing SQL migrations. Replaces the current developer-only workflow of hand-writing SQL seed files for every content change.

## 📊 Status

- **Current Status**: 🔄 In Progress
- **Priority**: Medium
- **Target Release**: v1.2
- **Dependencies**:
  - Existing `journal_templates` table (already in production)
  - Keycloak authentication (already working)
  - Tiptap editor (already integrated for journaling)
  - Nuxt UI 3 components (already available)

## 🎨 User Value

- **Rapid content iteration**: Add or update lessons in minutes, not deployment cycles
- **Visual editing**: See content structure while building (not raw JSON)
- **Error reduction**: Form validation prevents malformed content
- **Bilingual management**: Side-by-side EN/VI editing with clear visual separation
- **Safe experimentation**: Toggle collections inactive instead of deleting
- **Content portability**: Import/export for backup, migration, or sharing

## 🔑 Key Features

### Core Management
- **Collections List**: Table view with search, filters (type/category/status), bulk actions
- **CRUD Operations**: Create, read, update, delete collections
- **Duplicate**: Clone existing collections as starting point for new content
- **Toggle Active**: Show/hide collections from user library without data loss
- **Import/Export**: Bulk JSON operations for content migration

### Visual Slide Builder
- **Drag-and-Drop**: Reorder slide groups and individual slides
- **Type-Specific Editors**: Custom form for each of 6 slide types
- **Inline Validation**: Real-time error feedback on required fields
- **Add/Remove**: Dynamically add or remove slide groups and slides

### Internationalization
- **Side-by-Side Editing**: EN column | VI column layout
- **Independent Fields**: title_vi, description_vi, slide_groups_vi
- **Preview per Language**: Switch preview between EN and VI

### Content Preview
- **Separate Preview Page**: Renders collection exactly as users see it
- **Reuses Existing Components**: Same `<Slide*>` components from learn_and_prepare
- **Language Toggle**: Preview in EN or VI

## 📋 Success Criteria

- [ ] Admin can create a new collection with all slide types in < 5 minutes
- [ ] Existing collections editable without data loss
- [ ] Non-admin users cannot access `/admin` routes (403 + redirect)
- [ ] Preview renders identically to user-facing library pages
- [ ] Import/Export produces valid JSON that round-trips correctly
- [ ] Vietnamese translations display correctly when locale is set
- [ ] Collections toggled inactive disappear from user gallery immediately
- [ ] Drag-and-drop reorder persists after save

## 🔗 Related Features

- **[Micro Learning](../03.%20Micro%20learning/)** - Educational content (type='learn') managed here
- **[Journaling](../02.%20Jounral%20Feature/)** - Journal templates (type='journal') managed here
- **[Database Schema](../00-DATABASE/)** - `journal_templates` table definition

## 📝 Notes

### Design Decisions

1. **Why Inside the Existing App (Not Separate Admin App)?**
   - Only one admin user (developer/owner) — no need for dedicated infrastructure
   - Reuses existing auth, layout, and component systems
   - Faster to build (no separate deployment pipeline)
   - Can reuse Slide rendering components directly for preview
   - Hidden behind middleware — invisible to regular users

2. **Why Hardcoded Admin Check (Not Keycloak Roles)?**
   - Only one admin user — role-based access control is overkill
   - Avoids Keycloak configuration complexity
   - Simple env var (`ADMIN_USERS=uuid1,uuid2`) is easy to change
   - Can upgrade to role-based later if needed
   - Both frontend middleware and backend middleware validate

3. **Why Visual Slide Builder (Not JSON Editor)?**
   - Content creator UX even for developer — faster than writing JSONB
   - Prevents JSON syntax errors
   - Form validation catches missing required fields
   - Drag-and-drop makes reordering intuitive
   - Each slide type has different `config` schema — forms encode this knowledge

4. **Why Side-by-Side i18n (Not Separate Tabs)?**
   - Context: can see EN content while writing VI translation
   - Ensures parity — easy to spot missing translations
   - Matches the dual-field DB schema (title/title_vi, description/description_vi)
   - More efficient than switching tabs for each field

5. **Why Soft-Delete (Toggle Active) Instead of Hard Delete?**
   - Users may have `user_learned_slide_groups` records referencing the collection
   - Allows restoring accidentally "deleted" content
   - Hard delete available but with confirmation modal
   - Backend already filters by `is_active = true` for user-facing endpoints

6. **Why Import/Export JSON?**
   - Backup before destructive operations
   - Share content between environments (dev → prod)
   - Enables batch content creation in external tools
   - Debugging — can inspect raw content structure

### Content Creation Workflow (Before vs After)

**Before (Current):**
```
Write SQL → Test locally → Create migration file → Deploy → Run migration
If error: Write another migration to fix → Deploy again
```

**After (With Admin Panel):**
```
Open /admin → Click "New Collection" → Fill form → Add slides → Save
If error: Edit inline → Save again
```

### Metrics to Track

**Admin Usage:**
- Collections created/edited per week
- Average time to create a collection
- Most commonly used slide types

**Content Health:**
- Total active vs inactive collections
- Collections missing Vietnamese translations
- Average slides per collection

---

**Last Updated**: May 6, 2026
