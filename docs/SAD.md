# Mewmory — Software Architecture Document (SAD)

> **Version:** 1.0
> **Last Updated:** 2026-08-25
> **Related:** [PRD.md](file:///f:/Side%20Projects/mewmory/docs/PRD.md)
> **Status:** Draft — Pending Review

---

## 1. Tổng quan kiến trúc

### 1.1 Architecture Style

**Offline-First Client-Server Architecture** với:

- **Client (Web):** Vite + React SPA — xử lý UI, local storage, offline CRUD.
- **Client (Mobile):** Flutter (Phase 2) — offline-first với SQLite.
- **Backend:** Supabase (BaaS) — Auth, PostgreSQL, Edge Functions, Realtime.
- **External Services:** Free Dictionary API, AI APIs (Gemini, OpenRouter).

### 1.2 High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      CLIENTS                            │
│  ┌──────────────────┐    ┌───────────────────────────┐  │
│  │   Web App (P1)   │    │   Mobile App (P2)         │  │
│  │   Vite + React   │    │   Flutter                 │  │
│  │   IndexedDB      │    │   SQLite                  │  │
│  │   (Dexie.js)     │    │   (drift/sqflite)         │  │
│  └────────┬─────────┘    └──────────┬────────────────┘  │
│           │                         │                    │
│           └─────────┬───────────────┘                    │
│                     │ HTTPS                              │
└─────────────────────┼────────────────────────────────────┘
                      │
┌─────────────────────┼────────────────────────────────────┐
│              SUPABASE CLOUD                              │
│                     │                                    │
│  ┌──────────────────▼───────────────────────────────┐   │
│  │              Supabase Gateway                     │   │
│  │         (Auth + API Router)                       │   │
│  └──────┬──────────────┬────────────────┬───────────┘   │
│         │              │                │                │
│  ┌──────▼──────┐ ┌─────▼──────┐ ┌──────▼──────────┐    │
│  │  Supabase   │ │ PostgreSQL │ │ Edge Functions  │    │
│  │    Auth     │ │  Database  │ │  (Deno)         │    │
│  │             │ │  + RLS     │ │                 │    │
│  │ - Email/Pwd │ │            │ │ - AI Proxy      │    │
│  │ - Google    │ │            │ │ - Dictionary    │    │
│  └─────────────┘ └────────────┘ │   Proxy         │    │
│                                  └──────┬──────────┘    │
│                                         │                │
└─────────────────────────────────────────┼────────────────┘
                                          │
┌─────────────────────────────────────────┼────────────────┐
│              EXTERNAL SERVICES          │                │
│                                         │                │
│  ┌──────────────────┐  ┌───────────────▼──────────────┐ │
│  │ Free Dictionary  │  │     AI APIs                  │ │
│  │ API              │  │  ┌─────────┐ ┌────────────┐  │ │
│  │ dictionaryapi.dev│  │  │ Gemini  │ │ OpenRouter │  │ │
│  └──────────────────┘  │  └─────────┘ └────────────┘  │ │
│                        └──────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Client Architecture (Web App — Phase 1)

### 2.1 Tech Stack

| Layer                | Technology            | Lý do                            |
| -------------------- | --------------------- | -------------------------------- |
| **Build Tool**       | Vite                  | Nhanh, nhẹ, HMR tốt              |
| **UI Framework**     | React 18+             | Thành thạo, ecosystem lớn        |
| **Styling**          | TailwindCSS           | Thành thạo, nhanh                |
| **Routing**          | React Router v6       | SPA routing                      |
| **State Management** | Zustand               | Nhẹ, đơn giản, ít boilerplate    |
| **Local Database**   | Dexie.js (IndexedDB)  | Offline-first, reactive queries  |
| **Supabase Client**  | @supabase/supabase-js | Auth, DB operations, Realtime    |
| **Charts**           | Recharts              | Lightweight, React-native charts |
| **HTTP Client**      | Fetch API (built-in)  | Đơn giản, không cần thêm lib     |

### 2.2 Project Structure

```
src/
├── main.jsx                    # Entry point
├── App.jsx                     # Root component + routing
├── config/
│   └── supabase.js             # Supabase client init
│
├── db/
│   ├── database.js             # Dexie.js database definition
│   ├── schemas.js              # IndexedDB table schemas
│   └── sync.js                 # Sync engine (local ↔ server)
│
├── services/
│   ├── dictionary.service.js   # Free Dictionary API client
│   ├── ai/
│   │   ├── ai.service.js       # AI abstraction layer
│   │   ├── gemini.provider.js  # Gemini API implementation
│   │   └── openrouter.provider.js # OpenRouter implementation
│   ├── vocabulary.service.js   # Vocabulary CRUD operations
│   ├── collection.service.js   # Collection CRUD operations
│   ├── auth.service.js         # Authentication operations
│   └── notification.service.js # Web Push notification
│
├── stores/
│   ├── auth.store.js           # Auth state (Zustand)
│   ├── vocabulary.store.js     # Vocabulary state
│   ├── collection.store.js     # Collection state
│   ├── settings.store.js       # User settings state
│   └── ui.store.js             # UI state (modals, loading, etc.)
│
├── hooks/
│   ├── useOnlineStatus.js      # Network status hook
│   ├── useSync.js              # Auto-sync hook
│   └── useDebouncedSearch.js   # Debounced search hook
│
├── pages/
│   ├── LoginPage.jsx
│   ├── DashboardPage.jsx       # Home + Statistics
│   ├── VocabularyPage.jsx      # Vocabulary list + search/filter
│   ├── AddWordPage.jsx         # Smart vocabulary input
│   ├── WordDetailPage.jsx      # Word detail view/edit
│   ├── CollectionsPage.jsx     # Collection list
│   ├── CollectionDetailPage.jsx
│   └── SettingsPage.jsx
│
├── components/
│   ├── layout/
│   │   ├── Sidebar.jsx
│   │   ├── Header.jsx
│   │   └── MainLayout.jsx
│   ├── vocabulary/
│   │   ├── WordCard.jsx
│   │   ├── WordForm.jsx
│   │   ├── LookupResult.jsx
│   │   ├── MeaningSelector.jsx
│   │   ├── DuplicateWarning.jsx
│   │   └── FilterBar.jsx
│   ├── collection/
│   │   ├── CollectionCard.jsx
│   │   └── CollectionForm.jsx
│   ├── statistics/
│   │   ├── StatsOverview.jsx
│   │   ├── StreakChart.jsx
│   │   ├── LevelDistribution.jsx
│   │   └── CollectionDistribution.jsx
│   └── common/
│       ├── Button.jsx
│       ├── Input.jsx
│       ├── Modal.jsx
│       ├── Toast.jsx
│       ├── LoadingSpinner.jsx
│       └── OfflineBadge.jsx
│
└── utils/
    ├── constants.js            # CEFR levels, part of speech, usage types
    ├── formatters.js           # Date, text formatters
    └── validators.js           # Input validation
```

### 2.3 Routing

| Route              | Page                 | Auth Required |
| ------------------ | -------------------- | ------------- |
| `/login`           | LoginPage            | ❌            |
| `/`                | DashboardPage        | ✅            |
| `/vocabulary`      | VocabularyPage       | ✅            |
| `/vocabulary/add`  | AddWordPage          | ✅            |
| `/vocabulary/:id`  | WordDetailPage       | ✅            |
| `/collections`     | CollectionsPage      | ✅            |
| `/collections/:id` | CollectionDetailPage | ✅            |
| `/settings`        | SettingsPage         | ✅            |

---

## 3. Backend Architecture (Supabase)

### 3.1 Supabase Services Used

| Service                   | Usage                                  |
| ------------------------- | -------------------------------------- |
| **Auth**                  | Email/Password + Google OAuth          |
| **Database (PostgreSQL)** | Persistent storage, RLS policies       |
| **Edge Functions**        | AI API proxy, Dictionary API proxy     |
| **Realtime**              | Sync giữa devices (Phase 2 - optional) |
| **Storage**               | Không cần trong Phase 1                |

### 3.2 Edge Functions

#### `lookup-word`

- **Trigger:** POST request từ client.
- **Input:** `{ word: string, provider: "gemini" | "openrouter", model?: string }`
- **Logic:**
  1. Gọi song song Free Dictionary API + AI API.
  2. Merge kết quả.
  3. Trả về dữ liệu đã structured.
- **Output:** `{ phonetic, partOfSpeech, level, usage, definitions[], examples[], suggestedCollections[] }`

```
Client                    Edge Function              External APIs
  │                           │                           │
  │  POST /lookup-word        │                           │
  │  { word: "resilient" }    │                           │
  │ ─────────────────────────>│                           │
  │                           │  GET dictionaryapi.dev    │
  │                           │ ─────────────────────────>│
  │                           │                           │
  │                           │  POST AI API              │
  │                           │ ─────────────────────────>│
  │                           │                           │
  │                           │<──── Dictionary response  │
  │                           │<──── AI response          │
  │                           │                           │
  │                           │  Merge & Structure        │
  │                           │                           │
  │  { phonetic, level,       │                           │
  │    definitions[], ... }   │                           │
  │ <─────────────────────────│                           │
```

#### `ai-proxy`

- **Trigger:** POST request từ `lookup-word` hoặc trực tiếp từ client cho các tác vụ AI khác.
- **Logic:** Route request đến AI provider được chọn (Gemini / OpenRouter).
- **Security:** API keys lưu trong Supabase Secrets (environment variables).

### 3.3 Row Level Security (RLS)

Tất cả bảng dữ liệu người dùng đều bật RLS:

```sql
-- Ví dụ policy cho bảng vocabularies
CREATE POLICY "Users can only access own vocabularies"
ON vocabularies FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```

Nguyên tắc: **Mỗi user chỉ CRUD được dữ liệu của mình.**

---

## 4. Offline-First Architecture

### 4.1 Data Flow

```
┌─────────────────────────────────────────────────┐
│                    CLIENT                        │
│                                                  │
│  ┌────────────┐     ┌────────────────────────┐  │
│  │  React UI  │────>│  Service Layer         │  │
│  │            │<────│  (vocabulary.service)   │  │
│  └────────────┘     └───────────┬────────────┘  │
│                                  │               │
│                     ┌────────────▼────────────┐  │
│                     │  Local DB (Dexie.js)    │  │
│                     │  IndexedDB              │  │
│                     │                         │  │
│                     │  - vocabularies         │  │
│                     │  - collections          │  │
│                     │  - vocab_collections    │  │
│                     │  - sync_queue           │  │
│                     └────────────┬────────────┘  │
│                                  │               │
│                     ┌────────────▼────────────┐  │
│                     │  Sync Engine            │  │
│                     │  (sync.js)              │  │
│                     │                         │  │
│                     │  - Detects online       │  │
│                     │  - Processes sync_queue │  │
│                     │  - Pulls server changes │  │
│                     │  - Conflict resolution  │  │
│                     └────────────┬────────────┘  │
│                                  │               │
└──────────────────────────────────┼───────────────┘
                                   │ Online only
                      ┌────────────▼────────────┐
                      │  Supabase PostgreSQL    │
                      │  (Source of Truth)      │
                      └─────────────────────────┘
```

### 4.2 Sync Strategy

**Approach: Sync Queue + Last-Write-Wins**

1. **Mọi write operation** đều write vào local DB trước (IndexedDB).
2. Đồng thời, tạo một entry trong **sync_queue** table ghi lại thao tác (CREATE/UPDATE/DELETE).
3. Khi có mạng, **Sync Engine** xử lý queue:
   - Push các thay đổi local lên Supabase.
   - Pull các thay đổi từ server (dựa trên `updated_at` timestamp).
4. **Conflict resolution:** Last-write-wins dựa trên `updated_at`.
   - Hợp lý vì <10 users, mỗi user chỉ sửa data của mình.

**sync_queue record:**

```json
{
  "id": "uuid",
  "table_name": "vocabularies",
  "record_id": "uuid",
  "operation": "CREATE | UPDATE | DELETE",
  "payload": { ... },
  "created_at": "timestamp",
  "synced": false
}
```

### 4.3 Online/Offline Detection

```javascript
// useOnlineStatus hook
// - navigator.onLine + window events (online/offline)
// - Khi online → trigger sync
// - Khi offline → show OfflineBadge, disable API features
```

---

## 5. AI Abstraction Layer

### 5.1 Provider Interface

```
┌─────────────────────────────────────────────────┐
│             AI Service (ai.service.js)           │
│                                                  │
│  ┌─────────────────────────────────────────────┐│
│  │  lookupWord(word) → structured data         ││
│  │  classifyCollection(word, existingCols)      ││
│  │  translateDefinitions(definitions)           ││
│  └───────────────────────┬─────────────────────┘│
│                          │                       │
│  ┌───────────────────────▼─────────────────────┐│
│  │        Provider Router                       ││
│  │  (based on user settings)                    ││
│  └──────┬──────────────────────┬───────────────┘│
│         │                      │                 │
│  ┌──────▼──────────┐  ┌───────▼───────────────┐│
│  │ GeminiProvider  │  │ OpenRouterProvider    ││
│  │                 │  │                       ││
│  │ - API endpoint  │  │ - API endpoint        ││
│  │ - Auth header   │  │ - Auth header         ││
│  │ - Response      │  │ - Response            ││
│  │   mapping       │  │   mapping             ││
│  └─────────────────┘  └───────────────────────┘│
└─────────────────────────────────────────────────┘
```

### 5.2 AI Prompt Design

AI được gọi qua Edge Function với structured prompt để trả về JSON:

```
Given the English word "{word}", provide:
1. CEFR level (A1/A2/B1/B2/C1/C2)
2. Usage register (formal/informal/slang/neutral/vulgar/technical)
3. Vietnamese translations for each meaning
4. Example sentences (if not provided by dictionary)
5. Suggested topic categories (e.g., Travel, Business, Technology)

Respond in JSON format: { level, usage, vietnameseDefinitions[], examples[], suggestedCollections[] }
```

---

## 6. Security Architecture

### 6.1 Authentication Flow

```
Client                 Supabase Auth              Google OAuth
  │                        │                          │
  │  Login (email/pwd)     │                          │
  │ ──────────────────────>│                          │
  │  JWT + Refresh Token   │                          │
  │ <──────────────────────│                          │
  │                        │                          │
  │  OR: Google Sign-In    │                          │
  │ ──────────────────────>│ ────────────────────────>│
  │                        │ <────────────────────────│
  │  JWT + Refresh Token   │                          │
  │ <──────────────────────│                          │
  │                        │                          │
  │  API calls with JWT    │                          │
  │ ──────────────────────>│                          │
  │  (RLS enforced)        │                          │
```

### 6.2 API Key Security

| Key                         | Storage               | Exposure               |
| --------------------------- | --------------------- | ---------------------- |
| Supabase `anon` key         | Client-side (public)  | OK — RLS protects data |
| Supabase `service_role` key | Edge Function env var | Server-only            |
| Gemini API key              | Edge Function env var | Server-only            |
| OpenRouter API key          | Edge Function env var | Server-only            |

---

## 7. Deployment Architecture

```
┌────────────────────────────────────────────────────┐
│                   PRODUCTION                        │
│                                                     │
│  ┌─────────────────┐    ┌────────────────────────┐ │
│  │    Vercel        │    │   Supabase Cloud       │ │
│  │                  │    │                        │ │
│  │  - React SPA     │    │  - PostgreSQL          │ │
│  │  - Static assets │    │  - Auth                │ │
│  │  - CDN           │    │  - Edge Functions      │ │
│  │  - Auto HTTPS    │    │  - Realtime            │ │
│  │                  │    │  - Auto backups        │ │
│  │  Free tier:      │    │                        │ │
│  │  100GB bandwidth │    │  Free tier:            │ │
│  │                  │    │  500MB DB              │ │
│  │                  │    │  50K auth users        │ │
│  │                  │    │  500K Edge invocations │ │
│  └─────────────────┘    └────────────────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │             CI/CD                            │   │
│  │  GitHub → Vercel (auto-deploy on push)      │   │
│  │  Supabase CLI → Edge Functions deploy       │   │
│  └─────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────┘
```

### 7.1 Free Tier Estimation

| Service           | Free Tier              | Estimated Usage (10 users)    | Headroom   |
| ----------------- | ---------------------- | ----------------------------- | ---------- |
| **Vercel**        | 100GB bandwidth/month  | ~1GB                          | ✅ Rất dư  |
| **Supabase DB**   | 500MB                  | ~50MB (10K words × 10 users)  | ✅ Rất dư  |
| **Supabase Auth** | 50K MAU                | 10                            | ✅ Rất dư  |
| **Supabase Edge** | 500K invocations/month | ~3K (10 users × 10 words/day) | ✅ Rất dư  |
| **Gemini API**    | 15 RPM (free)          | ~10 RPM peak                  | ✅ Đủ dùng |
| **OpenRouter**    | Varies by model        | Backup option                 | ✅ Backup  |

---

## 8. Error Handling Strategy

### 8.1 Graceful Degradation

| Scenario              | Behavior                                                             |
| --------------------- | -------------------------------------------------------------------- |
| Dictionary API down   | Chỉ dùng AI cho tất cả fields. Hiển thị warning.                     |
| AI API down           | Chỉ dùng Dictionary API. Level/Usage/Vietnamese trống, user tự điền. |
| Cả hai API down       | Cho phép nhập thủ công hoàn toàn.                                    |
| Supabase down         | App vẫn hoạt động offline. Queue sync cho khi server khả dụng.       |
| Network lost mid-sync | Rollback partial sync. Retry khi có mạng.                            |

### 8.2 User Feedback

- **Loading states:** Skeleton UI khi đang lookup.
- **Error messages:** Toast notification rõ ràng, không technical jargon.
- **Offline indicator:** Badge/banner hiển thị trạng thái offline.
- **Sync status:** Icon hiển thị trạng thái sync (synced / pending / error).

---

## 9. Technology Decisions Log

| Decision         | Chosen                  | Alternatives Considered    | Rationale                                                             |
| ---------------- | ----------------------- | -------------------------- | --------------------------------------------------------------------- |
| Local DB (Web)   | Dexie.js (IndexedDB)    | localStorage, PouchDB      | Dexie: reactive queries, lớn hơn localStorage (>5MB), nhẹ hơn PouchDB |
| State Management | Zustand                 | Redux, Jotai, Context API  | Zustand: minimal boilerplate, đơn giản, đủ cho app size này           |
| AI Abstraction   | Custom provider pattern | LangChain.js               | LangChain quá nặng cho use case đơn giản này                          |
| Sync Strategy    | Custom sync queue       | PouchDB+CouchDB, PowerSync | Đơn giản hơn, không cần thêm service, phù hợp <10 users               |
| Charts           | Recharts                | Chart.js, D3               | Recharts: React-native, declarative, nhẹ                              |
