# 11. Data Import/Export — Overview

## 🎯 Purpose

Cho phép người dùng **xuất toàn bộ dữ liệu cá nhân** (journals, emotion logs, learning progress, v.v.) ra file JSON và **nhập lại** khi cần — phục vụ backup, chuyển thiết bị, hoặc tuân thủ quyền riêng tư (GDPR data portability).

## 📊 Status

- **Current Status**: 🧠 Planned
- **Priority**: Medium
- **Target Release**: v1.2
- **Dependencies**: User Authentication, existing data models

## 🎨 User Value

- **Backup an toàn**: Người dùng tự chủ backup dữ liệu, không lo mất khi đổi điện thoại
- **Data portability**: Tuân thủ GDPR, người dùng có quyền lấy dữ liệu của mình
- **Migration**: Chuyển dữ liệu giữa tài khoản / thiết bị dễ dàng
- **Transparency**: Xem rõ tất cả dữ liệu mà hệ thống lưu trữ về mình

## 🔑 Key Features

### Phase 1 — Export Data (MVP)
1. **GET `/v1/data-export`** — Backend endpoint xuất toàn bộ dữ liệu user
2. **Frontend UI** — "Export Data" button trong Settings → Your Data page
3. **JSON download** — File `tranquara-export-{date}.json` chứa tất cả user data
4. **Loading/progress** — Hiển thị trạng thái đang chuẩn bị file

### Phase 2 — Import Data
5. **POST `/v1/data-import`** — Backend endpoint nhập dữ liệu từ file JSON
6. **Frontend UI** — Upload file component với validation
7. **Conflict resolution** — Skip existing hoặc overwrite (user chọn)
8. **Import summary** — Hiển thị số record đã import cho mỗi loại

### Phase 3 — Enhanced (Future)
9. **Selective export** — Chọn loại dữ liệu cụ thể để xuất
10. **PDF export** — Xuất journals dạng readable PDF
11. **Scheduled auto-backup** — Tự động backup định kỳ

## 📋 Success Criteria

- [ ] User có thể export toàn bộ dữ liệu trong < 10 giây (cho ~1000 records)
- [ ] Export JSON có cấu trúc rõ ràng, versioned
- [ ] Import validate file structure, reject malformed files
- [ ] Import không ghi đè dữ liệu existing trừ khi user chọn overwrite
- [ ] Export/import hoạt động trên cả web và mobile (Capacitor)
- [ ] Loading states và error handling đầy đủ

## 🔗 Related Features

- [User Profile & Settings](../06.%20User%20profile%20and%20Settings/) — UI host cho data management
- [Journal Feature](../02.%20Jounral%20Feature/) — Main data source for export
- [Therapy Toolkit](../09.%20Therapy%20Toolkit/) — Sessions & homework data

## 📝 Notes

- Export file format cần **versioned** để forward-compatible
- Import phải handle **old format** gracefully
- Large exports (> 10MB) cần streaming hoặc pagination
- Cần encrypt sensitive data trong export file (optional, future)

---

## 📂 Implementation Scope

### Files to Create/Modify

| File | Action | Description |
|------|--------|-------------|
| **Backend (Go)** | | |
| `internal/data/data_export.go` | Create | Data export model + queries |
| `internal/data/data_import.go` | Create | Data import model + queries |
| `cmd/api/handlers/data_portability.go` | Create | Export/import HTTP handlers |
| `cmd/api/router.go` | Modify | Add `/v1/data-export`, `/v1/data-import` routes |
| **Frontend (Vue/Nuxt)** | | |
| `composables/useDataExport.ts` | Create | Export composable |
| `composables/useDataImport.ts` | Create | Import composable |
| `components/Settings/DataManagementSection.vue` | Modify | Wire real export/import |
| `pages/profile/your-data.vue` | Create (optional) | Dedicated data page |
| `i18n/locales/en.json` | Modify | Add export/import keys |
| `i18n/locales/vi.json` | Modify | Add export/import keys |