# Mewmory — User Flow Document

> **Version:** 1.0
> **Last Updated:** 2026-08-25
> **Related:** [PRD.md](file:///f:/Side%20Projects/mewmory/docs/PRD.md)
> **Status:** Draft — Pending Review

---

## 1. Authentication Flows

### 1.1 Đăng ký (Sign Up)

```mermaid
flowchart TD
    A["Mở app"] --> B{"Đã đăng nhập?"}
    B -->|Có| C["→ Dashboard"]
    B -->|Không| D["Hiển thị Login Page"]
    D --> E["Nhấn 'Đăng ký'"]
    E --> F["Nhập Email + Password"]
    F --> G["Nhấn 'Tạo tài khoản'"]
    G --> H{"Validation OK?"}
    H -->|Không| I["Hiển thị lỗi"]
    I --> F
    H -->|Có| J["Supabase tạo user"]
    J --> K["Auto-create: profile + default collection + settings"]
    K --> C
```

### 1.2 Đăng nhập (Sign In)

```mermaid
flowchart TD
    A["Login Page"] --> B{"Chọn phương thức"}
    B -->|Email/Password| C["Nhập Email + Password"]
    C --> D["Nhấn 'Đăng nhập'"]
    D --> E{"Auth thành công?"}
    E -->|Không| F["Hiển thị lỗi"]
    F --> C
    E -->|Có| G["Lưu JWT token"]
    B -->|Google| H["Nhấn 'Đăng nhập với Google'"]
    H --> I["Google OAuth flow"]
    I --> E
    G --> J["Sync pull dữ liệu từ server"]
    J --> K["→ Dashboard"]
```

---

## 2. Core Flow: Note từ vựng thông minh

### 2.1 Happy Path

```mermaid
flowchart TD
    A["Dashboard / Vocabulary List"] --> B["Nhấn nút '+ Thêm từ mới'"]
    B --> C["Trang Add Word"]
    C --> D["Gõ từ tiếng Anh: 'resilient'"]
    D --> D1{"Từ đã tồn tại?\n(kiểm tra real-time)"}
    D1 -->|"Có"| D2["Hiển thị badge:\n'Từ này đã có X entries'"]
    D2 --> E["Nhấn 'Lookup' hoặc Enter"]
    D1 -->|"Không / Bỏ qua"| E
    E --> F{"Có mạng?"}
    F -->|Có| G["Loading... gọi Edge Function"]
    G --> H["Edge Function gọi song song:\n• Dictionary API\n• AI API"]
    H --> I["Hiển thị kết quả:\n• Phiên âm: /rɪˈzɪl.i.ənt/\n• Loại từ: adjective\n• Level: C1\n• Usage: formal\n• Tất cả nghĩa EN + VI"]
    I --> J["User tích chọn nghĩa muốn lưu"]
    J --> K{"Cần sửa field nào?"}
    K -->|Có| L["Sửa field\n(click vào field → edit)"]
    L --> K
    K -->|Không| M["Xem Collection gợi ý"]
    M --> N{"Chọn Collection"}
    N -->|AI gợi ý| O["Chấp nhận gợi ý"]
    N -->|Tự chọn| P["Chọn Collection có sẵn"]
    N -->|Tạo mới| Q["Tạo Collection mới"]
    O --> R["Nhấn 'Save'"]
    P --> R
    Q --> R
    R --> S["Lưu vào IndexedDB"]
    S --> T{"Online?"}
    T -->|Có| U["Sync lên Supabase"]
    T -->|Không| V["Thêm vào sync_queue"]
    U --> W["✅ Toast: 'Đã lưu thành công!'"]
    V --> W
    W --> X["Quay lại Vocabulary List"]

    F -->|Không| Y["Hiển thị form trống\n+ thông báo 'Offline mode'"]
    Y --> Z["User tự điền tay tất cả field"]
    Z --> R
```

### 2.2 Duplicate Warning Flow

```mermaid
flowchart TD
    A["User nhấn 'Save'"] --> B["Kiểm tra trùng trong IndexedDB"]
    B --> C{"Trùng từ + trùng nghĩa?"}
    C -->|Không| D["Lưu bình thường"]
    C -->|Có| E["⚠️ Hiển thị Warning:\n'Bạn đã lưu từ này\nvới nghĩa tương tự!'"]
    E --> F["Hiển thị entry cũ để so sánh"]
    F --> G{"User chọn?"}
    G -->|"Lưu bản mới"| H["Lưu song song"]
    G -->|"Xem entry cũ"| I["→ Word Detail Page"]
    G -->|"Hủy"| J["Quay lại form"]
```

---

## 3. Collection Management Flow

### 3.1 Xem Collections

```mermaid
flowchart TD
    A["Sidebar: nhấn 'Collections'"] --> B["Trang Collections List"]
    B --> C["Hiển thị tất cả Collections\nvới số lượng từ mỗi collection"]
    C --> D{"Action?"}
    D -->|"Xem"| E["Nhấn vào Collection"]
    E --> F["Trang Collection Detail\nDanh sách từ trong collection"]
    D -->|"Tạo mới"| G["Nhấn '+ Tạo Collection'"]
    G --> H["Nhập tên + mô tả"]
    H --> I["Nhấn 'Tạo'"]
    I --> C
    D -->|"Sửa"| J["Nhấn icon edit"]
    J --> K["Sửa tên / mô tả"]
    K --> C
    D -->|"Xóa"| L["Nhấn icon xóa"]
    L --> M["Confirm dialog"]
    M -->|"Xóa"| N["Soft delete\n(từ vựng không bị xóa)"]
    N --> C
```

---

## 4. Search & Filter Flow

```mermaid
flowchart TD
    A["Trang Vocabulary List"] --> B["Search bar ở trên cùng"]
    B --> C["Gõ tìm kiếm (debounced 300ms)"]
    C --> D["Tìm trong IndexedDB:\n• word LIKE '%search%'\n• definition_vi LIKE '%search%'"]
    D --> E["Hiển thị kết quả"]

    A --> F["Nhấn icon 'Filter'"]
    F --> G["Mở Filter Panel"]
    G --> H["Chọn filters:"]
    H --> I["☐ Level: B1, B2, C1..."]
    H --> J["☐ Loại từ: noun, verb..."]
    H --> K["☐ Usage: formal, slang..."]
    H --> L["☐ Collection: Travel..."]
    I --> M["Apply filters"]
    J --> M
    K --> M
    L --> M
    M --> E

    A --> N["Sort dropdown"]
    N --> O["Chọn: Mới nhất / A→Z / Level"]
    O --> E
```

---

## 5. Settings Flow

```mermaid
flowchart TD
    A["Sidebar: nhấn 'Settings'"] --> B["Trang Settings"]
    B --> C["Sections:"]
    C --> D["🤖 AI Settings"]
    D --> D1["Chọn Provider: Gemini / OpenRouter"]
    D1 --> D2["Chọn Model từ provider"]
    C --> E["🔔 Notification Settings"]
    E --> E1["Toggle bật/tắt"]
    E1 --> E2["Chọn mode: Nhắc nhở / Quiz"]
    E2 --> E3["Chọn giờ nhận"]
    E3 --> E4["Chọn Collection nguồn"]
    C --> F["👤 Account"]
    F --> F1["Xem email, tên"]
    F1 --> F2["Đổi tên hiển thị"]
    F2 --> F3["Đăng xuất"]
```

---

## 6. Offline/Online Transition

```mermaid
flowchart TD
    A["App đang chạy"] --> B{"Trạng thái mạng?"}
    B -->|Online| C["Hiển thị bình thường\nTất cả chức năng khả dụng"]
    C --> D["User thao tác"]
    D --> E["Write → IndexedDB + Supabase"]

    B -->|Offline| F["Hiển thị 'Offline' badge"]
    F --> G["Ẩn/Disable nút 'Lookup'\n(vì cần API)"]
    G --> H["User vẫn có thể:\n• Xem từ vựng\n• Thêm (tự điền)\n• Sửa, Xóa\n• Tìm kiếm, Lọc"]
    H --> I["Write → IndexedDB + sync_queue"]

    I --> J{"Có mạng lại?"}
    J -->|Có| K["Sync Engine tự động:\n1. Push sync_queue\n2. Pull server changes"]
    K --> L["✅ Toast: 'Đã đồng bộ X thay đổi'"]
    L --> C
```

---

## 7. Dashboard & Daily Review Flow

```mermaid
flowchart TD
    A["Sidebar: nhấn 'Dashboard'"] --> B["Trang Dashboard"]
    B --> C["Load dữ liệu từ IndexedDB"]
    C --> D["Hiển thị 2 khu vực chính:"]
    D --> W["💡 1. Daily Review Widget (Flashcard / Gentle)"]
    W --> W1["Nghe phát âm / Lật thẻ xem nghĩa / Next Word"]
    D --> S["📊 2. Statistics Overview"]
    S --> E["Tổng từ vựng: 247"]
    S --> F["🔥 Streak Chart (30 ngày gần nhất)"]
    S --> G["📈 Phân bố Level (Pie Chart)"]
    S --> H["📚 Phân bố Collection (Bar Chart)"]
    E --> I{"Click vào số?"}
    I -->|Có| J["→ Vocabulary List (tất cả)"]
    G --> K{"Click vào segment?"}
    K -->|Có| L["→ Vocabulary List (filtered by level)"]
    H --> M{"Click vào bar?"}
    M -->|Có| N["→ Collection Detail"]
```

---

## 8. Page Navigation Map

```mermaid
flowchart LR
    Login["Login Page"]
    Dashboard["Dashboard\n(Statistics)"]
    VocabList["Vocabulary\nList"]
    AddWord["Add Word"]
    WordDetail["Word\nDetail"]
    Collections["Collections\nList"]
    CollDetail["Collection\nDetail"]
    Settings["Settings"]

    Login -->|auth| Dashboard
    Dashboard -->|sidebar| VocabList
    Dashboard -->|sidebar| Collections
    Dashboard -->|sidebar| Settings
    Dashboard -->|"click stat"| VocabList
    Dashboard -->|"click collection"| CollDetail

    VocabList -->|"+ Add"| AddWord
    VocabList -->|"click word"| WordDetail
    VocabList -->|sidebar| Dashboard
    VocabList -->|sidebar| Collections

    AddWord -->|save| VocabList
    AddWord -->|cancel| VocabList
    AddWord -->|"view dup"| WordDetail

    WordDetail -->|back| VocabList
    WordDetail -->|"edit"| WordDetail

    Collections -->|"click"| CollDetail
    Collections -->|sidebar| Dashboard
    Collections -->|sidebar| VocabList

    CollDetail -->|"click word"| WordDetail
    CollDetail -->|back| Collections

    Settings -->|sidebar| Dashboard
    Settings -->|logout| Login
```
