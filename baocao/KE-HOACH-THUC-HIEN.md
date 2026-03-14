# IV. KẾ HOẠCH THỰC HIỆN

## Giai đoạn 1: Thiết kế & Lập kế hoạch (01/12/2025 - 22/12/2025)

| STT | Thời gian | Nội dung thực hiện | Kết quả dự kiến |
|-----|-----------|-------------------|----------------|
| 1 | 01/12/2025<br>- 22/12/2025 | - Phân tích yêu cầu hệ thống TheraPrep<br>- Thiết kế kiến trúc microservices (Frontend Nuxt 3, Backend Go, AI Service Python)<br>- Thiết kế database schema (PostgreSQL, Qdrant)<br>- Lập kế hoạch tích hợp Keycloak authentication<br>- Thiết kế UI/UX wireframes cho các màn hình chính | - Tài liệu phân tích yêu cầu hoàn chỉnh<br>- Sơ đồ kiến trúc hệ thống<br>- Database schema design<br>- Wireframes & user flows<br><br>**Viết word chương 1** |

## Giai đoạn 2: Hạ tầng & Authentication (23/12/2025 - 22/01/2026)

| STT | Thời gian | Nội dung thực hiện | Kết quả dự kiến |
|-----|-----------|-------------------|----------------|
| 2 | 23/12/2025<br>- 08/01/2026 | - Cài đặt môi trường phát triển (Docker, RabbitMQ, Redis)<br>- Triển khai Keycloak server & cấu hình realm<br>- Xây dựng backend API (Go) với JWT validation<br>- Tích hợp Keycloak authentication vào frontend (Nuxt 3) | - Docker compose setup hoàn chỉnh<br>- Keycloak hoạt động với OAuth 2.0<br>- API backend với authentication middleware<br>- Login/Register flow hoàn chỉnh |
| 3 | 09/01/2026<br>- 22/01/2026 | - Phát triển User Registration & Login flows<br>- Tích hợp social login (Google, Apple)<br>- Cài đặt Capacitor cho iOS/Android<br>- Implement offline authentication với SQLite | - User có thể đăng ký/đăng nhập<br>- Social login hoạt động<br>- App chạy được trên Android/iOS<br>- Offline mode với encrypted storage<br><br>**Viết word chương 2** |

## Giai đoạn 3: Core Features - Journaling (23/01/2026 - 09/03/2026)

| STT | Thời gian | Nội dung thực hiện | Kết quả dự kiến |
|-----|-----------|-------------------|----------------|
| 4 | 23/01/2026<br>- 19/02/2026 | - Xây dựng AI Service (Python FastAPI)<br>- Tích hợp LangChain + HuggingFace models<br>- Setup Qdrant vector database<br>- Implement WebSocket cho real-time AI chat<br>- Xây dựng RabbitMQ message queues | - AI Service hoạt động độc lập<br>- LangChain pipeline hoàn chỉnh<br>- Qdrant lưu trữ journal embeddings<br>- WebSocket real-time communication<br>- Async processing với RabbitMQ |
| 5 | 20/02/2026<br>- 09/03/2026 | - Phát triển Journaling UI (carousel prompts, editor)<br>- Tích hợp AI-assisted journaling<br>- Implement SQLite local storage (offline-first)<br>- Xây dựng sync mechanism (RabbitMQ)<br>- Journal history & search | - User có thể viết journal với AI assistance<br>- Offline journaling với SQLite<br>- Auto-sync khi online<br>- Journal history với search<br><br>**Viết word chương 3** |

## Giai đoạn 4: Learning & Progress (10/03/2026 - 08/04/2026)

| STT | Thời gian | Nội dung thực hiện | Kết quả dự kiến |
|-----|-----------|-------------------|----------------|
| 6 | 10/03/2026<br>- 25/03/2026 | - Xây dựng Micro Learning feature<br>- Implement slide-based lessons (doc, cta, journal_prompt)<br>- Tạo lesson collections & categories<br>- Tích hợp semantic search với Qdrant<br>- Offline lesson storage | - Lesson library với browse/search<br>- Slide-based content system<br>- Collections organization<br>- Semantic discovery<br>- Offline access cho core lessons |
| 7 | 26/03/2026<br>- 08/04/2026 | - Phát triển Progress Tracking screen<br>- Implement metrics calculation (streak, sentiment, word count)<br>- Xây dựng charts & visualizations<br>- User Profile & Settings screen<br>- Data export functionality | - Progress metrics hiển thị real-time<br>- Streak tracking với 🔥 icon<br>- Sentiment trend charts<br>- Settings với theme, notifications<br>- Export progress reports |

## Giai đoạn 5: Testing & Deployment (09/04/2026 - 01/05/2026)

| STT | Thời gian | Nội dung thực hiện | Kết quả dự kiến |
|-----|-----------|-------------------|----------------|
| 8 | 09/04/2026<br>- 20/04/2026 | - Integration testing (Frontend ↔ Backend ↔ AI Service)<br>- Security testing (Keycloak, JWT, encryption)<br>- Performance optimization (API response, AI processing)<br>- Mobile testing (iOS & Android devices)<br>- Offline scenarios testing | - Tất cả features hoạt động end-to-end<br>- Security vulnerabilities được fix<br>- App mượt trên mobile devices<br>- Offline mode ổn định |
| 9 | 21/04/2026<br>- 01/05/2026 | - Bug fixes & polishing<br>- User acceptance testing<br>- Deployment preparation<br>- Documentation hoàn thiện<br>- **Hoàn thiện báo cáo đồ án** | - App production-ready<br>- User guide & technical docs<br>- Deployment scripts<br><br>**Hoàn thiện word, slide báo cáo** |

---

## 📝 Ghi chú

- **Công nghệ chính**: Nuxt 3 + Capacitor (Frontend), Go (Backend), Python FastAPI (AI), Keycloak (Auth), PostgreSQL + Qdrant (Database)
- **Ưu tiên**: Authentication → Journaling → Learning → Progress
- **Testing**: Liên tục trong suốt quá trình phát triển
- **Tài liệu**: Cập nhật song song với implementation

