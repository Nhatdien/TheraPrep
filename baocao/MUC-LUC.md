# MỤC LỤC

LỜI CẢM ƠN

LỜI NÓI ĐẦU

DANH MỤC KÝ HIỆU VÀ CHỮ VIẾT TẮT

DANH MỤC HÌNH VẼ

DANH MỤC BẢNG BIỂU

---

## CHƯƠNG 1. TỔNG QUAN VỀ ỨNG DỤNG CHĂM SÓC SỨC KHỎE TÂM THẦN VÀ TRÍ TUỆ NHÂN TẠO

1.1. Khảo sát các ứng dụng chăm sóc sức khỏe tâm thần

1.2. Tìm hiểu kỹ thuật xử lý ngôn ngữ tự nhiên (NLP)
- 1.2.1. Khái niệm
- 1.2.2. Hoạt động
- 1.2.3. Ứng dụng trong phân tích cảm xúc

1.3. Tìm hiểu về mô hình ngôn ngữ lớn (LLM) và RAG

1.4. Tìm hiểu về kiến trúc vi dịch vụ (Microservices)
- 1.4.1. Microservices và Message Queue
- 1.4.2. RabbitMQ trong hệ thống phân tán

1.5. Một số công nghệ và công cụ sử dụng
- 1.5.1. Nuxt 3 và Capacitor
- 1.5.2. Golang và Python FastAPI
- 1.5.3. PostgreSQL và Qdrant
- 1.5.4. LangChain và HuggingFace
- 1.5.5. Keycloak OAuth 2.0
- 1.5.6. Docker và VS Code

1.6. Tổng kết chương 1

---

## CHƯƠNG 2. PHÂN TÍCH VÀ THIẾT KẾ HỆ THỐNG THERAPREP

2.1. Phân tích hệ thống
- 2.1.1. Yêu cầu chức năng
- 2.1.2. Yêu cầu phi chức năng
- 2.1.3. Use case tổng quát
- 2.1.4. Biểu đồ hoạt động

2.2. Thiết kế hệ thống
- 2.2.1. Kiến trúc tổng thể
- 2.2.2. Thiết kế giao diện
- 2.2.3. Thiết kế cơ sở dữ liệu

2.3. Tổng kết chương 2

---

## CHƯƠNG 3. XÂY DỰNG ỨNG DỤNG THERAPREP

3.1. Cấu hình môi trường và Docker

3.2. Xây dựng hệ thống xác thực

3.3. Xây dựng AI Service với LangChain

3.4. Xây dựng tính năng viết nhật ký

3.5. Xây dựng tính năng micro-learning

3.6. Tổng kết chương 3

---

## CHƯƠNG 4. KẾT QUẢ VÀ THỰC NGHIỆM

4.1. Kết quả đạt được

4.2. Thực nghiệm
- 4.2.1. Chức năng đăng ký và xác thực
- 4.2.2. Chức năng viết nhật ký với AI
- 4.2.3. Chức năng học tập và theo dõi tiến trình

4.3. Tổng kết chương 4

---

## KẾT LUẬN

## TÀI LIỆU THAM KHẢO

[1] World Health Organization, Mental Health and COVID-19: Early evidence of the pandemic's impact, WHO, 2022.

[2] Nuxt Team, Nuxt 3 Documentation, Online: https://nuxt.com/docs

[3] Capacitor Team, Capacitor: Cross-platform native runtime for web apps, Online: https://capacitorjs.com/docs

[4] Keycloak Team, Keycloak Documentation - Securing Applications and Services, Online: https://www.keycloak.org/documentation

[5] IETF, RFC 6749 - The OAuth 2.0 Authorization Framework, Online: https://datatracker.ietf.org/doc/html/rfc6749

[6] Harrison Chase et al., LangChain: Building applications with LLMs through composability, Online: https://python.langchain.com/

[7] Lewis, Patrick et al., Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks, arXiv:2005.11401, 2020.

[8] Qdrant Team, Qdrant Vector Database Documentation, Online: https://qdrant.tech/documentation/

[9] PostgreSQL Global Development Group, PostgreSQL Documentation, Online: https://www.postgresql.org/docs/

[10] RabbitMQ Team, RabbitMQ Documentation, Online: https://www.rabbitmq.com/documentation.html

[11] Golang Team, The Go Programming Language Documentation, Online: https://go.dev/doc/

[12] FastAPI Team, FastAPI framework for building APIs with Python, Online: https://fastapi.tiangolo.com/

## PHỤ LỤC (nếu có)
- Theo dõi tiến trình và thống kê
- Quản lý hồ sơ và cài đặt
- Đồng bộ dữ liệu offline/online

#### 2.1.2. Yêu cầu phi chức năng
- Bảo mật và quyền riêng tư
- Hiệu suất và khả năng mở rộng
- Tính sẵn sàng và độ tin cậy
- Trải nghiệm người dùng
- Khả năng hoạt động offline

#### 2.1.3. Sơ đồ ca sử dụng (Use Case)
- Sơ đồ Use Case tổng thể
- Vai trò và tác nhân trong hệ thống
- Các luồng tương tác chính

#### 2.1.4. Biểu đồ hoạt động (Activity Diagrams)
- Quy trình đăng ký và giới thiệu hệ thống
- Quy trình viết nhật ký
- Quy trình học tập
- Quy trình đồng bộ dữ liệu

### 2.2. Thiết kế kiến trúc hệ thống
#### 2.2.1. Tổng quan kiến trúc
- Kiến trúc vi dịch vụ (Microservices) dạng monorepo
- Sơ đồ kiến trúc tổng thể
- Luồng dữ liệu giữa các dịch vụ

#### 2.2.2. Thiết kế giao diện người dùng (Frontend)
- Kiến trúc ứng dụng Nuxt 3
- Cấu trúc thành phần và mẫu thiết kế
- Quản lý trạng thái với Pinia
- Chiến lược offline-first (ưu tiên chế độ ngoại tuyến)
- Kiến trúc lưu trữ cục bộ (SQLite + Preferences + SecureStorage)

#### 2.2.3. Thiết kế dịch vụ chính phía máy chủ (Backend Core Service - Golang)
- Thiết kế API RESTful
- Mẫu thiết kế Repository
- Middleware và xác thực
- Quản lý kết nối cơ sở dữ liệu (Connection pooling)

#### 2.2.4. Thiết kế dịch vụ AI (AI Service - Python)
- Kiến trúc FastAPI
- Tích hợp LangChain
- Thiết kế cơ sở dữ liệu vector
- Giao tiếp thời gian thực qua WebSocket

#### 2.2.5. Thiết kế hàng đợi tin nhắn (Message Queue)
- Cấu trúc RabbitMQ
- Cấu hình hàng đợi (Queue) và bộ trao đổi (Exchange)
- Xử lý tác vụ bất đồng bộ

#### 2.2.6. Thiết kế xác thực người dùng
- Tích hợp Keycloak
- Luồng OAuth 2.0
- Chiến lược quản lý mã thông báo
- Xác thực ngoại tuyến

### 2.3. Thiết kế cơ sở dữ liệu
#### 2.3.1. Thiết kế lược đồ PostgreSQL
- Bảng Users (Người dùng) và User Information (Thông tin người dùng)
- Bảng Journals (Nhật ký) và Emotion Logs (Nhật ký cảm xúc)
- Bảng Lessons (Bài học) và Collections (Bộ sưu tập)
- Bảng Progress (Tiến trình) và Streaks (Chuỗi hoạt động)
- Bảng AI Chatlogs (Lịch sử trò chuyện AI)

#### 2.3.2. Thiết kế cơ sở dữ liệu vector (Qdrant)
- Cấu trúc bộ sưu tập (Collection)
- Chiến lược nhúng dữ liệu (Embedding)
- Cấu hình tìm kiếm ngữ nghĩa

#### 2.3.3. Thiết kế cơ sở dữ liệu cục bộ (SQLite)
- Lược đồ cho dữ liệu ngoại tuyến
- Chiến lược đồng bộ
- Giải quyết xung đột dữ liệu


### 2.4. Tổng kết chương 2

---

## CHƯƠNG 3. CÀI ĐẶT CÁC TÍNH NĂNG CHÍNH

### 3.1. Triển khai tính năng Đăng ký và Xác thực
#### 3.1.1. Cấu hình Keycloak
- Cấu hình Realm (Miền xác thực)
- Thiết lập Client (Ứng dụng khách)
- Liên kết người dùng (User federation)

#### 3.1.2. Triển khai luồng đăng ký
- Đăng ký dựa trên tên người dùng
- Chính sách mật khẩu
- Xác minh email

#### 3.1.3. Triển khai luồng đăng nhập
- Luồng OAuth 2.0 Authorization Code
- Thu thập và lưu trữ mã thông báo
- Tự động làm mới mã thông báo

#### 3.1.4. Luồng giới thiệu hệ thống
- Thu thập tùy chọn người dùng
- Hướng dẫn thiết lập ban đầu
- Màn hình hướng dẫn sử dụng

### 3.2. Triển khai tính năng Viết nhật ký cảm xúc
#### 3.2.1. Kiến trúc tính năng nhật ký
- Mô hình dữ liệu bài nhật ký
- Cấu trúc nhật ký cảm xúc
- Tích hợp hỗ trợ AI

#### 3.2.2. Triển khai gợi ý chủ đề nhật ký
- Hệ thống mẫu gợi ý
- Giao diện băng chuyền (Carousel)
- Thuật toán chọn gợi ý

#### 3.2.3. Triển khai viết nhật ký với hỗ trợ AI
- Gợi ý AI theo thời gian thực
- Phản hồi nhận thức ngữ cảnh

#### 3.2.4. Xử lý và lưu trữ bài nhật ký
- Lưu trữ cục bộ SQLite
- Phân tích cảm xúc
- Tạo vector nhúng dữ liệu
- Đồng bộ đám mây với PostgreSQL

#### 3.2.5. Triển khai lịch sử nhật ký
- Hiển thị dòng thời gian
- Tìm kiếm và lọc
- Xem chi tiết bài viết

### 3.3. Triển khai tính năng Học tập vi mô
#### 3.3.1. Hệ thống quản lý nội dung
- Cấu trúc dữ liệu bài học
- Tổ chức bộ sưu tập
- Các loại slide và hiển thị

#### 3.3.2. Triển khai các loại slide
- Slide văn bản
- Slide hình ảnh
- Slide kêu gọi hành động (CTA)
- Slide gợi ý viết nhật ký
- Slide câu hỏi trắc nghiệm
- Slide video

#### 3.3.3. Điều hướng bài học
- Băng chuyền slide
- Theo dõi tiến độ
- Phát hiện hoàn thành

#### 3.3.4. Hệ thống học tập hàng ngày
- Thuật toán đề xuất nội dung
- Lập lịch thông báo
- Chỉ số tương tác

### 3.4. Triển khai tính năng Theo dõi tiến trình
#### 3.4.1. Hệ thống chuỗi hoạt động
- Thuật toán tính chuỗi hoạt động
- Quy tắc duy trì chuỗi
- Hiển thị trực quan

#### 3.4.2. Phân tích tâm trạng
- Tổng hợp cảm xúc
- Phân tích xu hướng
- Biểu đồ trực quan hóa

#### 3.4.3. Chỉ số hoạt động
- Theo dõi số lượng nhật ký
- Theo dõi hoàn thành bài học
- Phân tích thời gian sử dụng

#### 3.4.4. Thông tin cá nhân hóa
- Nhận dạng mẫu hình
- Thông tin do AI tạo ra
- Công cụ đề xuất

### 3.5. Triển khai tính năng Hồ sơ và Cài đặt
#### 3.5.1. Quản lý hồ sơ người dùng
- Thao tác CRUD thông tin hồ sơ
- Tải lên ảnh đại diện
- Quản lý tùy chọn

#### 3.5.2. Cấu hình cài đặt
- Cài đặt giao diện (chế độ tối/sáng)
- Tùy chọn ngôn ngữ
- Cài đặt thông báo
- Cài đặt quyền riêng tư

#### 3.5.3. Xuất dữ liệu
- Tính năng xuất nhật ký
- Tạo báo cáo tiến trình
- Tài liệu tóm tắt cho chuyên gia trị liệu

### 3.6. Triển khai Dịch vụ AI
#### 3.6.1. Chuỗi xử lý LangChain
- Cấu hình chuỗi xử lý
- Kỹ thuật thiết kế lời nhắc (Prompt engineering)
- Thiết kế lời nhắc hệ thống

#### 3.6.2. Thao tác cơ sở dữ liệu vector
- Tạo vector nhúng
- Tìm kiếm tương đồng
- Truy xuất ngữ cảnh cho RAG

#### 3.6.3. Công cụ và hàm AI
- Triển khai công cụ tùy chỉnh
- Gọi hàm
- Xử lý lỗi

#### 3.6.4. Trò chuyện thời gian thực qua WebSocket
- Quản lý kết nối
- Truyền tin nhắn
- Xử lý phiên làm việc

### 3.7. Triển khai Đồng bộ hóa dữ liệu
#### 3.7.1. Kiến trúc ưu tiên ngoại tuyến
- SQLite cục bộ làm lưu trữ chính
- Quản lý hàng đợi đồng bộ
- Chiến lược giải quyết xung đột

#### 3.7.2. Đồng bộ bất đồng bộ qua RabbitMQ
- Cấu hình hàng đợi đồng bộ
- Định dạng tin nhắn
- Cơ chế thử lại

#### 3.7.3. Các thao tác đồng bộ
- Đồng bộ nhật ký
- Đồng bộ tiến trình bài học
- Đồng bộ cài đặt
- Đồng bộ lịch sử trò chuyện

### 3.8. Tổng kết chương 3

---

## CHƯƠNG 4. KẾT QUẢ VÀ ĐÁNH GIÁ

### 4.1. Kết quả triển khai
#### 4.1.1. Môi trường phát triển
- Thiết lập môi trường phát triển
- Đóng gói container với Docker
- Quy trình CI/CD

#### 4.1.2. Các tính năng đã hoàn thành
- Đăng ký và xác thực người dùng ✅
- Tính năng viết nhật ký (đang phát triển) 🔄
- Học tập vi mô (đã lên kế hoạch) 🧠
- Theo dõi tiến trình (đã lên kế hoạch) 🧠
- Hồ sơ và cài đặt (đã lên kế hoạch) 🧠

### 4.2. Thực nghiệm và kiểm thử
#### 4.2.1. Kiểm thử chức năng Đăng ký và Xác thực
- Các ca kiểm thử luồng đăng ký
- Các ca kiểm thử luồng đăng nhập
- Kiểm thử làm mới mã thông báo
- Kiểm thử xác thực ngoại tuyến

#### 4.2.2. Kiểm thử chức năng Viết nhật ký
- Kiểm thử tạo nhật ký
- Kiểm thử hỗ trợ AI
- Kiểm thử lưu trữ cục bộ
- Kiểm thử đồng bộ
- Kiểm thử tìm kiếm và lọc

#### 4.2.3. Kiểm thử chức năng Dịch vụ AI
- Kiểm thử tạo vector nhúng
- Độ chính xác tìm kiếm vector
- Đánh giá chất lượng phản hồi
- Đo độ trễ

#### 4.2.4. Kiểm thử hiệu năng
- Thời gian phản hồi API
- Tối ưu hóa truy vấn cơ sở dữ liệu
- Hiệu năng ứng dụng di động
- Sử dụng bộ nhớ
- Tiêu thụ pin

#### 4.2.5. Kiểm thử bảo mật
- Bảo mật xác thực
- Mã hóa dữ liệu
- Bảo mật API
- Bảo mật mã thông báo
- Xác thực đầu vào

#### 4.2.6. Kiểm thử tương thích
- Kiểm thử đa nền tảng (iOS/Android/Web)
- Tương thích trình duyệt
- Tương thích thiết bị
- Kiểm thử điều kiện mạng

### 4.3. Đánh giá và so sánh
#### 4.3.1. So sánh với các ứng dụng tương tự
- So sánh tính năng
- So sánh hiệu năng
- So sánh trải nghiệm người dùng

#### 4.3.2. Ưu điểm của hệ thống
- Phương pháp ưu tiên ngoại tuyến
- Viết nhật ký với hỗ trợ AI
- Theo dõi tiến trình toàn diện
- Thiết kế tập trung vào quyền riêng tư

#### 4.3.3. Hạn chế và thách thức
- Hạn chế về kỹ thuật
- Ràng buộc về tài nguyên
- Cải tiến cần thiết trong tương lai

### 4.4. Phản hồi và đánh giá người dùng (nếu có)
#### 4.4.1. Phản hồi từ kiểm thử người dùng
#### 4.4.2. Đánh giá khả năng sử dụng
#### 4.4.3. Chỉ số hài lòng

### 4.5. Tổng kết chương 4

---

## KẾT LUẬN

### 1. Tóm tắt kết quả đạt được
### 2. Đóng góp của đề tài
### 3. Hạn chế và hướng phát triển
#### 3.1. Hạn chế hiện tại
#### 3.2. Kế hoạch phát triển tương lai
- Tính năng chuẩn bị cho buổi trị liệu
- Tóm tắt hồ sơ cho chuyên gia trị liệu
- Nâng cao khả năng AI
- Tính năng cộng đồng
- Kết nối với chuyên gia trị liệu
- Nhật ký video/audio
- Phân tích nâng cao

### 4. Kết luận chung

---

## TÀI LIỆU THAM KHẢO

### Sách và tạp chí
1. [Tài liệu về Công nghệ Sức khỏe Tâm thần]
2. [Cơ bản về Xử lý Ngôn ngữ Tự nhiên]
3. [Các mẫu kiến trúc Vi dịch vụ]

### Tài liệu kỹ thuật
1. Tài liệu Nuxt 3 - https://nuxt.com/docs
2. Tài liệu Vue 3 - https://vuejs.org/guide/
3. Tài liệu Capacitor - https://capacitorjs.com/docs
4. Tài liệu Keycloak - https://www.keycloak.org/documentation
5. Tài liệu LangChain - https://python.langchain.com/
6. Tài liệu Qdrant - https://qdrant.tech/documentation/
7. Tài liệu Golang - https://go.dev/doc/
8. Tài liệu FastAPI - https://fastapi.tiangolo.com/
9. Tài liệu PostgreSQL - https://www.postgresql.org/docs/
10. Tài liệu RabbitMQ - https://www.rabbitmq.com/documentation.html

### Tiêu chuẩn RFC và Quy chuẩn
1. RFC 6749 - Khung Ủy quyền OAuth 2.0
2. RFC 7519 - Mã thông báo Web JSON (JWT)
3. OpenID Connect Core 1.0

### Các nguồn tham khảo khác
1. Hướng dẫn Bảo mật OWASP
2. Thực hành Tốt nhất về Bảo mật Ứng dụng Di động
3. Hướng dẫn Thiết kế Ứng dụng Sức khỏe Tâm thần

---

## PHỤ LỤC

### Phụ lục A: Ví dụ mã nguồn
#### A.1. Mã nguồn giao diện người dùng (Frontend)
#### A.2. Ví dụ API phía máy chủ (Backend)
#### A.3. Ví dụ dịch vụ AI

### Phụ lục B: Lược đồ cơ sở dữ liệu
#### B.1. Lược đồ đầy đủ PostgreSQL
#### B.2. Lược đồ SQLite cục bộ
#### B.3. Lược đồ bộ sưu tập Qdrant

### Phụ lục C: Tài liệu API
#### C.1. Các endpoint API dịch vụ chính
#### C.2. Các endpoint API dịch vụ AI
#### C.3. Giao thức WebSocket

### Phụ lục D: Ảnh chụp màn hình giao diện
#### D.1. Màn hình giới thiệu
#### D.2. Màn hình viết nhật ký
#### D.3. Màn hình học tập
#### D.4. Màn hình theo dõi tiến trình
#### D.5. Màn hình cài đặt

### Phụ lục E: Biểu đồ và sơ đồ
#### E.1. Sơ đồ kiến trúc hệ thống
#### E.2. Sơ đồ ER cơ sở dữ liệu
#### E.3. Sơ đồ luồng người dùng
#### E.4. Sơ đồ trình tự (Sequence diagrams)

### Phụ lục F: Cấu hình hệ thống
#### F.1. File cấu hình Docker
#### F.2. Biến môi trường
#### F.3. Cấu hình Keycloak
#### F.4. Cấu hình RabbitMQ

### Phụ lục G: Các ca kiểm thử
#### G.1. Ví dụ kiểm thử đơn vị
#### G.2. Kịch bản kiểm thử tích hợp
#### G.3. Kết quả kiểm thử hiệu năng

---

## METADATA

**Dự án**: TheraPrep - Nền tảng Viết nhật ký Cảm xúc và Chuẩn bị Trị liệu với hỗ trợ AI  
**Kiến trúc**: Vi dịch vụ dạng Monorepo  
**Công nghệ chính**: Nuxt 3, Golang, Python FastAPI, PostgreSQL, Qdrant, RabbitMQ, Keycloak  
**Nền tảng**: iOS, Android, Web  
**Năm thực hiện**: 2025-2026  

---

*Mục lục này được tạo dựa trên tài liệu thiết kế chi tiết trong thư mục feature-design của dự án TheraPrep*
