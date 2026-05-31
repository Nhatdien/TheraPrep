# Media Upload - Production Setup Guide

> Step-by-step guide to deploy the Media Upload feature to production

---

## 📋 Prerequisites Checklist

- [ ] Cloudflare account with R2 access
- [ ] Production PostgreSQL database running
- [ ] Core Service (Go backend) deployed
- [ ] Frontend (Nuxt 3) deployed
- [ ] Domain with HTTPS configured

---

## 1. Cloudflare R2 Setup

### 1.1 Create R2 Bucket

1. Go to **Cloudflare Dashboard → R2 Object Storage**
2. Click **Create bucket**
3. Name: `tranquara-media` (or your preferred name)
4. Location: Choose closest to your users (e.g., APAC)

### 1.2 Create R2 API Token

1. Go to **R2 → Manage R2 API Tokens**
2. Click **Create API token**
3. Permissions: **Object Read & Write**
4. Specify bucket: `tranquara-media`
5. Copy the values:
   - **Access Key ID** → `R2_ACCESS_KEY_ID`
   - **Secret Access Key** → `R2_SECRET_ACCESS_KEY`

### 1.3 Configure Public Access (Custom Domain)

**Option A: Custom Domain (Recommended)**
1. Go to **R2 → tranquara-media bucket → Settings**
2. Under **Custom Domain**, click **Connect Domain**
3. Enter: `cdn.tranquara.com` (or your media subdomain)
4. Cloudflare auto-configures DNS + SSL

**Option B: R2 Public Dev URL (Development only)**
1. Go to **R2 → tranquara-media bucket → Settings**
2. Under **Public Dev URL**, click **Allow Access**
3. Copy the generated URL (e.g., `https://pub-xxx.r2.dev`)

> ⚠️ **Production must use Option A** — the dev URL has no SLA and is rate-limited.

### 1.4 Configure CORS for R2 Bucket

The frontend uploads directly to R2 via presigned URLs. You need CORS configured:

```json
[
  {
    "AllowedOrigins": ["https://your-production-domain.com"],
    "AllowedMethods": ["PUT", "GET"],
    "AllowedHeaders": ["Content-Type"],
    "MaxAgeSeconds": 3600
  }
]
```

**How to apply:**
1. Go to **R2 → tranquara-media bucket → Settings**
2. Under **CORS Policy**, paste the JSON above
3. Replace `your-production-domain.com` with your actual domain

---

## 2. Environment Variables

### 2.1 Backend (Core Service - Go)

Add these to your production environment (Docker Compose `.env`, Azure Container Apps, etc.):

```env
# Cloudflare R2 Configuration
R2_ACCOUNT_ID=your_cloudflare_account_id
R2_ACCESS_KEY_ID=your_r2_access_key_id
R2_SECRET_ACCESS_KEY=your_r2_secret_access_key
R2_BUCKET_NAME=tranquara-media
R2_PUBLIC_URL=https://cdn.tranquara.com
```

**How to find your Account ID:**
- Cloudflare Dashboard → any domain → right sidebar → **Account ID**

### 2.2 CORS Update

Add your production frontend URL to `ALLOWED_ORIGINS`:

```env
ALLOWED_ORIGINS=https://your-production-domain.com
```

### 2.3 Frontend

No additional frontend env vars needed — the frontend gets presigned URLs from the backend API.

---

## 3. Database Migration

### 3.1 Run Migration

Migration `000040_create_media_upload.up.sql` creates two tables:
- `media_files` — uploaded file metadata + R2 references
- `journal_entry_media` — junction table linking media to journal slides

**Run against production PostgreSQL:**

```bash
# Option A: Using migration tool (if you use golang-migrate)
migrate -path migrations -database "postgres://user:pass@host:5432/tranquara_core?sslmode=require" up

# Option B: Direct psql
psql -h your-db-host -U postgres -d tranquara_core -f migrations/000040_create_media_upload.up.sql
```

### 3.2 Verify Migration

```sql
-- Check tables exist
SELECT tablename FROM pg_tables WHERE tablename IN ('media_files', 'journal_entry_media');

-- Check indexes
SELECT indexname FROM pg_indexes WHERE tablename = 'media_files';
SELECT indexname FROM pg_indexes WHERE tablename = 'journal_entry_media';
```

Expected output:
```
media_files
journal_entry_media

idx_media_files_user_id
idx_media_files_upload_status
idx_media_files_r2_key
idx_jem_journal_entry_id
idx_jem_media_file_id
```

---

## 4. Deployment Steps

### 4.1 Deploy Backend

```bash
# Build and deploy core service (includes media handlers)
cd tranquara_core_service
docker build -t tranquara-core:latest .
docker push your-registry/tranquara-core:latest
# Deploy to your platform (Docker Compose / Azure / etc.)
```

The media API routes are auto-registered in `cmd/api/router.go`:
- `POST /api/v1/media/presign`
- `POST /api/v1/media/{id}/confirm`
- `GET /api/v1/media/{id}`
- `DELETE /api/v1/media/{id}`
- `GET /api/v1/media/journal/{journalEntryId}`
- `POST /api/v1/media/attach`

### 4.2 Deploy Frontend

```bash
# Build and deploy frontend (includes media components + offline caching)
cd tranquara_frontend
yarn build
# Deploy dist/ or Docker image to your platform
```

### 4.3 Verify Deployment

```bash
# Test presign endpoint (requires auth token)
curl -X POST https://api.your-domain.com/api/v1/media/presign \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"filename":"test.jpg","content_type":"image/jpeg","size_bytes":1000}'
```

---

## 5. Production Security Checklist

- [ ] R2 API token has **minimum permissions** (only the media bucket, not all R2)
- [ ] R2 public URL uses **HTTPS** (Cloudflare auto-provisions SSL)
- [ ] Presigned URLs expire in **15 minutes** (hardcoded in `r2_storage.go`)
- [ ] `ALLOWED_ORIGINS` only includes production domain (not `*`)
- [ ] R2 CORS only allows your production domain
- [ ] Max file size enforced: **10MB** (frontend + backend validation)
- [ ] Allowed file types: `image/jpeg`, `image/png`, `image/webp`, `image/gif`
- [ ] User isolation: R2 keys include `users/{user_id}/` path prefix

---

## 6. Monitoring & Costs

### Cloudflare R2 Free Tier
- **Storage**: 10 GB/month free
- **Class A operations** (write): 1 million/month free
- **Class B operations** (read): 10 million/month free
- **No egress fees** (images served without bandwidth cost)

### Estimated Costs at Scale
| Users | Storage | Monthly Cost |
|-------|---------|-------------|
| 100 | ~2 GB | **Free** |
| 1,000 | ~20 GB | ~$0.36/mo |
| 10,000 | ~200 GB | ~$3.60/mo |

### Monitoring
- **Cloudflare Dashboard → R2** — storage usage, request counts, error rates
- **Application logs** — monitor presign failures, upload errors
- **Database** — monitor `media_files` table growth

---

## 7. Rollback Plan

If issues arise in production:

### Rollback Database
```bash
psql -h your-db-host -U postgres -d tranquara_core -f migrations/000040_create_media_upload.down.sql
```

### Rollback Backend
```bash
# Deploy previous version
docker pull your-registry/tranquara-core:previous-version
# Redeploy
```

### R2 Cleanup
```bash
# If needed, delete all media files for a user
# Use Cloudflare R2 API or dashboard
```

> **Note**: Rollback drops `media_files` and `journal_entry_media` tables. Any uploaded images remain in R2 but lose DB references. Clean up R2 separately if needed.

---

**Last Updated**: May 31, 2026