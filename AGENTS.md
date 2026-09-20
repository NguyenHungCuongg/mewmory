# Mewmory — Project Context for AI Agents

> **Last Updated:** 2026-09-17
> **Status:** Alpha — Core features done, production-readiness in progress

---

## 1. Sản phẩm là gì?

**Mewmory** là ứng dụng ghi chép từ vựng tiếng Anh thông minh cho người Việt. Người dùng chỉ cần nhập từ tiếng Anh → app tự động tra Dictionary API + AI để điền phiên âm, loại từ, CEFR level, nghĩa tiếng Việt, ví dụ, và gợi ý Collection. Hỗ trợ offline-first, đồng bộ cross-platform.

- **Đối tượng:** App nội bộ ~10 người (developer và bạn bè)
- **Ngôn ngữ UI:** Tiếng Việt (có i18n EN/VI)

---

## 2. Tech Stack

### Web App (`web/`)
| Layer | Technology |
|-------|-----------|
| Framework | React 19 + Vite 8 |
| Language | JavaScript (JSX), TypeScript config có nhưng code chính viết JS |
| Styling | Tailwind CSS v4 |
| State | Zustand v4 |
| Routing | React Router DOM v6 |
| Local DB | Dexie.js (IndexedDB wrapper) — offline-first |
| Charts | Recharts |
| i18n | i18next + react-i18next |
| Testing | Vitest + @testing-library/react + jsdom + fake-indexeddb |

### Backend (`supabase/`)
| Layer | Technology |
|-------|-----------|
| Auth | Supabase Auth (Email + Google OAuth) |
| Database | Supabase PostgreSQL |
| Edge Functions | Deno (Supabase Edge Functions) |
| RLS | Row Level Security policies trên mọi table |

### Mobile App (`mobile/`) — **Chưa triển khai, có plan**
| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.24+ / Dart 3.5+ |
| State | Riverpod |
| Local DB | Drift (SQLite) — read cache |
| Routing | GoRouter |
| Platform | Android only (debug APK) |

### CI/CD
- GitHub Actions: `ci.yml` — chạy `npm test` trên push/PR tới `main`/`dev`
- **Chưa có auto-deploy** (Vercel hoặc tương đương)

---

## 3. Cấu trúc Project

```
mewmory/
├── .agents/                    # Antigravity customizations
│   ├── rules/                  # Coding rules (Karpathy principles, etc.)
│   └── skills/                 # AI agent skills (design, UI, etc.)
├── .github/workflows/ci.yml    # GitHub Actions CI
├── web/                        # React Web App (Phase 1 — DONE)
│   ├── src/
│   │   ├── components/         # UI components (collection/, common/, dashboard/, layout/, vocabulary/)
│   │   ├── pages/              # Route pages (8 pages)
│   │   ├── services/           # Business logic (auth, collection, lookup, settings, statistics, vocabulary)
│   │   ├── stores/             # Zustand stores (auth, collection, settings, theme, ui, vocabulary)
│   │   ├── hooks/              # Custom hooks (useSync, useRateLimit, useDebouncedSearch, useOnlineStatus, useChartColors)
│   │   ├── db/                 # Dexie database + sync engine
│   │   ├── config/             # i18n.js + supabase.js
│   │   ├── locales/            # i18n translation files
│   │   ├── utils/              # Utility functions
│   │   └── test/               # Test setup
│   ├── package.json
│   └── vite.config.js
├── supabase/
│   ├── migrations/             # 8 SQL migration files (profiles, vocabularies, definitions, collections, etc.)
│   └── functions/              # 3 Edge Functions
│       ├── lookup-word/        # Tra từ điển (Free Dictionary API)
│       ├── ai-classify/        # AI phân loại từ (CEFR level, usage, collection gợi ý)
│       └── translate-definition/ # AI dịch nghĩa sang tiếng Việt
├── mobile/                     # Flutter Mobile App (Phase 2 — PLANNED, chưa code)
├── dev-docs/                   # Internal dev documentation
│   ├── RAW_IDEA.md             # Ý tưởng ban đầu
│   ├── ARCHITECTURE_REVIEW.md  # Đánh giá kiến trúc
│   ├── PROJECT_GAP_ANALYSIS.md # Gap analysis & roadmap
│   ├── IMPLEMENTATION_PLAN.md  # Implementation plan chi tiết
│   └── CI_CD_ERROR.md          # CI/CD error logs & fixes
├── docs/                       # Product documentation
│   ├── PRD.md                  # Product Requirements Document
│   ├── SAD.md                  # Software Architecture Document
│   ├── Database_Schema.md
│   ├── API_Specification.md
│   ├── User_Flows.md
│   ├── Project_Setup.md
│   └── superpowers/plans/      # AI-generated implementation plans (Flutter, etc.)
├── DESIGN.md                   # Design system (ElevenLabs-inspired warm cream editorial)
└── AGENTS.md                   # ← File này
```

---

## 4. Features đã hoàn thành ✅

| Feature | Mô tả |
|---------|-------|
| **Auth** | Login/Register (Email + Google OAuth via Supabase) |
| **Smart Vocabulary Input** | Nhập từ → auto-lookup Dictionary + AI → chọn nghĩa → save |
| **Vocabulary CRUD** | Xem, sửa, xóa từ vựng, nghe phát âm |
| **Collection CRUD** | Tạo/sửa/xóa collection, gán/bỏ gán từ vào collection |
| **Search & Filter** | Debounced search, filter theo level/loại từ/usage/collection |
| **Statistics Dashboard** | Streak, phân bố level, phân bố collection, charts |
| **Daily Review Widget** | Flashcard mode + gentle review mode |
| **Offline-First** | Dexie.js IndexedDB, background sync engine |
| **Dark/Light Mode** | Theme switching via Zustand |
| **i18n** | Tiếng Việt + English |
| **Error Boundary** | React Error Boundary wrap toàn app |
| **Rate Limiting** | `useRateLimit` hook cho lookup button |
| **Unit Tests** | Vitest cho services, utils, hooks, db, pages |

---

## 5. Giai đoạn hiện tại & Gaps 🔧

**Đánh giá tổng thể:** Alpha tốt, chưa phải Production.

### 🔴 Thiếu hoàn toàn — Cần làm

| ID | Gap | Ghi chú |
|----|-----|---------|
| G1 | **PWA** (Service Worker + Web Manifest) | App trắng trang khi reload offline |
| G2 | **Web Push Notification** | Settings UI có nhưng chưa có `notification.service.js` |
| G3 | **Export/Import data** (CSV/JSON) | PRD yêu cầu nhưng chưa implement |
| G4 | **Flutter Mobile App** | Có plan chi tiết (`docs/superpowers/plans/`), chưa bắt tay code |

### 🟡 Implement chưa đầy đủ

| ID | Gap | Ghi chú |
|----|-----|---------|
| G5 | **Duplicate Warning** chưa real-time | Chỉ check khi Save, PRD yêu cầu check debounced khi gõ |
| G6 | **Sync Engine** thiếu retry, pagination, conflict resolution | Last-Write-Wins có thể gây data loss |
| G7 | **CI/CD** chỉ có test, chưa auto-deploy | Cần thêm build + deploy step |

### 🟡 Code Quality Concerns

| ID | Issue | File |
|----|-------|------|
| C1 | `AddWordPage.jsx` quá lớn (28KB) | Nên tách custom hooks |
| C2 | Search load toàn bộ definitions vào memory | `vocabulary.service.js` — nên dùng Dexie index |
| C3 | Sync pull không filter theo user_id | `sync.js` — network payload lớn |
| C4 | CI test failing | `undici` incompatibility với Node 22 (`webidl.util.markAsUncloneable`) |

---

## 6. Design System

**Phong cách:** Warm cream editorial — lấy cảm hứng từ ElevenLabs.
**File tham chiếu:** [`DESIGN.md`](file:///f:/Side%20Projects/mewmory/DESIGN.md)

**Quick reference:**
- Canvas: `#fdfcfc` (eggshell) — KHÔNG dùng pure white `#ffffff`
- Card surface: `#f5f3f1` (warm taupe)
- Border: `#ebe8e4` (stone) — hairline 1px
- Text: `#000000` (ink), `#777169` (smoke/body), `#a59f97` (ash/caption)
- Accent: `#0447ff` (violet) + `#ff4704` (orange) — chỉ dùng trong product visuals
- Buttons: pill shape `border-radius: 9999px`
- Cards: `border-radius: 20px`
- Display font: Waldenburg/Inter weight 300
- Body font: Inter weight 400/500

---

## 7. Conventions & Quy tắc khi code

### File & Naming
- Components: PascalCase (`AddWordPage.jsx`, `DuplicateWarning.jsx`)
- Services: camelCase với suffix `.service.js` (`vocabulary.service.js`)
- Stores: camelCase với suffix `.store.js` (`auth.store.js`)
- Hooks: camelCase prefix `use` (`useSync.js`, `useRateLimit.js`)
- Tests: đặt trong `__tests__/` cùng cấp, suffix `.test.jsx`

### Architecture Patterns
- **Offline-first:** Mọi write đi vào Dexie (IndexedDB) trước → sync lên Supabase khi có mạng
- **Service layer:** Business logic nằm trong `services/`, KHÔNG nằm trong components
- **Zustand stores:** UI state và auth state — KHÔNG duplicate business logic ở đây
- **Edge Functions:** Tác vụ cần bảo mật (API keys) và tính toán nặng chạy trên Supabase Edge Functions

### Database
- 8 migration files trong `supabase/migrations/`
- Tables: `profiles`, `vocabularies`, `definitions`, `collections`, `vocabulary_collections`, `user_settings`
- Có views và stored functions
- RLS enabled trên mọi table
- **KHÔNG modify schema/migrations/RLS** khi làm việc trên web hoặc mobile — trừ khi có yêu cầu rõ ràng

### Commands thường dùng
```bash
# Web development
cd web && npm run dev          # Start dev server
cd web && npm run build        # Production build
cd web && npm run test         # Run vitest

# Supabase (cần Supabase CLI)
supabase start                 # Local Supabase
supabase functions serve       # Local Edge Functions
```

---

## 8. Tài liệu tham khảo

| Tài liệu | Đường dẫn | Mô tả |
|-----------|-----------|-------|
| PRD | `docs/PRD.md` | Yêu cầu sản phẩm đầy đủ |
| SAD | `docs/SAD.md` | Kiến trúc hệ thống (⚠️ một số phần lỗi thời) |
| Database Schema | `docs/Database_Schema.md` | Schema chi tiết |
| API Spec | `docs/API_Specification.md` | API endpoints |
| User Flows | `docs/User_Flows.md` | Luồng người dùng |
| Design System | `DESIGN.md` | Tokens, components, do's & don'ts |
| Gap Analysis | `dev-docs/PROJECT_GAP_ANALYSIS.md` | Gaps & roadmap chi tiết |
| Architecture Review | `dev-docs/ARCHITECTURE_REVIEW.md` | Đánh giá kiến trúc |
| Flutter Plan | `docs/superpowers/plans/2026-09-16-flutter-mobile-app.md` | Plan Flutter chi tiết |

> **⚠️ Lưu ý:** Một số docs ghi React 18, Zustand v4 — thực tế đang dùng **React 19**. SAD ghi `src/services/ai/` nhưng thực tế không có folder này. Luôn đối chiếu với code thực tế.
