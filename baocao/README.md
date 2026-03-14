# 📚 Báo Cáo Dự Án TheraPrep

Thư mục này chứa tài liệu báo cáo đồ án cho dự án **TheraPrep** - Nền tảng hỗ trợ sức khỏe tâm thần với AI.

## 📋 Nội dung

### Tài liệu chính
- **[MUC-LUC.md](./MUC-LUC.md)** - Mục lục chi tiết toàn bộ báo cáo

## 🎯 Tổng quan dự án

**TheraPrep** là một ứng dụng di động cross-platform (iOS/Android/Web) giúp người dùng:
- ✍️ Viết nhật ký cảm xúc với sự hỗ trợ của AI
- 📚 Học các bài học micro-learning về tâm lý học
- 📊 Theo dõi tiến trình và phân tích cảm xúc
- 🎯 Chuẩn bị cho các buổi trị liệu

## 🏗️ Kiến trúc hệ thống

### Microservices Monorepo
```
tranquara_frontend/      → Ứng dụng Nuxt 3 + Capacitor
tranquara_core_service/  → Backend Go REST API
tranquara_ai_service/    → AI Service Python FastAPI
```

### Công nghệ sử dụng
- **Frontend**: Nuxt 3, Vue 3, Capacitor, Pinia, TailwindCSS, Nuxt UI
- **Backend**: Golang, PostgreSQL, RabbitMQ, Redis, Keycloak
- **AI/ML**: Python FastAPI, LangChain, Qdrant Vector DB, HuggingFace
- **Auth**: Keycloak (OAuth 2.0 / OpenID Connect)

## 📖 Cấu trúc báo cáo

### Chương 1: Tổng quan
- Giới thiệu về sức khỏe tâm thần và công nghệ
- Khảo sát các ứng dụng hiện có
- Tìm hiểu công nghệ NLP và AI
- Kiến trúc Microservices
- Các công cụ và ngôn ngữ sử dụng

### Chương 2: Phân tích và Thiết kế
- Phân tích yêu cầu hệ thống
- Thiết kế kiến trúc tổng thể
- Thiết kế cơ sở dữ liệu
- Thiết kế giao diện người dùng

### Chương 3: Cài đặt các tính năng
- Đăng ký và xác thực (Keycloak + OAuth 2.0)
- Emotion Journaling với AI
- Micro Learning
- Progress Tracking
- Profile và Settings
- AI Service (LangChain + Qdrant)
- Data Synchronization (Offline-first)

### Chương 4: Kết quả và Đánh giá
- Kết quả triển khai
- Thực nghiệm và kiểm thử
- Đánh giá so sánh với các ứng dụng tương tự
- Phản hồi người dùng

## 🔗 Tham khảo

### Tài liệu thiết kế chi tiết
Xem thư mục [`../tranquara_frontend/feature-design/`](../tranquara_frontend/feature-design/) để biết thêm chi tiết về:
- User flows và use cases
- Database schema
- API documentation
- Technical specifications

### Tài liệu kỹ thuật chính
- [Nuxt 3 Documentation](https://nuxt.com/docs)
- [Capacitor Documentation](https://capacitorjs.com/docs)
- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [LangChain Documentation](https://python.langchain.com/)
- [Qdrant Documentation](https://qdrant.tech/documentation/)

## 📝 Lưu ý khi viết báo cáo

1. **Sử dụng tài liệu feature-design**: Tất cả các tính năng đều có tài liệu chi tiết trong thư mục feature-design
2. **Tham khảo code thực tế**: Code trong các service là nguồn tham khảo tốt nhất
3. **Cập nhật liên tục**: Báo cáo nên được cập nhật khi có thay đổi trong dự án
4. **Thêm hình ảnh**: Sử dụng screenshots, diagrams từ feature-design
5. **Liên kết tài liệu**: Tham chiếu đến các file markdown trong feature-design

## 🎨 Template và Ví dụ

### Cách viết một phần trong báo cáo
```markdown
### 3.X. Triển khai tính năng [Tên Feature]

#### 3.X.1. Tổng quan
[Mô tả tính năng - tham khảo từ 00-OVERVIEW.md]

#### 3.X.2. Luồng người dùng
[Mô tả user flow - tham khảo từ 01-*-FLOW.md]

#### 3.X.3. Cài đặt kỹ thuật
[Chi tiết implementation - tham khảo từ 02-TECHNICAL-SPEC.md]

#### 3.X.4. Mô hình dữ liệu
[Database schema - tham khảo từ 03-DATA-MODELS.md]

#### 3.X.5. Code chính
[Code snippets và giải thích]

#### 3.X.6. Kết quả
[Screenshots và demo]
```

## 📞 Liên hệ

Nếu cần hỗ trợ về nội dung báo cáo, vui lòng tham khảo:
- Tài liệu trong `feature-design/`
- File `feature-design/README.md` để biết cấu trúc dự án
- File `.github/copilot-instructions.md` để hiểu conventions

---

*Mục lục được tạo tự động dựa trên tài liệu thiết kế trong feature-design/*
