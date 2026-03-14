# LỜI NÓI ĐẦU

Trong bối cảnh xã hội hiện đại với áp lực cuộc sống ngày càng gia tăng, sức khỏe tâm thần đã trở thành một trong những thách thức lớn nhất đối với cộng đồng. Theo Tổ chức Y tế Thế giới (WHO), có khoảng 280 triệu người trên toàn cầu đang phải đối mặt với các vấn đề về sức khỏe tâm thần, trong đó trầm cảm và lo âu là những tình trạng phổ biến nhất. Tại Việt Nam, những rào cản như chi phí điều trị cao, thiếu nguồn lực chuyên môn, khoảng cách địa lý, và đặc biệt là sự kỳ thị xã hội đã khiến nhiều người ngần ngại tìm kiếm sự hỗ trợ chuyên môn.

Việc ứng dụng trí tuệ nhân tạo (AI) và công nghệ thông tin vào lĩnh vực chăm sóc sức khỏe tâm thần đang trở nên cấp thiết. Công nghệ AI có thể cung cấp sự hỗ trợ cá nhân hóa 24/7, không bị giới hạn bởi thời gian và địa điểm, giúp hạ thấp rào cản tiếp cận, tạo môi trường an toàn để người dùng tự do bày tỏ cảm xúc, và cung cấp phản hồi tức thời. Phương pháp viết nhật ký cảm xúc (emotion journaling) đã được nhiều nghiên cứu tâm lý học chứng minh là công cụ hiệu quả, nhưng vẫn còn gặp khó khăn trong việc duy trì thói quen và theo dõi tiến trình một cách khoa học.

Đề tài **"Xây dựng Hệ thống Hỗ trợ Sức khỏe Tâm thần với AI - TheraPrep"** ra đời nhằm ứng dụng các công nghệ AI, xử lý ngôn ngữ tự nhiên (NLP) và kiến trúc vi dịch vụ (microservices) để xây dựng một nền tảng toàn diện. Hệ thống sử dụng Nuxt 3, Golang, Python FastAPI, LangChain, Qdrant vector database, và RabbitMQ để cung cấp trải nghiệm viết nhật ký thông minh với AI hỗ trợ real-time, kiến thức tâm lý học, phân tích xu hướng cảm xúc, và hỗ trợ chuẩn bị cho buổi trị liệu. Đặc biệt, hệ thống áp dụng mô hình offline-first với SQLite, cho phép người dùng sử dụng đầy đủ tính năng ngay cả khi không có kết nối internet.

Đồ án này không chỉ góp phần nâng cao chất lượng chăm sóc sức khỏe tâm thần cộng đồng trong kỷ nguyên số, mà còn là cơ hội để nghiên cứu và áp dụng các công nghệ tiên tiến như RAG (Retrieval-Augmented Generation), vector search, và kiến trúc phân tán vào thực tiễn. Tác giả xin chân thành cảm ơn sự hướng dẫn của thầy cô, sự hỗ trợ của gia đình, bạn bè, và cộng đồng open-source trong suốt quá trình thực hiện đồ án này.

---

## I. MỞ ĐẦU

### 1. Tính cấp thiết của đề tài

Vấn đề sức khỏe tâm thần đang trở thành một trong những thách thức lớn nhất của xã hội hiện đại. Tại Việt Nam, hệ thống chăm sóc sức khỏe tâm thần còn nhiều hạn chế với chi phí cao, thiếu nguồn lực chuyên môn và kỳ thị xã hội. Phương pháp truyền thống thiếu công cụ tự theo dõi, khó khăn trong việc diễn đạt cảm xúc và không có phản hồi kịp thời.

Việc ứng dụng AI vào lĩnh vực này có thể hạ thấp rào cản tiếp cận, cung cấp hỗ trợ 24/7, tạo môi trường an toàn để bày tỏ cảm xúc và phân tích xu hướng theo thời gian. Viết nhật ký cảm xúc đã được chứng minh hiệu quả nhưng cần công cụ hỗ trợ để duy trì thói quen và theo dõi tiến trình khoa học.

Chính vì vậy, đề tài **"Xây dựng Hệ thống Hỗ trợ Sức khỏe Tâm thần với AI - TheraPrep"** ứng dụng AI, NLP và kiến trúc microservices để cung cấp giải pháp toàn diện: viết nhật ký thông minh, kiến thức tâm lý học, phân tích cảm xúc và hỗ trợ chuẩn bị trị liệu.

### 2. Mục tiêu nghiên cứu của đề tài

Sử dụng các công nghệ hiện đại như Nuxt 3, Golang, Python FastAPI, LangChain, Qdrant, PostgreSQL và RabbitMQ để xây dựng hệ thống ứng dụng di động đa nền tảng hỗ trợ sức khỏe tâm thần. Đồng thời áp dụng kiến trúc vi dịch vụ (microservices) và mô hình offline-first, tích hợp AI phân tích cảm xúc và hệ thống RAG để cung cấp trải nghiệm viết nhật ký cá nhân hóa.

**Mục tiêu cụ thể:**
- Quản lý người dùng và xác thực an toàn (Keycloak OAuth 2.0)
- Viết nhật ký với AI hỗ trợ real-time
- Hệ thống học tập vi mô về tâm lý
- Theo dõi tiến trình và phân tích cảm xúc
- Đồng bộ dữ liệu offline/online

### 3. Đối tượng và phạm vi nghiên cứu

**• Đối tượng:**
- Công nghệ AI và xử lý ngôn ngữ tự nhiên (NLP, LangChain, LLM)
- Kiến trúc microservices và offline-first cho ứng dụng mobile
- Hệ thống xác thực OAuth 2.0 và bảo mật dữ liệu

**• Phạm vi:**
- Xây dựng hệ thống viết nhật ký với AI hỗ trợ real-time
- Tạo vector database với Qdrant cho semantic search và RAG
- Triển khai kiến trúc microservices (Nuxt 3, Golang, Python FastAPI)
- Tích hợp đồng bộ dữ liệu bất đồng bộ với RabbitMQ
- Đánh giá hiệu quả trên nền tảng iOS/Android

### 4. Các nhiệm vụ chính cần thực hiện

Nội dung nghiên cứu tập trung vào các nhiệm vụ chính:
- Tìm hiểu và sử dụng LangChain để xây dựng AI assistant
- Nghiên cứu Qdrant vector database cho semantic search
- Nghiên cứu kiến trúc microservices với Golang và Python
- Triển khai OAuth 2.0 với Keycloak cho mobile app
- Xây dựng hệ thống offline-first với SQLite và sync strategy
- Phát triển ứng dụng mobile với Nuxt 3 và Capacitor
- Xây dựng WebSocket real-time chat với AI
- Triển khai hệ thống message queue với RabbitMQ

### 5. Kết quả dự kiến

**• Lý thuyết:**
- Nắm vững xử lý ngôn ngữ tự nhiên (NLP) và phân tích cảm xúc
- Thành thạo kiến trúc microservices và offline-first patterns
- Hiểu rõ RAG (Retrieval-Augmented Generation) với LangChain và Qdrant

**• Thực nghiệm:**

Ứng dụng mobile TheraPrep hoàn chỉnh với các tính năng:
- **Xác thực người dùng**: OAuth 2.0 với Keycloak, hỗ trợ social login
- **Viết nhật ký AI**: Real-time AI assistance, phân tích cảm xúc, lưu trữ encrypted offline
- **Học tập vi mô**: Thư viện bài học tâm lý (2-5 phút), semantic search
- **Theo dõi tiến trình**: Streak system, biểu đồ xu hướng cảm xúc, AI insights cá nhân hóa
- **Quản lý dữ liệu**: Đồng bộ tự động, xuất báo cáo cho chuyên gia trị liệu

**Tiêu chí đánh giá:**
- Độ chính xác phân tích cảm xúc ≥ 80%
- Thời gian phản hồi AI < 2 giây
- Hoạt động offline đầy đủ tính năng
- Đồng bộ dữ liệu tin cậy và bảo mật
