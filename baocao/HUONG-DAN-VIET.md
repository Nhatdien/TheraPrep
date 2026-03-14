# HƯỚNG DẪN VIẾT BÁO CÁO THERAPREP

> Tài liệu này hướng dẫn cách viết từng phần của báo cáo dựa trên nội dung trong feature-design

---

## 🎯 Nguyên tắc chung

1. **Dựa vào tài liệu có sẵn**: Sử dụng nội dung từ `feature-design/` làm nguồn chính
2. **Trích dẫn code thực tế**: Lấy ví dụ code từ các service
3. **Thêm hình ảnh**: Sử dụng diagrams, screenshots có sẵn
4. **Giải thích kỹ thuật**: Giải thích why và how, không chỉ what
5. **Cập nhật liên tục**: Đồng bộ với tiến độ phát triển thực tế

---

## 📚 Hướng dẫn viết từng chương

### CHƯƠNG 1: Tổng quan

#### 1.1. Giới thiệu về sức khỏe tâm thần
**Nguồn tham khảo**:
- WHO mental health statistics
- Mental health apps market research
- Psychology and therapy fundamentals

**Nội dung cần có**:
- Tình trạng sức khỏe tâm thần toàn cầu và Việt Nam
- Rào cản trong việc tiếp cận trị liệu (chi phí, stigma, thiếu nguồn lực)
- Vai trò của công nghệ trong mental wellness

#### 1.2. Khảo sát ứng dụng hiện có
**So sánh với**:
- Day One (journaling)
- Headspace, Calm (meditation)
- Sanvello (CBT-based)
- Woebot (AI chatbot)

**Tham khảo từ**: `feature-design/Project documentation.md`

#### 1.3-1.5. Công nghệ
**Nguồn**: 
- `.github/copilot-instructions.md` → Tech stack
- `feature-design/README.md` → Architecture
- Documentation của từng công nghệ

**Nội dung viết**:
- NLP basics và ứng dụng trong emotion analysis
- RAG (Retrieval-Augmented Generation) architecture
- Microservices vs Monolithic
- Giới thiệu từng technology trong stack

---

### CHƯƠNG 2: Phân tích và Thiết kế

#### 2.1. Phân tích yêu cầu

**Nguồn chính**:
```
feature-design/
├── 01. User register/00-OVERVIEW.md          → Auth requirements
├── 02. Journal Feature/00-OVERVIEW.md        → Journal requirements
├── 03. Micro learning/00-OVERVIEW.md         → Learning requirements
├── 06. User profile and Settings/00-OVERVIEW.md → Settings requirements
└── 07. Progress/00-OVERVIEW.md               → Progress requirements
```

**Template viết**:
```markdown
#### 2.1.1. Yêu cầu chức năng

##### Tính năng Đăng ký và Xác thực
- **Mô tả**: [Từ 01. User register/00-OVERVIEW.md]
- **Use cases**:
  - Người dùng đăng ký tài khoản
  - Người dùng đăng nhập
  - Quản lý session và token
- **Actors**: Guest User, Registered User, System
```

#### 2.2. Thiết kế kiến trúc

**Nguồn**: 
- `feature-design/README.md` → Architecture section
- `.github/copilot-instructions.md` → Architecture patterns

**Nội dung viết**:
1. **Sơ đồ kiến trúc tổng thể**: Vẽ diagram 3 services
2. **Giải thích từng service**:
   - Frontend: Nuxt 3 SPA với Capacitor
   - Core Service: Golang REST API
   - AI Service: Python FastAPI + LangChain
3. **Communication patterns**:
   - REST API cho sync calls
   - RabbitMQ cho async tasks
   - WebSocket cho real-time chat

#### 2.3. Thiết kế Database

**Nguồn chính**:
```
feature-design/00-DATABASE/
├── SCHEMA_OVERVIEW.md       → Tổng quan schema
└── database-design-v2.md    → Chi tiết bảng
```

**Từng feature**:
```
feature-design/
├── 01. User register/03-DATA-MODELS.md
├── 02. Journal Feature/03-DATA-MODELS.md
├── 03. Micro learning/03-DATA-MODELS.md
└── 07. Progress/03-DATA-MODELS.md
```

**Template viết**:
```markdown
#### 2.3.1. Bảng Users và User Information

**Schema**:
```sql
[Copy từ 00-DATABASE/database-design-v2.md]
```

**Mô tả các trường**:
- `uuid`: Primary key, UUID v4
- `username`: Unique, không null
- `email`: Unique, có thể null
[...]

**Relationships**:
- One-to-One với user_informations
- One-to-Many với user_journals
```

#### 2.4. Thiết kế UI/UX

**Nguồn**:
- `feature-design/theraprep_user_journey_flow.png`
- Các file `01-*-FLOW.md` trong từng feature folder

**Nội dung**:
1. **User Journey Map**: Giải thích flow chart
2. **Wireframes**: Mô tả từng màn hình
3. **Design principles**: Offline-first, simplicity, privacy

---

### CHƯƠNG 3: Cài đặt các tính năng

> Đây là chương quan trọng nhất, viết chi tiết implementation

#### Template cho mỗi tính năng:

```markdown
### 3.X. Triển khai tính năng [Feature Name]

#### 3.X.1. Kiến trúc tính năng
[Sơ đồ component/module architecture]

#### 3.X.2. Frontend Implementation

**File structure**:
```
tranquara_frontend/
├── pages/[feature]/
├── components/[feature]/
└── stores/stores/[feature]/
```

**Key components**:
1. [Component 1]: [Mô tả + code snippet]
2. [Component 2]: [Mô tả + code snippet]

**State management** (Pinia store):
[Code example từ stores/]

#### 3.X.3. Backend Implementation

**API Endpoints**:
- POST /api/v1/[endpoint] - [Mô tả]
- GET /api/v1/[endpoint] - [Mô tả]

**Handler code**:
[Code từ tranquara_core_service/cmd/api/handlers.go]

**Database operations**:
[Code từ tranquara_core_service/internal/data/]

#### 3.X.4. AI Integration (nếu có)

**LangChain chain**:
[Code từ tranquara_ai_service/service/ai_service_processor.py]

**Vector operations**:
[Code từ tranquara_ai_service/database/vector_database.py]

#### 3.X.5. Data flow
[Sequence diagram: User → Frontend → Backend → AI Service → Database]

#### 3.X.6. Offline handling
[Giải thích local storage strategy]
```

#### Ví dụ cụ thể: Auth Feature

**Nguồn tài liệu**:
```
feature-design/01. User register/
├── 00-OVERVIEW.md           → Tổng quan
├── 01-LOGIN-FLOW.md         → Login flow chi tiết
├── 02-ONBOARDING-FLOW.md    → Onboarding flow
├── 03-DATA-MODELS.md        → Database models
└── IMPLEMENTATION-GUIDE.md  → Step-by-step implementation
```

**Cấu trúc viết**:

```markdown
### 3.1. Triển khai tính năng Đăng ký và Xác thực

#### 3.1.1. Kiến trúc Authentication

**Authentication flow**:
[Diagram: User → Frontend → Keycloak → Backend]

**Components**:
- Keycloak server (OAuth 2.0 provider)
- KeycloakService singleton (Frontend)
- JWT middleware (Backend)
- Token storage (SecureStorage)

#### 3.1.2. Cấu hình Keycloak

**Realm setup**:
- Realm name: `tranquara_auth`
- Client ID: `tranquara-frontend`
- Redirect URIs: [...]

[Copy từ IMPLEMENTATION-GUIDE.md]

#### 3.1.3. Frontend: KeycloakService

**File**: `stores/auth/keycloak_service.ts`

```typescript
[Copy code relevant code]
```

**Giải thích**:
- Singleton pattern để ensure 1 instance duy nhất
- initKeycloak() khởi tạo Keycloak client
- login(), logout(), refresh token methods
- onAuthSuccess callback để update SDK token

#### 3.1.4. Backend: JWT Validation

**File**: `cmd/api/middleware.go`

```go
[Copy middleware code]
```

**Giải thích**:
- Parse JWT từ Authorization header
- Validate signature với publicKey.pem
- Extract user claims (username, UUID, email)

#### 3.1.5. Token Refresh Strategy

**Auto-refresh mechanism**:
[Giải thích logic refresh mỗi 10s]

**Code**: `plugins/tranquaraSDK.client.ts`
```typescript
[Copy refresh interval code]
```

#### 3.1.6. Offline Authentication

**Strategy**:
- Online: Keycloak token required
- Offline: Local SQLite + optional PIN
- Biometric authentication (iOS/Android)

[Chi tiết implementation]
```

---

### CHƯƠNG 4: Kết quả và Đánh giá

#### 4.1. Kết quả triển khai

**Checklist tính năng**:
```markdown
| Feature | Status | Completion % |
|---------|--------|--------------|
| User Registration | ✅ Done | 100% |
| Login/Logout | ✅ Done | 100% |
| Token Management | ✅ Done | 100% |
| Journal Entry | 🔄 In Progress | 70% |
| AI Chat | 🔄 In Progress | 60% |
| Micro Learning | 🧠 Planned | 0% |
[...]
```

#### 4.2. Test Cases

**Nguồn**: Viết test cases dựa trên user flows

**Template**:
```markdown
##### Test Case: TC-AUTH-001 - User Registration

**Mô tả**: Kiểm tra user có thể đăng ký tài khoản mới

**Preconditions**:
- App đã được cài đặt
- Không có tài khoản nào được đăng nhập

**Steps**:
1. Mở app, nhấn "Register"
2. Nhập username: "testuser123"
3. Nhập password: "Test@1234"
4. Nhập email: "test@example.com"
5. Nhấn "Create Account"

**Expected Result**:
- Hiển thị màn hình onboarding
- Backend tạo user record trong database
- Keycloak tạo user trong realm

**Actual Result**: [Pass/Fail]
```

#### 4.3. Performance Testing

**Metrics cần đo**:
- API response time (target: < 200ms)
- App cold start time (target: < 3s)
- Memory usage (target: < 150MB)
- Battery drain (target: < 5%/hour active use)
- Database query time

**Tools**:
- Postman/Thunder Client (API testing)
- Chrome DevTools (web performance)
- Xcode Instruments (iOS profiling)
- Android Profiler (Android profiling)

#### 4.4. Security Testing

**Checklist**:
- [ ] Token expiration handling
- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] Secure storage of sensitive data
- [ ] HTTPS enforcement
- [ ] Input validation

---

## 🎨 Formatting Guidelines

### Code Blocks

**Đúng**:
````markdown
```typescript
// File: stores/auth/keycloak_service.ts
export class KeycloakService {
  private static instance: KeycloakService | null = null;
  
  static getInstance(): KeycloakService {
    if (!KeycloakService.instance) {
      KeycloakService.instance = new KeycloakService();
    }
    return KeycloakService.instance;
  }
}
```
````

### Diagrams

Sử dụng:
- Mermaid syntax (if supported)
- Draw.io exported PNG
- Screenshots từ feature-design/

### Tables

```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data 1   | Data 2   | Data 3   |
```

### Citations

```markdown
Theo nghiên cứu của WHO[1], ...

[1] World Health Organization. (2023). Mental Health Statistics.
```

---

## 📁 File Structure cho Báo Cáo

```
baocao/
├── README.md                    # Tổng quan
├── MUC-LUC.md                   # Mục lục chi tiết
├── HUONG-DAN-VIET.md            # File này
│
├── CHUONG-1-TONG-QUAN/
│   ├── 1.1-gioi-thieu.md
│   ├── 1.2-khao-sat-ung-dung.md
│   ├── 1.3-nlp-ai.md
│   ├── 1.4-microservices.md
│   └── 1.5-cong-nghe.md
│
├── CHUONG-2-PHAN-TICH-THIET-KE/
│   ├── 2.1-phan-tich-yeu-cau.md
│   ├── 2.2-thiet-ke-kien-truc.md
│   ├── 2.3-thiet-ke-database.md
│   └── 2.4-thiet-ke-ui-ux.md
│
├── CHUONG-3-CAI-DAT/
│   ├── 3.1-auth-feature.md
│   ├── 3.2-journal-feature.md
│   ├── 3.3-learning-feature.md
│   ├── 3.4-progress-feature.md
│   ├── 3.5-settings-feature.md
│   ├── 3.6-ai-service.md
│   └── 3.7-data-sync.md
│
├── CHUONG-4-KET-QUA/
│   ├── 4.1-ket-qua.md
│   ├── 4.2-testing.md
│   ├── 4.3-danh-gia.md
│   └── 4.4-user-feedback.md
│
├── KET-LUAN.md
├── TAI-LIEU-THAM-KHAO.md
│
└── images/                      # Screenshots, diagrams
    ├── architecture/
    ├── ui-screenshots/
    ├── flowcharts/
    └── test-results/
```

---

## ✅ Checklist trước khi hoàn thành báo cáo

### Nội dung
- [ ] Tất cả các tính năng đã implemented đều được document
- [ ] Code examples có giải thích rõ ràng
- [ ] Diagrams đầy đủ và dễ hiểu
- [ ] Test cases đầy đủ cho các tính năng chính
- [ ] Performance metrics được đo và ghi nhận
- [ ] Security considerations được đề cập

### Format
- [ ] Mục lục đầy đủ và có page numbers
- [ ] Hình ảnh có caption và reference
- [ ] Code blocks có syntax highlighting
- [ ] Tables được format đúng
- [ ] Citations đầy đủ

### Kỹ thuật
- [ ] Giải thích architecture patterns
- [ ] Database schema có ER diagrams
- [ ] API endpoints được document
- [ ] Authentication flow rõ ràng
- [ ] Offline-first strategy được giải thích

### Language
- [ ] Thuật ngữ tiếng Anh có giải thích tiếng Việt
- [ ] Câu văn rõ ràng, không dài dòng
- [ ] Tránh lỗi chính tả
- [ ] Formatting nhất quán

---

## 📞 Tips và Best Practices

### 1. Viết dễ hiểu
- Giải thích **why** trước **how**
- Dùng ví dụ cụ thể
- Tránh jargon không cần thiết

### 2. Code examples
- Show, don't tell
- Comment code quan trọng
- Highlight key lines

### 3. Visual aids
- 1 diagram > 1000 words
- Screenshots có annotations
- Use consistent styling

### 4. Testing
- Show both pass và fail cases
- Include edge cases
- Document known issues

### 5. Updates
- Keep sync với codebase
- Version control cho documents
- Date các thay đổi quan trọng

---

*Tài liệu này sẽ được cập nhật liên tục theo tiến độ dự án*
