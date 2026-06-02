# 🧪 Tranquara AI Service - Stress Test Suite

Bộ công cụ stress test cho `tranquara_ai_service`, bao gồm **k6** (load test chuyên nghiệp) và **Postman** (smoke test + debugging).

## 📁 Cấu trúc

```
stress-test/
├── README.md                              # File này
├── seed-data/
│   ├── seed-test-data.json                # 50 users raw data (JSON)
│   └── seed-qdrant.py                     # Script seed Qdrant vector DB
├── k6/
│   ├── config.js                          # Shared config + test data
│   ├── smoke.js                           # Kịch bản 1: 1 VU, verify
│   ├── light-load.js                      # Kịch bản 2: 10 VUs, 30s
│   ├── medium-load.js                     # Kịch bản 3: 25 VUs, 60s
│   ├── heavy-load.js                      # Kịch bản 4: 50 VUs, 120s
│   ├── spike-test.js                      # Kịch bản 5: 50 VUs burst
│   ├── sustained-load.js                  # Kịch bản 6: 10 VUs, 5 phút
│   └── run-all.bat                        # Chạy tất cả kịch bản
├── postman/
│   ├── Tranquara_Stress_Test.postman_collection.json
│   ├── Tranquara_Stress_Test.postman_environment.json
│   ├── generate-data-files.py             # Tạo CSV data files
│   └── data/                              # CSV files cho Postman Runner
│       ├── smoke-data.csv
│       ├── light-data.csv
│       ├── medium-data.csv
│       ├── heavy-data.csv
│       ├── spike-data.csv
│       └── sustained-data.csv
└── scripts/
    ├── monitor.bat                        # Giám sát hệ thống
    └── cleanup-seed-data.py               # Xóa seed data sau test
```

## 📊 Test Data

| Loại user | Số lượng | Mô tả |
|-----------|----------|-------|
| RAG users | 20 | Có past journals + memories trong Qdrant |
| No-RAG users | 15 | Không có data trước, test cold start |
| Crisis users | 5 | Nội dung khủng hoảng, test crisis detection |
| Vietnamese users | 5 | Nội dụng tiếng Việt, test multilingual |
| **Total** | **45** | |

Mỗi direction (why, emotions, patterns, challenge, growth) được phân bổ đều.

---

## 🚀 Quick Start

### Bước 1: Cài đặt k6

```bash
# Option 1: winget (Windows)
winget install k6

# Option 2: Chocolatey
choco install k6

# Verify
k6 version
```

### Bước 2: Đảm bảo services đang chạy

```bash
# Từ thư mục gốc
docker compose up -d
docker compose ps
```

Verify: `curl http://localhost:8000/healthcheck`

### Bước 3: Seed Qdrant (tạo RAG data)

```bash
cd stress-test/seed-data
pip install qdrant_client langchain-google-genai python-dotenv
python seed-qdrant.py
```

### Bước 4: Chạy k6 test

```bash
cd stress-test/k6

# Chạy 1 kịch bản
k6 run smoke.js

# Chạy với custom URL
k6 run -e AI_SERVICE_URL=http://localhost:8000 smoke.js

# Chạy + xuất JSON report
k6 run --out json=results.json smoke.js

# Chạy tất cả kịch bản
run-all.bat
```

### Bước 5: Giám sát (terminal khác)

```bash
cd stress-test/scripts
monitor.bat
```

Hoặc thủ công:
```bash
# Terminal 1: Logs
docker compose logs -f ai_service

# Terminal 2: Resources
docker stats ai_service qdrant
```

---

## 📋 6 Kịch bản Test

### Kịch bản 1: Smoke Test
- **Mục đích**: Verify endpoint hoạt động
- **VUs**: 1 | **Duration**: ~5s
- **Chạy**: `k6 run smoke.js`

### Kịch bản 2: Light Load
- **Mục đích**: Test cơ bản với 10 concurrent users
- **VUs**: 10 | **Duration**: ~35s | **Threshold**: p(95) < 30s
- **Chạy**: `k6 run light-load.js`

### Kịch bản 3: Medium Load
- **Mục đích**: Test 25 concurrent users
- **VUs**: 25 | **Duration**: ~55s | **Threshold**: p(95) < 45s
- **Chạy**: `k6 run medium-load.js`

### Kịch bản 4: Heavy Load
- **Mục đích**: Tìm bottlenecks, 50 concurrent users
- **VUs**: 50 | **Duration**: ~120s | **Threshold**: p(95) < 60s
- **Chạy**: `k6 run heavy-load.js`

### Kịch bản 5: Spike Test
- **Mục đích**: Test burst traffic, system recovery
- **VUs**: 50 (instant) | **Duration**: ~37s | **Threshold**: p(95) < 90s
- **Chạy**: `k6 run spike-test.js`

### Kịch bản 6: Sustained Load
- **Mục đích**: Test memory leaks, sustained API usage
- **VUs**: 10 | **Duration**: ~5 min | **Threshold**: p(95) < 30s
- **Chạy**: `k6 run sustained-load.js`

---

## 📮 Dùng Postman (thay thế k6)

### Import
1. Mở Postman → Import
2. Chọn `postman/Tranquara_Stress_Test.postman_collection.json`
3. Import Environment: `postman/Tranquara_Stress_Test.postman_environment.json`

### Chạy với Collection Runner
1. Mở Collection → Runner
2. Chọn request "2. Analyze Journal - Current Row"
3. Chọn data file từ `postman/data/`:
   - `smoke-data.csv` → 1 iteration
   - `light-data.csv` → 10 iterations, delay 500ms
   - `medium-data.csv` → 25 iterations, delay 200ms
   - `heavy-data.csv` → 45 iterations, delay 100ms
   - `spike-data.csv` → 45 iterations, delay 0ms
   - `sustained-data.csv` → 60 iterations, delay 5000ms
4. Click Run

### Chạy với Newman CLI
```bash
npm install -g newman
newman run postman/Tranquara_Stress_Test.postman_collection.json \
  -e postman/Tranquara_Stress_Test.postman_environment.json \
  -d postman/data/light-data.csv \
  --iteration-count 10 \
  --delay-request 500
```

---

## ⚠️ Rủi ro cần lưu ý

1. **Gemini API Rate Limits**: `gemini-2.5-flash` có giới hạn RPM. Vượt → 429 errors
2. **Single Worker**: AI service chạy `workers=1` → tất cả concurrent requests trên 1 process
3. **ThreadPoolExecutor(max_workers=3)**: Mỗi request spawn 3 threads → 50 concurrent = 150 threads
4. **k6 vs Postman**: k6 = true parallel VUs. Postman Runner = sequential only

---

## 🧹 Cleanup

```bash
# Xóa seed data từ Qdrant
python stress-test/scripts/cleanup-seed-data.py

# Hoặc xóa toàn bộ collection
curl -X DELETE http://localhost:6333/collections/journal_entries
curl -X DELETE http://localhost:6333/collections/user_memories
```

---

## 📈 Bảng Kết quả (Template)

| Kịch bản | VUs | Duration | Avg RT (ms) | P95 RT (ms) | Error % | Notes |
|----------|-----|----------|-------------|-------------|---------|-------|
| Smoke | 1 | 5s | - | - | - | |
| Light | 10 | 35s | - | - | - | |
| Medium | 25 | 55s | - | - | - | |
| Heavy | 50 | 120s | - | - | - | |
| Spike | 50 | 37s | - | - | - | |
| Sustained | 10 | 5min | - | - | - | |