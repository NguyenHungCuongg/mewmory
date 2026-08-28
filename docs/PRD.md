# Mewmory — Product Requirements Document (PRD)

> **Version:** 1.0
> **Last Updated:** 2026-08-25
> **Author:** PM (AI-assisted)
> **Status:** Draft — Pending Review

---

## 1. Tổng quan sản phẩm

### 1.1 Tên sản phẩm

**Mewmory** — Ứng dụng ghi chép từ vựng tiếng Anh thông minh.

### 1.2 Tầm nhìn

Mewmory giúp người học tiếng Anh ghi chép từ vựng nhanh chóng, thông minh, và có tổ chức — chỉ cần nhập từ tiếng Anh, app tự động điền đầy đủ thông tin từ Dictionary API và AI, giúp người dùng tập trung vào việc học thay vì tra cứu và ghi chép thủ công.

### 1.3 Mục tiêu

- **Giảm thời gian ghi chép từ vựng** từ ~2 phút/từ xuống ~10 giây/từ.
- **Tổ chức từ vựng tự động** theo chủ đề (Collection) bằng AI.
- **Hỗ trợ offline hoàn toàn** — xem, thêm, sửa, xóa không cần mạng.
- **Đồng bộ cross-platform** — Web và Mobile dùng chung dữ liệu.
- **Nhắc nhở ôn tập** — thông báo từ vựng hàng ngày.

### 1.4 Đối tượng sử dụng

- App nội bộ cho developer và bạn bè (~10 người).
- Chưa cần publish lên Store.
- Người dùng chủ yếu là người Việt học tiếng Anh.

### 1.5 Phạm vi phát triển

| Giai đoạn   | Nền tảng   | Mô tả                                      |
| ----------- | ---------- | ------------------------------------------ |
| **Phase 1** | Web App    | Vite + React SPA — Đầy đủ chức năng        |
| **Phase 2** | Mobile App | Flutter — Offline-first, push notification |

---

## 2. Các chức năng chính

### 2.1 F01 — Note từ vựng thông minh (Smart Vocabulary Input)

**Mô tả:** Người dùng chỉ cần nhập từ tiếng Anh → nhấn 1 nút → app tự động điền tất cả các field thông tin → người dùng review, chỉnh sửa nếu cần → lưu.

**Các field của một từ vựng:**

| Field                              | Nguồn dữ liệu               | Bắt buộc | Editable |
| ---------------------------------- | --------------------------- | -------- | -------- |
| Từ vựng (word)                     | User nhập                   | ✅       | ✅       |
| Phiên âm IPA (phonetic)            | Dictionary API              | ❌       | ✅       |
| Audio phát âm (audio_url)          | Dictionary API              | ❌       | ✅       |
| Loại từ (part of speech)           | Dictionary API              | ❌       | ✅       |
| Level (CEFR: A1→C2)                | AI                          | ❌       | ✅       |
| Usage (formal, informal, slang...) | AI                          | ❌       | ✅       |
| Nghĩa tiếng Việt (definitions)     | AI (dịch từ EN definitions) | ❌       | ✅       |
| Ví dụ (examples)                   | Dictionary API + AI         | ❌       | ✅       |
| Collection gợi ý                   | AI                          | ❌       | ✅       |

> [!NOTE]
> **Một từ có nhiều loại từ (part of speech):** Ví dụ "run" vừa là verb vừa là noun. Mỗi vocabulary entry lưu 1 `part_of_speech`, nên nếu từ có nhiều loại từ, user sẽ thấy nhiều kết quả và có thể lưu thành nhiều entries riêng biệt. UI sẽ hiển thị kèm part_of_speech để phân biệt.

**Luồng xử lý:**

1. User nhập từ tiếng Anh vào input field.
2. User nhấn nút "Lookup" (hoặc Enter).
3. App gọi song song:
   - **Free Dictionary API** → lấy phonetic, audio_url, part of speech, definitions (EN), examples.
   - **AI API** → lấy CEFR level, usage, nghĩa tiếng Việt, collection gợi ý.
4. App hiển thị kết quả với TẤT CẢ các nghĩa của từ.
5. User tích chọn những nghĩa muốn lưu.
6. User review/chỉnh sửa bất kỳ field nào (có thể bấm nghe phát âm thử).
7. User nhấn "Save" → lưu vào local database.
8. Khi có mạng → sync lên Supabase.

**Xử lý từ trùng:**

- Khi user nhập từ vào input field, app **kiểm tra real-time** (debounced) xem từ đã tồn tại trong local database chưa. Nếu có, hiển thị badge nhỏ: _"Từ này đã có X entries"_ ngay dưới input field.
- Khi user nhấn Save, app kiểm tra:
  - Nếu trùng từ **và** trùng nghĩa đã lưu → hiển thị cảnh báo: _"Bạn đã lưu từ này với nghĩa tương tự!"_
  - Vẫn cho phép lưu bản mới song song nếu user muốn.
  - Nếu trùng từ nhưng khác nghĩa → không cảnh báo, lưu bình thường.

**Chế độ nhập thủ công:**

- User có thể chọn tự điền tất cả các field mà không dùng API/AI.
- Có thể mix: dùng API cho một số field, tự điền field khác.

### 2.2 F02 — Quản lý Collection (Collection Management)

**Mô tả:** Từ vựng được tổ chức theo Collection (bộ sưu tập) dựa trên chủ đề (topic).

**Chức năng:**

- AI tự động gợi ý Collection phù hợp khi user lưu từ mới (ví dụ: "Travel", "Technology", "Business").
- User có thể:
  - Tạo Collection mới tùy ý (ví dụ: "IELTS Writing Task 2", "Phỏng vấn IT").
  - Chỉnh sửa/xóa Collection.
  - Gán/bỏ gán từ vựng khỏi Collection.
  - Xem tất cả từ vựng trong một Collection.
- Một từ vựng có thể thuộc nhiều Collection (many-to-many).
- Có Collection mặc định "Uncategorized" cho từ chưa được phân loại.

### 2.3 F03 — Ôn tập & Thông báo từ vựng hàng ngày (Daily Vocabulary Review & Reminder)

**Mô tả:** Giúp người dùng chủ động hoặc thụ động ôn lại ngẫu nhiên 1 từ vựng cũ đã lưu mỗi ngày.

**Hình thức triển khai:**

1. **In-App Daily Review Widget (Phase 1 - Web & Dashboard):**
   - Widget nổi bật ngay đầu trang Dashboard hiển thị 1 từ ngẫu nhiên trong ngày kèm 2 chế độ:
     - **Nhắc nhở nhẹ (Gentle Card):** Hiển thị từ + phiên âm + nút loa phát âm + nghĩa rút gọn.
     - **Quiz nhanh (Flashcard Mode):** Chỉ hiển thị từ tiếng Anh → bấm "Xem nghĩa / Lật thẻ" để kiểm tra trí nhớ.
   - Nút "Từ khác (Next Word)" để ôn thêm nhiều từ liên tục.
2. **Push Notification:**
   - **Phase 1 (Web):** Hỗ trợ Web Push Notification (nếu trình duyệt hỗ trợ và người dùng cấp quyền).
   - **Phase 2 (Mobile App):** Native Push Notification (FCM/APNs) định kỳ theo khung giờ đã chọn.

**Cấu hình trong Settings:**

- Bật/tắt thông báo / Daily widget.
- Chọn chế độ hiển thị mặc định (nhắc nhở nhẹ / quiz nhanh).
- Chọn thời gian nhận thông báo.
- Chọn Collection nguồn (tất cả hoặc chỉ định một số Collection).

### 2.4 F04 — Tìm kiếm và Lọc từ vựng (Search & Filter)

**Mô tả:** Hệ thống tìm kiếm và lọc mạnh mẽ để thay thế Ctrl+F trên Notion.

**Tìm kiếm:**

- Tìm theo từ tiếng Anh (fuzzy search).
- Tìm theo nghĩa tiếng Việt.

**Lọc (Filter):**

- Theo Collection/chủ đề.
- Theo CEFR level (A1, A2, B1, B2, C1, C2).
- Theo loại từ (noun, verb, adjective, adverb, ...).
- Theo usage (formal, informal, slang, ...).

**Sắp xếp (Sort):**

- Theo ngày thêm (mới nhất / cũ nhất).
- Theo alphabet (A→Z / Z→A).
- Theo level (thấp → cao / cao → thấp).

**Kết hợp:** Có thể kết hợp nhiều bộ lọc cùng lúc.

### 2.5 F05 — Thống kê (Statistics Dashboard)

**Mô tả:** Dashboard hiển thị các thống kê về quá trình học từ vựng.

**Các chỉ số:**

1. **Tổng số từ vựng đã ghi** — con số tổng quan.
2. **Biểu đồ streak** — số từ mới thêm theo ngày/tuần/tháng.
3. **Phân bố theo level** — pie chart hoặc bar chart: bao nhiêu từ B1, B2, C1, C2...
4. **Phân bố theo Collection** — bar chart: collection nào có nhiều từ nhất.

### 2.6 F06 — Quản lý tài khoản & Settings (Account & Settings)

**Authentication:**

- Đăng ký / Đăng nhập bằng Email + Password.
- Đăng nhập bằng Google Sign-In.
- Supabase Auth xử lý toàn bộ.

**Settings:**

- **AI Provider:** Chọn giữa Gemini và OpenRouter.
- **AI Model:** Chọn model cụ thể từ provider đã chọn.
- **Notification:** Cấu hình thông báo (xem F03).
- **Data:** Export/Import dữ liệu (CSV/JSON) — hỗ trợ migrate từ Notion hoặc các nguồn khác. (nice-to-have, Phase 1).

### 2.7 F07 — Offline & Sync (Offline-First Architecture)

**Mô tả:** App hoạt động offline hoàn toàn cho các thao tác CRUD. Sync dữ liệu khi có mạng.

**Offline capabilities:**

- ✅ Xem tất cả từ vựng đã lưu.
- ✅ Thêm từ vựng mới (tự điền tay, không có AI/Dictionary).
- ✅ Sửa từ vựng.
- ✅ Xóa từ vựng.
- ✅ Tìm kiếm và lọc.
- ✅ Xem statistics.
- ❌ Gọi Dictionary API (cần mạng).
- ❌ Gọi AI API (cần mạng).

**Sync strategy:**

- Khi có mạng → tự động sync các thay đổi offline lên Supabase.
- Conflict resolution: Last-write-wins (đơn giản, phù hợp cho <10 users, mỗi user chỉ sửa data của mình).

---

## 3. User Stories

### 3.1 Note từ vựng

| ID    | User Story                                                                                                             | Priority   |
| ----- | ---------------------------------------------------------------------------------------------------------------------- | ---------- |
| US-01 | Là người dùng, tôi muốn nhập từ tiếng Anh và app tự động điền tất cả thông tin để tôi không phải tra từ điển thủ công. | **Must**   |
| US-02 | Là người dùng, tôi muốn xem tất cả nghĩa của từ và chọn những nghĩa tôi muốn lưu.                                      | **Must**   |
| US-03 | Là người dùng, tôi muốn sửa bất kỳ field nào mà AI/Dictionary đã điền.                                                 | **Must**   |
| US-04 | Là người dùng, tôi muốn được cảnh báo khi nhập từ + nghĩa đã lưu trước đó.                                             | **Must**   |
| US-05 | Là người dùng, tôi muốn tự điền tay tất cả field mà không dùng API.                                                    | **Should** |

### 3.2 Collection

| ID    | User Story                                                          | Priority   |
| ----- | ------------------------------------------------------------------- | ---------- |
| US-06 | Là người dùng, tôi muốn AI tự gợi ý Collection cho mỗi từ vựng mới. | **Must**   |
| US-07 | Là người dùng, tôi muốn tạo Collection riêng theo ý mình.           | **Must**   |
| US-08 | Là người dùng, tôi muốn xem tất cả từ trong một Collection.         | **Must**   |
| US-09 | Là người dùng, tôi muốn gán/bỏ gán từ khỏi Collection.              | **Should** |

### 3.3 Ôn tập & Thông báo

| ID    | User Story                                                                                                      | Priority   |
| ----- | --------------------------------------------------------------------------------------------------------------- | ---------- |
| US-10 | Là người dùng, tôi muốn ôn tập ngẫu nhiên 1 từ mỗi ngày qua Daily Widget trên Dashboard hoặc Push Notification. | **Should** |
| US-11 | Là người dùng, tôi muốn chọn chế độ nhắc nhở nhẹ hoặc quiz nhanh (flashcard).                                   | **Should** |

### 3.4 Tìm kiếm & Thống kê

| ID    | User Story                                                             | Priority   |
| ----- | ---------------------------------------------------------------------- | ---------- |
| US-12 | Là người dùng, tôi muốn tìm kiếm từ theo tiếng Anh hoặc tiếng Việt.    | **Must**   |
| US-13 | Là người dùng, tôi muốn lọc từ theo level, loại từ, usage, collection. | **Must**   |
| US-14 | Là người dùng, tôi muốn xem thống kê tổng quan về quá trình học.       | **Should** |

### 3.5 Offline & Sync

| ID    | User Story                                                        | Priority |
| ----- | ----------------------------------------------------------------- | -------- |
| US-15 | Là người dùng, tôi muốn xem và quản lý từ vựng khi không có mạng. | **Must** |
| US-16 | Là người dùng, tôi muốn dữ liệu tự động đồng bộ khi có mạng.      | **Must** |

---

## 4. Yêu cầu phi chức năng

| ID     | Yêu cầu                 | Mô tả                                                                                                    |
| ------ | ----------------------- | -------------------------------------------------------------------------------------------------------- |
| NFR-01 | **Performance**         | Thời gian load app < 5 giây. Lookup từ vựng < 8 giây.                                                    |
| NFR-02 | **Offline**             | Cả Web App và Mobile App đều hỗ trợ offline CRUD thông qua local database (IndexedDB cho Web, SQLite cho Mobile). Sync khi có mạng. |
| NFR-03 | **Security**            | API key AI quản lý trên server, không expose cho client.                                                 |
| NFR-04 | **Scalability**         | Hỗ trợ tối thiểu 10 users đồng thời.                                                                     |
| NFR-05 | **Cost**                | Toàn bộ hạ tầng phải nằm trong free tier (Vercel, Supabase, AI APIs).                                    |
| NFR-06 | **Cross-platform sync** | Dữ liệu đồng bộ realtime giữa Web và Mobile (Phase 2).                                                   |
| NFR-07 | **Data ownership**      | Mỗi user chỉ truy cập dữ liệu của mình (RLS).                                                            |

---

## 5. Phạm vi ngoài (Out of Scope) — Phase 1

- ❌ Mobile App (Flutter) — Phase 2.
- ❌ Spaced Repetition System (SRS) nâng cao — có thể xem xét sau.
- ❌ Chia sẻ Collection giữa các users.
- ❌ Gamification (huy hiệu, leaderboard).
- ❌ Publish lên App Store / Google Play.
- ❌ Hỗ trợ ngôn ngữ khác ngoài Anh → Việt.

---

## 6. Glossary

| Thuật ngữ         | Định nghĩa                                                              |
| ----------------- | ----------------------------------------------------------------------- |
| **Collection**    | Bộ sưu tập từ vựng theo chủ đề (ví dụ: Travel, Business).               |
| **CEFR Level**    | Khung tham chiếu châu Âu về ngôn ngữ (A1→C2).                           |
| **IPA**           | International Phonetic Alphabet — bảng phiên âm quốc tế.                |
| **RLS**           | Row Level Security — chính sách bảo mật cấp dòng của Supabase/Postgres. |
| **Offline-first** | Kiến trúc ưu tiên hoạt động offline, sync khi có mạng.                  |
| **Edge Function** | Serverless function chạy trên Supabase Edge (Deno runtime).             |
