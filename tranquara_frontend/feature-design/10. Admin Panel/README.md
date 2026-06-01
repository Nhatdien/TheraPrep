# 🛠️ Admin Panel - Content Management

> Visual admin interface for managing library collections (learn + journal templates) with drag-and-drop slide builder

---

## 📑 Core Documentation

| File | Description |
|------|-------------|
| **[00-OVERVIEW.md](./00-OVERVIEW.md)** | Feature purpose, user value, and design decisions |
| **[01-ADMIN-FLOWS.md](./01-ADMIN-FLOWS.md)** | Admin user journeys with Mermaid diagrams |
| **[02-TECHNICAL-SPEC.md](./02-TECHNICAL-SPEC.md)** | Architecture, admin auth, API design, frontend structure |
| **[03-DATA-MODELS.md](./03-DATA-MODELS.md)** | API schemas, request/response models |
| **[04-UX-DESIGN.md](./04-UX-DESIGN.md)** | Wireframes, component layout, interaction patterns |

---

## 🎯 Quick Summary

**Status**: 🔄 In Progress  
**Priority**: Medium  
**Target**: v1.2

### What This Feature Does

Admin (developer/owner) gets:
- **Collections CRUD**: Create, edit, delete, duplicate library collections
- **Visual Slide Builder**: Drag-and-drop editor for all 6 slide types
- **Side-by-side i18n**: Edit English and Vietnamese content simultaneously
- **Preview Mode**: See how content renders in the user-facing app
- **Import/Export**: Bulk JSON import/export for content backup and migration
- **Active/Inactive Toggle**: Control collection visibility without deletion

### Technology

- **Auth**: Hardcoded admin UUID check (env var `ADMIN_USERS`)
- **Backend**: Go REST API with admin middleware wrapper
- **Frontend**: Nuxt 3 pages at `/admin/*` with dedicated layout
- **Editor**: Tiptap (existing dep) for rich HTML content in `doc` slides
- **Drag-and-drop**: `sortablejs` (direct usage, already installed)

---

## 🔗 Related Features

- **[Micro Learning](../03.%20Micro%20learning/)** - Content managed by this admin panel
- **[Journaling](../02.%20Jounral%20Feature/)** - Journal templates also managed here
- **[Database Schema](../00-DATABASE/)** - `journal_templates` table

---

## 🚀 Implementation Status

**Feature Checklist:**
- [x] Backend admin middleware (UUID check)
- [x] Backend CRUD API endpoints
- [x] Frontend admin middleware + layout
- [x] Admin SDK mixin + Pinia store
- [x] Collections list page (table + filters)
- [x] Collection editor page (visual builder)
- [x] Slide type editors (7 components including generic fallback)
- [x] Drag-and-drop reordering (sortablejs)
- [x] Side-by-side EN/VI editing
- [x] Preview mode
- [x] Import/Export functionality
- [x] Duplicate collection
- [x] Toggle active/inactive

---

**Last Updated**: May 6, 2026
