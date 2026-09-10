# Báo cáo Đánh giá Kiến trúc Hệ thống (Mewmory)

_Thực hiện bởi: Senior Solution Architect_

Dựa trên việc phân tích mã nguồn hiện tại của dự án (React + Vite, Supabase, Dexie.js, Zustand, Tailwind v4), dưới đây là đánh giá toàn diện về hiện trạng kiến trúc và các đề xuất để đưa ứng dụng đạt chuẩn Production.

---

## 1. Hiện trạng: Đã có gì và Đang thiếu gì?

### 1.1. Đối với Người dùng (End-Users)

**Đã có:**

- **Local-First Experience:** Ứng dụng chạy rất nhanh do mọi thao tác đọc/ghi đều tương tác trực tiếp với IndexedDB (qua Dexie) trước.
- **Background Sync:** Cơ chế đồng bộ ngầm (`sync.js`) giúp người dùng có thể dùng offline và đồng bộ khi có mạng.
- **Tích hợp AI linh hoạt:** Có khả năng chuyển đổi giữa các nhà cung cấp AI (Gemini Native, OpenRouter).

**Đang thiếu:**

- **PWA (Progressive Web App) hoàn chỉnh:** Đã có Local DB nhưng thiếu Service Worker. Người dùng chưa thể "Cài đặt" (Install) app lên màn hình chính điện thoại và app sẽ chết nếu tải lại trang lúc mất mạng.
- **Push Notifications:** Trang Settings có nhắc đến "Kích hoạt nhắc nhở định kỳ" (dòng 236), nhưng hệ thống web chưa tích hợp Web Push API hoặc Firebase Cloud Messaging để thực sự gửi thông báo đẩy tới điện thoại.
- **Xử lý xung đột đồng bộ (Conflict Resolution):** Nếu người dùng sửa từ vựng offline trên điện thoại, rồi lại sửa offline trên laptop. Khi cả 2 có mạng, data sẽ bị đè lên nhau (Data Loss) do cơ chế hiện tại là _Last-Write-Wins_ mù quáng.

### 1.2. Đối với Lập trình viên (Developers)

**Đã có:**

- **Stack hiện đại & Clean:** Vite, Tailwind v4, Zustand.
- **Unit Testing Framework:** Đã thiết lập `vitest`, `jsdom`, `@testing-library/react` (thấy trong `package.json`).
- **Tách biệt Backend logic:** Các tác vụ nặng và bảo mật (gọi API LLM) được đưa xuống Supabase Edge Functions.

**Đang thiếu:**

- **E2E Testing:** Thiếu Playwright hoặc Cypress để test các luồng user flow quan trọng (VD: Đăng nhập -> Thêm từ -> Đồng bộ).
- **React Error Boundaries:** Thiếu một ranh giới bắt lỗi toàn cục. Nếu một component bị crash, toàn bộ app sẽ trắng trang thay vì hiện UI "Đã có lỗi xảy ra".
- **CI/CD Pipeline:** Chưa thấy cấu hình GitHub Actions để tự động chạy test, build và deploy Edge Functions/Web.

---

## 2. Đánh giá chuyên sâu về Non-functional Requirements

### 2.1. Observability (Khả năng quan sát) & Monitoring

**Hiện trạng:** **Chưa có.**

- Lỗi trên Frontend (React) chỉ hiện ở `console.error` của trình duyệt. Dev không thể biết user đang gặp lỗi gì.
- Lỗi trên Backend (Edge Functions) chỉ có logs cơ bản của Supabase. Không có Alerting (cảnh báo) khi AI API bị timeout hoặc rate-limited hàng loạt.

**Đề xuất:**

- Tích hợp **Sentry** cho Frontend để thu thập Error Tracking và Crash Reports.
- Tích hợp **Logflare** hoặc thiết lập Webhook Alerts trên Supabase để báo thẳng vào Slack/Discord khi Edge Functions có tỷ lệ lỗi > 5%.

### 2.2. Kiểm tra hiệu năng (Performance Testing)

**Hiện trạng:** **Chưa có.**

- Chúng ta chưa biết API `lookup-word` hay `translate-definition` sẽ phản hồi ra sao nếu có 1,000 user tra từ cùng lúc.
- Chưa có báo cáo Web Vitals (LCP, FID, CLS) cho Frontend.

**Đề xuất:**

- Cần chạy **Lighthouse CI** để đảm bảo điểm Performance > 90.
- Dùng **k6.io** để viết script bắn tải (Load Test) vào các Edge Functions.

### 2.3. Khả năng mở rộng (Scalability) & Tính hoàn chỉnh

**Hiện trạng:** Kiến trúc Local-First + Supabase là một mô hình tuyệt vời cho khả năng mở rộng (vì tải đọc/ghi đổ dồn về client). Tuy nhiên, nút thắt cổ chai (Bottleneck) đang nằm ở 2 điểm:

1. **Sync Engine (`sync.js`)**: Việc kéo (pull) toàn bộ record thay đổi dựa trên `last_sync_timestamp` sẽ ngày càng chậm khi database lớn lên.
2. **AI Third-party Limits**: Chúng ta đang bị phụ thuộc nặng vào Rate Limit của OpenRouter và Google AI.

**Đề xuất:**

- **Cải tiến Sync Engine:** Triển khai cơ chế phân trang (Pagination) hoặc Chunking khi Pull/Push data. Nên áp dụng CRDTs (Conflict-free Replicated Data Types) hoặc ít nhất là thêm trường `version` vào database để tránh ghi đè sai.
- **Caching ở Edge:** Triển khai Redis hoặc dùng chính database Supabase để cache các từ vựng đã được AI dịch. Nếu user B tra từ "Compute" mà user A đã từng tra, trả về luôn từ DB thay vì gọi lại Gemini (Tiết kiệm chi phí + Phản hồi 10ms).

---

## 3. Các bước hành động tiếp theo (Next Steps)

Để ứng dụng này "chuẩn Production", tôi đề xuất chúng ta nên ưu tiên làm theo thứ tự sau. Bạn hãy chọn ra **1-2 hạng mục ưu tiên nhất** để tôi lập Implementation Plan:

1. **[Bảo vệ người dùng]** Thêm **Sentry** (Observability) và **React Error Boundary** để theo dõi lỗi realtime.
2. **[Trải nghiệm người dùng]** Chuyển đổi thành **PWA hoàn chỉnh** (Thêm Service Worker, Web Manifest) để app có thể cài đặt và chạy offline 100%.
3. **[Tối ưu Chi phí & Tốc độ]** Xây dựng hệ thống **Global Dictionary Cache** trên Supabase: Ai tra từ gì thì lưu lại kết quả AI, người sau tra trùng sẽ lấy luôn kết quả đó.
4. **[Độ tin cậy]** Nâng cấp **Sync Engine**: Thêm cơ chế retry khi rớt mạng, phân trang dữ liệu khi đồng bộ.
5. **[Testing]** Viết script **k6** để test hiệu năng Edge Functions hoặc thiết lập **Playwright** cho E2E Testing.
