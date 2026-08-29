# Mewmory Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Mewmory web app — an offline-first smart vocabulary notebook that auto-fills word data from Dictionary API + AI, organizes words into collections, and syncs across devices via Supabase.

**Architecture:** Vite + React SPA with TailwindCSS v4 styling (@tailwindcss/vite + @theme in CSS) and Zustand state management. IndexedDB (Dexie.js) serves as the local-first database with a custom sync queue pushing changes to Supabase PostgreSQL. Edge Functions proxy Dictionary API and AI API calls, keeping API keys server-side.

**Tech Stack:** Vite 5, React 18, TailwindCSS 4 (@tailwindcss/vite), React Router 6, Zustand 4, Dexie.js 4, @supabase/supabase-js 2, Recharts 2, Vitest, React Testing Library

**Spec:** [PRD.md](file:///f:/Side%20Projects/mewmory/docs/PRD.md) | [SAD.md](file:///f:/Side%20Projects/mewmory/docs/SAD.md) | [Database_Schema.md](file:///f:/Side%20Projects/mewmory/docs/Database_Schema.md) | [API_Specification.md](file:///f:/Side%20Projects/mewmory/docs/API_Specification.md) | [User_Flows.md](file:///f:/Side%20Projects/mewmory/docs/User_Flows.md) | [Project_Setup.md](file:///f:/Side%20Projects/mewmory/docs/Project_Setup.md) | [DESIGN.md](file:///f:/Side%20Projects/mewmory/DESIGN.md)

## Global Constraints

- **Node.js** ≥ 18.x, **npm** ≥ 9.x
- All infrastructure MUST stay within free tier (Vercel, Supabase, AI APIs)
- Design tokens from [DESIGN.md](file:///f:/Side%20Projects/mewmory/DESIGN.md) — ElevenLabs-inspired warm cream editorial style (eggshell canvas `#fdfcfc`, warm taupe `#f5f3f1`, Inter font family with weight 300 for display headings, pill buttons `9999px` radius)
- **TailwindCSS v4** with `@tailwindcss/vite` plugin (using `@theme` in `src/index.css`, NO `tailwind.config.js` or `postcss.config.js` needed)
- File naming: `PascalCase.jsx` for components, `camelCase.js` for utilities
- Components don't call APIs directly — business logic lives in `services/`
- State management via Zustand stores in `stores/`
- Soft delete (`is_deleted = true`) for all data records to support sync
- RLS enforced on all Supabase tables — each user only accesses own data
- Offline-first: all writes go to IndexedDB first, sync when online
- Max 10 concurrent users, app is internal-use only

---

## 🛑 AGENT INTERACTION & USER GUIDANCE PROTOCOL (Bắt buộc cho AI Agent)

> [!IMPORTANT]
> **Quy tắc tương tác & Tạm dừng cho AI Agent khi thực thi kế hoạch:**
> Khi gặp bất kỳ bước nào cần:
>
> 1. **Thông tin bí mật hoặc cấu hình môi trường** (API Keys, Supabase URL/Anon Key, `.env.local`).
> 2. **Thao tác trên giao diện Web ngoài** (Supabase Dashboard, Google AI Studio, Vercel Dashboard).
> 3. **Lệnh CLI cần xác thực tương tác** (`supabase login`, `supabase link`).
>
> **AI Agent PHẢI:**
>
> - ⏸️ **TỰ ĐỘNG TẠM DỪNG (PAUSE)** — không tự sinh dữ liệu giả hay tự đoán key.
> - 📖 **HƯỚNG DẪN CHI TIẾT TỪNG BƯỚC (Step-by-step guidance)** cho người dùng biết cần vào đâu, click gì, copy cái gì.
> - 💬 **YÊU CẦU NGƯỜI DÙNG CUNG CẤP THÔNG TIN HOẶC XÁC NHẬN** đã hoàn thành trước khi chuyển sang bước tiếp theo.

---

## Confirmed Project Decisions

- **Styling:** TailwindCSS v4 with `@tailwindcss/vite` and `@theme` in CSS.
- **Display Typography:** Google Fonts `Inter` (weight 300) as substitute for Waldenburg.
- **Supabase Backend:** Existing Supabase project ready; Agent will prompt user at Task 2 & 3 for credentials.
- **AI Keys:** Gemini API key ready; Agent will guide user to set Supabase secret at Task 6.
- **Authentication:** Email & Password in Phase 1 (Google OAuth can be enabled in settings later).
- **Deployment:** Complete local development & verification first, deploy to Vercel at Task 14.

---

## 📅 Phased Execution Roadmap

Kế hoạch được chia thành **4 Phase** để thực hiện dần qua nhiều buổi làm việc. Mỗi Phase kết thúc tại một **milestone có thể kiểm tra được** — nghĩa là sau mỗi Phase bạn đã có một phần ứng dụng chạy được thực sự, không cần phải hoàn thành toàn bộ mới test.

### Phase A — Nền tảng (Foundation)

> **Tasks:** 1 → 2
> **Ước tính:** ~1 buổi (2–3 giờ)
> **Yêu cầu input từ bạn:** Supabase URL + Anon Key cho file `.env.local`

| Task | Tên                                 | Mô tả ngắn                                           |
| :--- | :---------------------------------- | :--------------------------------------------------- |
| 1    | Project Scaffolding & Design System | Vite + React + TailwindCSS v4 + common UI components |
| 2    | Authentication                      | Supabase Auth, Login page, Auth guard                |

**✅ Milestone A:** App chạy ở `localhost:5173`, có trang Login đẹp theo DESIGN.md, đăng ký/đăng nhập bằng email hoạt động, route được bảo vệ bởi auth guard.

---

### Phase B — Dữ liệu & Giao diện khung (Data & Shell)

> **Tasks:** 3 → 4 → 5
> **Ước tính:** ~1–2 buổi (3–5 giờ)
> **Yêu cầu input từ bạn:** `supabase login` + `supabase link` (lệnh CLI cần xác thực)

| Task | Tên                                         | Mô tả ngắn                                         |
| :--- | :------------------------------------------ | :------------------------------------------------- |
| 3    | Database Schema & Migrations                | 8 file SQL migration → push lên Supabase cloud     |
| 4    | Local Database (Dexie.js) + Vocabulary CRUD | IndexedDB schema + vocabulary service + sync queue |
| 5    | Layout & Navigation Shell                   | Sidebar, Header, MainLayout, OfflineBadge          |

**✅ Milestone B:** App có sidebar navigation hoàn chỉnh, database cloud đã có schema, dữ liệu từ vựng có thể tạo/đọc/sửa/xóa ở local (IndexedDB). Giao diện tổng thể đã thành hình.

---

### Phase C — Tính năng chính (Core Features)

> **Tasks:** 6 → 7 → 8 → 9 → 10
> **Ước tính:** ~2–3 buổi (5–8 giờ)
> **Yêu cầu input từ bạn:** Gemini API Key (cho Edge Functions)

| Task | Tên                                        | Mô tả ngắn                                        |
| :--- | :----------------------------------------- | :------------------------------------------------ |
| 6    | Edge Functions (lookup-word & ai-classify) | Supabase Edge Functions proxy Dictionary + AI API |
| 7    | Smart Vocabulary Input (AddWordPage)       | Trang thêm từ mới: tra cứu, chọn nghĩa, lưu       |
| 8    | Collection Management                      | CRUD collection, gán từ vào collection            |
| 9    | Vocabulary List + Search & Filter          | Danh sách từ vựng, tìm kiếm, lọc, sắp xếp         |
| 10   | Word Detail Page (View/Edit)               | Trang chi tiết từ: xem, sửa, xóa                  |

**✅ Milestone C:** Luồng chính hoàn chỉnh — nhập từ "resilient" → AI tra cứu tự động → chọn nghĩa → lưu → xem trong danh sách → xem chi tiết → phân loại vào collection. Đây là **demo-ready milestone**.

---

### Phase D — Hoàn thiện (Polish & Ship)

> **Tasks:** 11 → 12 → 13 → 14
> **Ước tính:** ~1–2 buổi (3–5 giờ)
> **Yêu cầu input từ bạn:** Không cần thêm (hoặc Vercel nếu muốn deploy)

| Task | Tên                    | Mô tả ngắn                                             |
| :--- | :--------------------- | :----------------------------------------------------- |
| 11   | Sync Engine            | Push/Pull đồng bộ IndexedDB ↔ Supabase                 |
| 12   | Dashboard + Statistics | Daily review widget, biểu đồ thống kê                  |
| 13   | Settings Page          | AI provider, notification, account management          |
| 14   | Polish & Testing       | Animations, empty states, edge cases, production build |

**✅ Milestone D:** App hoàn chỉnh Phase 1 — offline-first sync hoạt động, dashboard có biểu đồ đẹp, settings page, UI được đánh bóng với animations. Sẵn sàng deploy lên Vercel.

---

## File Structure

```
mewmory/
├── web/                               # Web App (Vite + React)
│   ├── package.json
│   ├── vite.config.js
│   ├── index.html
│   ├── .env.local                     # VITE_SUPABASE_URL + VITE_SUPABASE_ANON_KEY
│   ├── .env.example
│   ├── public/
│   │   └── favicon.svg
│   └── src/
│       ├── main.jsx                   # Entry point
│       ├── App.jsx                    # Root component + routing
│       ├── index.css                  # TailwindCSS imports + design tokens
│       │
│       ├── config/
│       │   └── supabase.js            # Supabase client singleton
│       │
│       ├── db/
│       │   ├── database.js            # Dexie.js database definition
│       │   └── sync.js               # Sync engine (local ↔ server)
│       │
│       ├── services/
│       │   ├── auth.service.js        # Authentication operations
│       │   ├── vocabulary.service.js  # Vocabulary CRUD (local-first)
│       │   ├── collection.service.js  # Collection CRUD (local-first)
│       │   ├── lookup.service.js      # Edge Function: word lookup
│       │   ├── settings.service.js    # User settings CRUD
│       │   └── statistics.service.js  # Stats computation
│       │
│       ├── stores/
│       │   ├── auth.store.js          # Auth state (user, session, loading)
│       │   ├── vocabulary.store.js    # Vocabulary list state + filters
│       │   ├── collection.store.js    # Collection list state
│       │   ├── settings.store.js      # User settings state
│       │   └── ui.store.js            # UI state (modals, toasts, loading)
│       │
│       ├── hooks/
│       │   ├── useOnlineStatus.js     # Network status detection
│       │   ├── useSync.js            # Auto-sync trigger hook
│       │   └── useDebouncedSearch.js  # Debounced search input
│       │
│       ├── pages/
│       │   ├── LoginPage.jsx
│       │   ├── DashboardPage.jsx      # Home: Daily Review + Statistics
│       │   ├── VocabularyPage.jsx     # Vocabulary list + search/filter
│       │   ├── AddWordPage.jsx        # Smart vocabulary input
│       │   ├── WordDetailPage.jsx     # Word detail view/edit
│       │   ├── CollectionsPage.jsx    # Collection list
│       │   ├── CollectionDetailPage.jsx
│       │   └── SettingsPage.jsx
│       │
│       ├── components/
│       │   ├── layout/
│       │   │   ├── Sidebar.jsx
│       │   │   ├── Header.jsx
│       │   │   └── MainLayout.jsx
│       │   ├── vocabulary/
│       │   │   ├── WordCard.jsx
│       │   │   ├── WordForm.jsx
│       │   │   ├── LookupResult.jsx
│       │   │   ├── MeaningSelector.jsx
│       │   │   ├── DuplicateWarning.jsx
│       │   │   └── FilterBar.jsx
│       │   ├── collection/
│       │   │   ├── CollectionCard.jsx
│       │   │   └── CollectionForm.jsx
│       │   ├── dashboard/
│       │   │   ├── DailyReviewWidget.jsx
│       │   │   ├── StatsOverview.jsx
│       │   │   ├── StreakChart.jsx
│       │   │   ├── LevelDistribution.jsx
│       │   │   └── CollectionDistribution.jsx
│       │   └── common/
│       │       ├── Button.jsx
│       │       ├── Input.jsx
│       │       ├── Modal.jsx
│       │       ├── Toast.jsx
│       │       ├── LoadingSpinner.jsx
│       │       ├── OfflineBadge.jsx
│       │       └── ConfirmDialog.jsx
│       │
│       └── utils/
│           ├── constants.js           # CEFR levels, POS, usage types
│           ├── formatters.js          # Date, text formatters
│           └── validators.js          # Input validation
│
├── supabase/                          # Supabase configuration
│   ├── config.toml
│   ├── migrations/
│   │   ├── 00001_create_profiles.sql
│   │   ├── 00002_create_vocabularies.sql
│   │   ├── 00003_create_definitions.sql
│   │   ├── 00004_create_collections.sql
│   │   ├── 00005_create_vocabulary_collections.sql
│   │   ├── 00006_create_user_settings.sql
│   │   ├── 00007_create_views.sql
│   │   └── 00008_create_functions.sql
│   └── functions/
│       ├── lookup-word/
│       │   └── index.ts
│       └── ai-classify/
│           └── index.ts
│
└── .gitignore
```

---

### Task 1: Project Scaffolding & Design System

**Files:**

- Create: `web/package.json` (via Vite scaffold)
- Create: `web/vite.config.js` (configured with `@tailwindcss/vite`)
- Create: `web/index.html`
- Create: `web/.env.example`
- Create: `web/src/index.css` (TailwindCSS v4 with `@theme`)
- Create: `web/src/main.jsx`
- Create: `web/src/App.jsx`
- Create: `web/src/utils/constants.js`
- Create: `web/src/utils/formatters.js`
- Create: `web/src/utils/validators.js`
- Create: `web/src/components/common/Button.jsx`
- Create: `web/src/components/common/Input.jsx`
- Create: `web/src/components/common/Modal.jsx`
- Create: `web/src/components/common/Toast.jsx`
- Create: `web/src/components/common/LoadingSpinner.jsx`
- Create: `web/src/components/common/ConfirmDialog.jsx`
- Create: `.gitignore`
- Test: `web/src/utils/__tests__/constants.test.js`
- Test: `web/src/utils/__tests__/formatters.test.js`
- Test: `web/src/utils/__tests__/validators.test.js`

**Interfaces:**

- Consumes: Nothing (first task)
- Produces:
  - `CEFR_LEVELS`: `['A1', 'A2', 'B1', 'B2', 'C1', 'C2']`
  - `PARTS_OF_SPEECH`: `['noun', 'verb', 'adjective', 'adverb', 'preposition', 'conjunction', 'interjection', 'pronoun', 'determiner', 'exclamation']`
  - `USAGE_REGISTERS`: `['formal', 'informal', 'slang', 'neutral', 'vulgar', 'technical']`
  - `formatDate(dateString: string): string` — format ISO date to locale string
  - `formatRelativeTime(dateString: string): string` — "2 hours ago", "yesterday"
  - `truncateText(text: string, maxLength: number): string`
  - `validateWord(word: string): { valid: boolean, error?: string }`
  - `validateEmail(email: string): { valid: boolean, error?: string }`
  - `validatePassword(password: string): { valid: boolean, error?: string }`
  - `<Button variant="primary|secondary|ghost" size="sm|md|lg" />` — pill-shaped buttons per DESIGN.md
  - `<Input label? error? />` — styled text input
  - `<Modal isOpen onClose title children />` — centered modal overlay
  - `<Toast message type="success|error|info" onClose />` — top-right toast notification
  - `<LoadingSpinner size="sm|md|lg" />` — animated spinner
  - `<ConfirmDialog isOpen title message onConfirm onCancel />` — confirm action modal

- [ ] **Step 1: Scaffold Vite + React project**

```bash
cd f:\Side Projects\mewmory
npx -y create-vite@latest web -- --template react
cd web
npm install
```

- [ ] **Step 2: Install dependencies**

```bash
cd web
npm install react-router-dom@^6 zustand@^4 dexie@^4 @supabase/supabase-js@^2 recharts@^2
npm install -D tailwindcss@^4 @tailwindcss/vite vitest @testing-library/react @testing-library/jest-dom jsdom
```

- [ ] **Step 3: Configure Vite with TailwindCSS v4 plugin**

Update `web/vite.config.js`:

```javascript
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  plugins: [react(), tailwindcss()],
  test: {
    globals: true,
    environment: "jsdom",
    setupFiles: "./src/test/setup.js",
  },
});
```

- [ ] **Step 4: Create `index.css` with TailwindCSS v4 @theme design tokens**

Create `web/src/index.css`:

```css
@import "tailwindcss";
@import url("https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&display=swap");

@theme {
  /* Colors from DESIGN.md */
  --color-eggshell: #fdfcfc;
  --color-warm-taupe: #f5f3f1;
  --color-stone: #ebe8e4;
  --color-ink: #000000;
  --color-graphite: #44403b;
  --color-smoke: #777169;
  --color-ash: #a59f97;
  --color-violet-spark: #0447ff;
  --color-ember-orange: #ff4704;

  /* Typography */
  --font-display: "Inter", ui-sans-serif, system-ui, -apple-system, sans-serif;
  --font-body: "Inter", ui-sans-serif, system-ui, -apple-system, sans-serif;
  --font-mono:
    "Geist Mono", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas,
    monospace;

  /* Border Radius */
  --radius-card: 20px;
  --radius-card-lg: 24px;
  --radius-pill: 9999px;

  /* Shadows */
  --shadow-subtle:
    rgba(0, 0, 0, 0.4) 0px 0px 1px 0px, rgba(0, 0, 0, 0.04) 0px 1px 1px 0px,
    rgba(0, 0, 0, 0.04) 0px 2px 4px 0px;
  --shadow-subtle-inset: rgba(0, 0, 0, 0.075) 0px 0px 0px 0.5px inset;
}

@layer base {
  body {
    background-color: var(--color-eggshell);
    color: var(--color-ink);
    font-family: var(--font-body);
    -webkit-font-smoothing: antialiased;
  }

  /* Display headings use Inter 300 (substitute for Waldenburg) */
  h1,
  h2,
  h3 {
    font-weight: 300;
    letter-spacing: -0.02em;
  }
}

@layer components {
  /* Hairline divider */
  .divider {
    border-top: 1px solid var(--color-stone);
  }

  /* Warm taupe surface card */
  .card-taupe {
    background-color: var(--color-warm-taupe);
    border-radius: var(--radius-card);
    padding: 2rem;
  }

  /* White card with whisper shadow */
  .card-elevated {
    background-color: var(--color-eggshell);
    border-radius: var(--radius-card);
    padding: 1rem;
    box-shadow: var(--shadow-subtle);
  }
}
```

- [ ] **Step 5: Create utility modules**

Create `web/src/utils/constants.js`:

```javascript
export const CEFR_LEVELS = ["A1", "A2", "B1", "B2", "C1", "C2"];

export const PARTS_OF_SPEECH = [
  "noun",
  "verb",
  "adjective",
  "adverb",
  "preposition",
  "conjunction",
  "interjection",
  "pronoun",
  "determiner",
  "exclamation",
];

export const USAGE_REGISTERS = [
  "formal",
  "informal",
  "slang",
  "neutral",
  "vulgar",
  "technical",
];

export const CEFR_COLORS = {
  A1: { bg: "bg-green-100", text: "text-green-800", label: "Beginner" },
  A2: { bg: "bg-green-200", text: "text-green-900", label: "Elementary" },
  B1: { bg: "bg-blue-100", text: "text-blue-800", label: "Intermediate" },
  B2: { bg: "bg-blue-200", text: "text-blue-900", label: "Upper-Intermediate" },
  C1: { bg: "bg-purple-100", text: "text-purple-800", label: "Advanced" },
  C2: { bg: "bg-purple-200", text: "text-purple-900", label: "Proficiency" },
};

export const PAGINATION = {
  DEFAULT_LIMIT: 20,
  MAX_LIMIT: 100,
};

export const DEBOUNCE_MS = 300;
```

Create `web/src/utils/formatters.js`:

```javascript
export function formatDate(dateString) {
  if (!dateString) return "";
  const date = new Date(dateString);
  return date.toLocaleDateString("vi-VN", {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
}

export function formatRelativeTime(dateString) {
  if (!dateString) return "";
  const date = new Date(dateString);
  const now = new Date();
  const diffMs = now - date;
  const diffSec = Math.floor(diffMs / 1000);
  const diffMin = Math.floor(diffSec / 60);
  const diffHour = Math.floor(diffMin / 60);
  const diffDay = Math.floor(diffHour / 24);

  if (diffSec < 60) return "Vừa xong";
  if (diffMin < 60) return `${diffMin} phút trước`;
  if (diffHour < 24) return `${diffHour} giờ trước`;
  if (diffDay < 7) return `${diffDay} ngày trước`;
  return formatDate(dateString);
}

export function truncateText(text, maxLength = 100) {
  if (!text || text.length <= maxLength) return text || "";
  return text.slice(0, maxLength).trimEnd() + "...";
}
```

Create `web/src/utils/validators.js`:

```javascript
export function validateWord(word) {
  if (!word || typeof word !== "string") {
    return { valid: false, error: "Vui lòng nhập từ vựng" };
  }
  const trimmed = word.trim();
  if (trimmed.length === 0) {
    return { valid: false, error: "Vui lòng nhập từ vựng" };
  }
  if (trimmed.length > 100) {
    return { valid: false, error: "Từ vựng quá dài (tối đa 100 ký tự)" };
  }
  if (!/^[a-zA-Z\s'-]+$/.test(trimmed)) {
    return { valid: false, error: "Từ vựng chỉ chứa chữ cái tiếng Anh" };
  }
  return { valid: true };
}

export function validateEmail(email) {
  if (!email || typeof email !== "string") {
    return { valid: false, error: "Vui lòng nhập email" };
  }
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email.trim())) {
    return { valid: false, error: "Email không hợp lệ" };
  }
  return { valid: true };
}

export function validatePassword(password) {
  if (!password || typeof password !== "string") {
    return { valid: false, error: "Vui lòng nhập mật khẩu" };
  }
  if (password.length < 6) {
    return { valid: false, error: "Mật khẩu phải có ít nhất 6 ký tự" };
  }
  return { valid: true };
}
```

- [ ] **Step 6: Write tests for utility modules**

Create `web/src/utils/__tests__/constants.test.js`:

```javascript
import { describe, it, expect } from "vitest";
import { CEFR_LEVELS, PARTS_OF_SPEECH, USAGE_REGISTERS } from "../constants";

describe("constants", () => {
  it("has 6 CEFR levels in order", () => {
    expect(CEFR_LEVELS).toEqual(["A1", "A2", "B1", "B2", "C1", "C2"]);
  });

  it("has standard parts of speech", () => {
    expect(PARTS_OF_SPEECH).toContain("noun");
    expect(PARTS_OF_SPEECH).toContain("verb");
    expect(PARTS_OF_SPEECH).toContain("adjective");
    expect(PARTS_OF_SPEECH.length).toBeGreaterThanOrEqual(8);
  });

  it("has usage registers", () => {
    expect(USAGE_REGISTERS).toContain("formal");
    expect(USAGE_REGISTERS).toContain("informal");
    expect(USAGE_REGISTERS).toContain("slang");
  });
});
```

Create `web/src/utils/__tests__/formatters.test.js`:

```javascript
import { describe, it, expect } from "vitest";
import { formatDate, formatRelativeTime, truncateText } from "../formatters";

describe("formatDate", () => {
  it("returns empty string for falsy input", () => {
    expect(formatDate(null)).toBe("");
    expect(formatDate(undefined)).toBe("");
    expect(formatDate("")).toBe("");
  });

  it("formats a valid ISO date string", () => {
    const result = formatDate("2026-08-25T10:00:00Z");
    expect(result).toBeTruthy();
    expect(typeof result).toBe("string");
  });
});

describe("formatRelativeTime", () => {
  it('returns "Vừa xong" for just now', () => {
    const now = new Date().toISOString();
    expect(formatRelativeTime(now)).toBe("Vừa xong");
  });

  it("returns empty string for falsy input", () => {
    expect(formatRelativeTime(null)).toBe("");
  });
});

describe("truncateText", () => {
  it("returns text unchanged if shorter than max", () => {
    expect(truncateText("hello", 10)).toBe("hello");
  });

  it("truncates text with ellipsis", () => {
    expect(truncateText("hello world foo bar", 10)).toBe("hello...");
  });

  it("handles null/undefined", () => {
    expect(truncateText(null)).toBe("");
    expect(truncateText(undefined)).toBe("");
  });
});
```

Create `web/src/utils/__tests__/validators.test.js`:

```javascript
import { describe, it, expect } from "vitest";
import { validateWord, validateEmail, validatePassword } from "../validators";

describe("validateWord", () => {
  it("rejects empty word", () => {
    expect(validateWord("")).toEqual({
      valid: false,
      error: "Vui lòng nhập từ vựng",
    });
  });

  it("accepts valid English word", () => {
    expect(validateWord("resilient")).toEqual({ valid: true });
  });

  it("accepts multi-word with spaces and hyphens", () => {
    expect(validateWord("don't")).toEqual({ valid: true });
    expect(validateWord("well-known")).toEqual({ valid: true });
  });

  it("rejects word with numbers", () => {
    const result = validateWord("abc123");
    expect(result.valid).toBe(false);
  });
});

describe("validateEmail", () => {
  it("accepts valid email", () => {
    expect(validateEmail("test@example.com")).toEqual({ valid: true });
  });

  it("rejects invalid email", () => {
    expect(validateEmail("not-an-email").valid).toBe(false);
  });
});

describe("validatePassword", () => {
  it("accepts password with 6+ chars", () => {
    expect(validatePassword("abcdef")).toEqual({ valid: true });
  });

  it("rejects short password", () => {
    expect(validatePassword("abc").valid).toBe(false);
  });
});
```

- [ ] **Step 7: Configure Vitest**

Add to `web/vite.config.js`:

```javascript
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: "jsdom",
    setupFiles: "./src/test/setup.js",
  },
});
```

Create `web/src/test/setup.js`:

```javascript
import "@testing-library/jest-dom";
```

- [ ] **Step 8: Create common UI components**

Create `web/src/components/common/Button.jsx`:

```jsx
export default function Button({
  children,
  variant = "primary",
  size = "md",
  onClick,
  disabled = false,
  type = "button",
  className = "",
  ...props
}) {
  const base =
    "inline-flex items-center justify-center rounded-pill font-body font-medium transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed";

  const variants = {
    primary: "bg-ink text-eggshell border border-stone hover:opacity-90",
    secondary: "bg-eggshell text-ink border border-stone hover:bg-warm-taupe",
    ghost: "bg-transparent text-ink border border-stone hover:bg-warm-taupe",
  };

  const sizes = {
    sm: "px-3 py-1.5 text-body-sm",
    md: "px-4 py-2 text-body-sm",
    lg: "px-6 py-2.5 text-body",
  };

  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled}
      className={`${base} ${variants[variant]} ${sizes[size]} ${className}`}
      {...props}
    >
      {children}
    </button>
  );
}
```

Create `web/src/components/common/Input.jsx`:

```jsx
export default function Input({ label, error, id, className = "", ...props }) {
  return (
    <div className={`flex flex-col gap-1.5 ${className}`}>
      {label && (
        <label htmlFor={id} className="text-body-sm text-graphite font-medium">
          {label}
        </label>
      )}
      <input
        id={id}
        className={`w-full px-3 py-2 rounded border bg-eggshell text-ink text-body font-body placeholder:text-ash focus:outline-none focus:ring-1 transition-colors ${
          error
            ? "border-red-400 focus:ring-red-400"
            : "border-stone focus:ring-ink"
        }`}
        {...props}
      />
      {error && <p className="text-body-sm text-red-500">{error}</p>}
    </div>
  );
}
```

Create `web/src/components/common/Modal.jsx`:

```jsx
import { useEffect } from "react";

export default function Modal({ isOpen, onClose, title, children }) {
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "";
    }
    return () => {
      document.body.style.overflow = "";
    };
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      <div
        className="absolute inset-0 bg-ink/20 backdrop-blur-sm"
        onClick={onClose}
      />
      <div className="relative bg-eggshell rounded-card-lg p-6 w-full max-w-lg mx-4 shadow-subtle animate-fade-in">
        {title && (
          <h2 className="text-heading-sm font-display font-light mb-4">
            {title}
          </h2>
        )}
        {children}
      </div>
    </div>
  );
}
```

Create `web/src/components/common/Toast.jsx`:

```jsx
import { useEffect } from "react";

export default function Toast({
  message,
  type = "success",
  onClose,
  duration = 3000,
}) {
  useEffect(() => {
    const timer = setTimeout(onClose, duration);
    return () => clearTimeout(timer);
  }, [onClose, duration]);

  const typeStyles = {
    success: "bg-green-50 text-green-800 border-green-200",
    error: "bg-red-50 text-red-800 border-red-200",
    info: "bg-blue-50 text-blue-800 border-blue-200",
  };

  return (
    <div
      className={`fixed top-4 right-4 z-50 px-4 py-3 rounded-card border shadow-subtle text-body-sm font-body animate-slide-in ${typeStyles[type]}`}
    >
      <div className="flex items-center gap-2">
        <span>{message}</span>
        <button
          onClick={onClose}
          className="text-current opacity-60 hover:opacity-100 ml-2"
        >
          ✕
        </button>
      </div>
    </div>
  );
}
```

Create `web/src/components/common/LoadingSpinner.jsx`:

```jsx
export default function LoadingSpinner({ size = "md" }) {
  const sizeClasses = {
    sm: "w-4 h-4",
    md: "w-6 h-6",
    lg: "w-10 h-10",
  };

  return (
    <div
      className={`${sizeClasses[size]} animate-spin rounded-full border-2 border-stone border-t-ink`}
    />
  );
}
```

Create `web/src/components/common/ConfirmDialog.jsx`:

```jsx
import Modal from "./Modal";
import Button from "./Button";

export default function ConfirmDialog({
  isOpen,
  title = "Xác nhận",
  message,
  onConfirm,
  onCancel,
  confirmText = "Xác nhận",
  cancelText = "Hủy",
}) {
  return (
    <Modal isOpen={isOpen} onClose={onCancel} title={title}>
      <p className="text-body text-smoke mb-6">{message}</p>
      <div className="flex justify-end gap-3">
        <Button variant="secondary" onClick={onCancel}>
          {cancelText}
        </Button>
        <Button variant="primary" onClick={onConfirm}>
          {confirmText}
        </Button>
      </div>
    </Modal>
  );
}
```

- [ ] **Step 9: Create `.env.example` and `.gitignore`**

Create `web/.env.example`:

```env
# Supabase
VITE_SUPABASE_URL=
VITE_SUPABASE_ANON_KEY=

# (Edge Function secrets are configured via Supabase Dashboard)
```

Create/update `.gitignore`:

```gitignore
node_modules/
dist/
.env.local
.env
*.log
.DS_Store
```

- [ ] **Step 10: Run tests to verify**

```bash
cd web
npx vitest run
```

Expected: All tests pass.

- [ ] **Step 11: Commit**

```bash
git add -A
git commit -m "feat: scaffold project with Vite + React, TailwindCSS, design tokens, and common UI components"
```

---

### Task 2: Authentication (Login/Register)

> [!IMPORTANT]
> **⏸️ USER INTERACTION CHECKPOINT (Trước khi chạy Task 2):**
> **AI Agent PHẢI tạm dừng và hướng dẫn người dùng tạo file `.env.local`:**
>
> 1. Hướng dẫn người dùng vào **Supabase Dashboard** -> Chọn Project -> **Project Settings** -> **API**.
> 2. Copy **Project URL** và **anon public key**.
> 3. Tạo file `web/.env.local` với nội dung:
>    ```env
>    VITE_SUPABASE_URL=https://<your-project-ref>.supabase.co
>    VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsIn...
>    ```
> 4. Nhắc người dùng vào **Authentication** -> **URL Configuration** và thêm `http://localhost:5173/**` vào Redirect URLs.
> 5. Chờ người dùng xác nhận đã tạo xong file `.env.local` mới tiếp tục các bước code bên dưới.

**Files:**

- Create: `web/src/config/supabase.js`
- Create: `web/src/services/auth.service.js`
- Create: `web/src/stores/auth.store.js`
- Create: `web/src/stores/ui.store.js`
- Create: `web/src/pages/LoginPage.jsx`
- Modify: `web/src/App.jsx`
- Modify: `web/src/main.jsx`
- Test: `web/src/services/__tests__/auth.service.test.js`

**Interfaces:**

- Consumes: `<Button />`, `<Input />`, `<Toast />`, `validateEmail()`, `validatePassword()` from Task 1
- Produces:
  - `supabase` — initialized Supabase client singleton
  - `authService.signUp(email, password): Promise<{ user, error }>`
  - `authService.signIn(email, password): Promise<{ user, error }>`
  - `authService.signInWithGoogle(): Promise<{ user, error }>`
  - `authService.signOut(): Promise<void>`
  - `authService.getSession(): Promise<{ session }>`
  - `authService.onAuthStateChange(callback): Subscription`
  - `useAuthStore` — Zustand store: `{ user, session, isLoading, isAuthenticated, setUser, setSession, setLoading, signOut }`
  - `useUIStore` — Zustand store: `{ toasts, addToast, removeToast }`
  - `<LoginPage />` — page with Email/Password login, Sign Up, Google Sign-In

- [ ] **Step 1: Create Supabase client config**

Create `web/src/config/supabase.js`:

```javascript
import { createClient } from "@supabase/supabase-js";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  console.warn(
    "Missing Supabase environment variables. Some features will not work.",
  );
}

export const supabase = createClient(
  supabaseUrl || "https://placeholder.supabase.co",
  supabaseAnonKey || "placeholder-key",
  {
    auth: {
      autoRefreshToken: true,
      persistSession: true,
      detectSessionInUrl: true,
    },
  },
);
```

- [ ] **Step 2: Create auth service**

Create `web/src/services/auth.service.js`:

```javascript
import { supabase } from "../config/supabase";

export const authService = {
  async signUp(email, password) {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
    });
    return { user: data?.user, error };
  },

  async signIn(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    return { user: data?.user, session: data?.session, error };
  },

  async signInWithGoogle() {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: "google",
      options: {
        redirectTo: window.location.origin,
      },
    });
    return { data, error };
  },

  async signOut() {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
  },

  async getSession() {
    const { data, error } = await supabase.auth.getSession();
    return { session: data?.session, error };
  },

  onAuthStateChange(callback) {
    return supabase.auth.onAuthStateChange(callback);
  },
};
```

- [ ] **Step 3: Create Zustand stores**

Create `web/src/stores/auth.store.js`:

```javascript
import { create } from "zustand";

export const useAuthStore = create((set) => ({
  user: null,
  session: null,
  isLoading: true,
  isAuthenticated: false,

  setUser: (user) => set({ user, isAuthenticated: !!user }),
  setSession: (session) => set({ session }),
  setLoading: (isLoading) => set({ isLoading }),

  signOut: () =>
    set({
      user: null,
      session: null,
      isAuthenticated: false,
    }),
}));
```

Create `web/src/stores/ui.store.js`:

```javascript
import { create } from "zustand";

let toastId = 0;

export const useUIStore = create((set) => ({
  toasts: [],
  sidebarOpen: true,

  addToast: (message, type = "success") => {
    const id = ++toastId;
    set((state) => ({
      toasts: [...state.toasts, { id, message, type }],
    }));
    return id;
  },

  removeToast: (id) =>
    set((state) => ({
      toasts: state.toasts.filter((t) => t.id !== id),
    })),

  toggleSidebar: () => set((state) => ({ sidebarOpen: !state.sidebarOpen })),
}));
```

- [ ] **Step 4: Create LoginPage**

Create `web/src/pages/LoginPage.jsx`:

```jsx
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { authService } from "../services/auth.service";
import { useUIStore } from "../stores/ui.store";
import { validateEmail, validatePassword } from "../utils/validators";
import Button from "../components/common/Button";
import Input from "../components/common/Input";

export default function LoginPage() {
  const navigate = useNavigate();
  const addToast = useUIStore((s) => s.addToast);

  const [isSignUp, setIsSignUp] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    const emailResult = validateEmail(email);
    const passwordResult = validatePassword(password);
    const newErrors = {};
    if (!emailResult.valid) newErrors.email = emailResult.error;
    if (!passwordResult.valid) newErrors.password = passwordResult.error;

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }

    setErrors({});
    setLoading(true);

    try {
      if (isSignUp) {
        const { error } = await authService.signUp(email, password);
        if (error) throw error;
        addToast("Tạo tài khoản thành công!", "success");
      } else {
        const { error } = await authService.signIn(email, password);
        if (error) throw error;
      }
      navigate("/");
    } catch (err) {
      addToast(err.message || "Đã xảy ra lỗi", "error");
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleSignIn = async () => {
    const { error } = await authService.signInWithGoogle();
    if (error) {
      addToast(error.message || "Lỗi đăng nhập Google", "error");
    }
  };

  return (
    <div className="min-h-screen bg-eggshell flex items-center justify-center p-4">
      <div className="w-full max-w-sm">
        {/* Logo */}
        <div className="text-center mb-10">
          <h1 className="text-display font-display font-light tracking-tight">
            Mewmory
          </h1>
          <p className="text-body text-smoke mt-2">
            Ghi chép từ vựng thông minh
          </p>
        </div>

        {/* Form */}
        <div className="bg-warm-taupe rounded-card-lg p-8">
          <h2 className="text-heading-sm font-display font-light mb-6">
            {isSignUp ? "Tạo tài khoản" : "Đăng nhập"}
          </h2>

          <form onSubmit={handleSubmit} className="flex flex-col gap-4">
            <Input
              id="email"
              type="email"
              label="Email"
              placeholder="you@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              error={errors.email}
            />
            <Input
              id="password"
              type="password"
              label="Mật khẩu"
              placeholder="••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              error={errors.password}
            />

            <Button type="submit" disabled={loading} className="w-full mt-2">
              {loading
                ? "Đang xử lý..."
                : isSignUp
                  ? "Tạo tài khoản"
                  : "Đăng nhập"}
            </Button>
          </form>

          {/* Divider */}
          <div className="flex items-center gap-3 my-5">
            <div className="flex-1 h-px bg-stone" />
            <span className="text-caption text-ash">hoặc</span>
            <div className="flex-1 h-px bg-stone" />
          </div>

          {/* Google Sign In */}
          <Button
            variant="secondary"
            onClick={handleGoogleSignIn}
            className="w-full"
          >
            Đăng nhập với Google
          </Button>

          {/* Toggle */}
          <p className="text-body-sm text-smoke text-center mt-5">
            {isSignUp ? "Đã có tài khoản?" : "Chưa có tài khoản?"}{" "}
            <button
              type="button"
              onClick={() => {
                setIsSignUp(!isSignUp);
                setErrors({});
              }}
              className="text-ink font-medium hover:underline"
            >
              {isSignUp ? "Đăng nhập" : "Đăng ký"}
            </button>
          </p>
        </div>
      </div>
    </div>
  );
}
```

- [ ] **Step 5: Wire up App.jsx with routing and auth guard**

```jsx
// web/src/App.jsx
import { useEffect } from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { useAuthStore } from "./stores/auth.store";
import { useUIStore } from "./stores/ui.store";
import { authService } from "./services/auth.service";
import LoginPage from "./pages/LoginPage";
import Toast from "./components/common/Toast";
import LoadingSpinner from "./components/common/LoadingSpinner";

function ProtectedRoute({ children }) {
  const { isAuthenticated, isLoading } = useAuthStore();

  if (isLoading) {
    return (
      <div className="min-h-screen bg-eggshell flex items-center justify-center">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return isAuthenticated ? children : <Navigate to="/login" replace />;
}

function PlaceholderPage({ title }) {
  return (
    <div className="p-8">
      <h1 className="text-heading font-display font-light">{title}</h1>
      <p className="text-smoke mt-2">Coming soon...</p>
    </div>
  );
}

export default function App() {
  const { setUser, setSession, setLoading } = useAuthStore();
  const { toasts, removeToast } = useUIStore();

  useEffect(() => {
    // Check existing session
    authService.getSession().then(({ session }) => {
      setSession(session);
      setUser(session?.user || null);
      setLoading(false);
    });

    // Listen for auth changes
    const {
      data: { subscription },
    } = authService.onAuthStateChange((_event, session) => {
      setSession(session);
      setUser(session?.user || null);
      setLoading(false);
    });

    return () => subscription.unsubscribe();
  }, [setUser, setSession, setLoading]);

  return (
    <BrowserRouter>
      {/* Toast container */}
      {toasts.map((toast) => (
        <Toast
          key={toast.id}
          message={toast.message}
          type={toast.type}
          onClose={() => removeToast(toast.id)}
        />
      ))}

      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route
          path="/"
          element={
            <ProtectedRoute>
              <PlaceholderPage title="Dashboard" />
            </ProtectedRoute>
          }
        />
        <Route
          path="/vocabulary"
          element={
            <ProtectedRoute>
              <PlaceholderPage title="Vocabulary" />
            </ProtectedRoute>
          }
        />
        <Route
          path="/vocabulary/add"
          element={
            <ProtectedRoute>
              <PlaceholderPage title="Add Word" />
            </ProtectedRoute>
          }
        />
        <Route
          path="/vocabulary/:id"
          element={
            <ProtectedRoute>
              <PlaceholderPage title="Word Detail" />
            </ProtectedRoute>
          }
        />
        <Route
          path="/collections"
          element={
            <ProtectedRoute>
              <PlaceholderPage title="Collections" />
            </ProtectedRoute>
          }
        />
        <Route
          path="/collections/:id"
          element={
            <ProtectedRoute>
              <PlaceholderPage title="Collection Detail" />
            </ProtectedRoute>
          }
        />
        <Route
          path="/settings"
          element={
            <ProtectedRoute>
              <PlaceholderPage title="Settings" />
            </ProtectedRoute>
          }
        />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
```

- [ ] **Step 6: Write auth service tests**

Create `web/src/services/__tests__/auth.service.test.js`:

```javascript
import { describe, it, expect, vi } from "vitest";

// Mock supabase
vi.mock("../../config/supabase", () => ({
  supabase: {
    auth: {
      signUp: vi.fn(),
      signInWithPassword: vi.fn(),
      signInWithOAuth: vi.fn(),
      signOut: vi.fn(),
      getSession: vi.fn(),
      onAuthStateChange: vi.fn(),
    },
  },
}));

import { authService } from "../auth.service";
import { supabase } from "../../config/supabase";

describe("authService", () => {
  it("signUp calls supabase.auth.signUp", async () => {
    supabase.auth.signUp.mockResolvedValue({
      data: { user: { id: "1" } },
      error: null,
    });
    const result = await authService.signUp("test@example.com", "password");
    expect(result.user).toBeDefined();
    expect(result.error).toBeNull();
  });

  it("signIn calls supabase.auth.signInWithPassword", async () => {
    supabase.auth.signInWithPassword.mockResolvedValue({
      data: { user: { id: "1" }, session: { access_token: "token" } },
      error: null,
    });
    const result = await authService.signIn("test@example.com", "password");
    expect(result.user).toBeDefined();
    expect(result.session).toBeDefined();
  });

  it("signOut calls supabase.auth.signOut", async () => {
    supabase.auth.signOut.mockResolvedValue({ error: null });
    await authService.signOut();
    expect(supabase.auth.signOut).toHaveBeenCalled();
  });
});
```

- [ ] **Step 7: Run tests and verify**

```bash
cd web
npx vitest run
```

Expected: All tests pass.

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "feat: add authentication with Supabase Auth, login page, and auth guard"
```

---

### Task 3: Database Schema & Migrations

**Files:**

- Create: `supabase/migrations/00001_create_profiles.sql`
- Create: `supabase/migrations/00002_create_vocabularies.sql`
- Create: `supabase/migrations/00003_create_definitions.sql`
- Create: `supabase/migrations/00004_create_collections.sql`
- Create: `supabase/migrations/00005_create_vocabulary_collections.sql`
- Create: `supabase/migrations/00006_create_user_settings.sql`
- Create: `supabase/migrations/00007_create_views.sql`
- Create: `supabase/migrations/00008_create_functions.sql`

**Interfaces:**

- Consumes: Supabase project (external prerequisite)
- Produces:
  - `profiles` table with auto-create trigger on `auth.users`
  - `vocabularies` table with RLS, indexes, `updated_at` trigger, CEFR level constraint
  - `definitions` table with RLS through vocabulary ownership, full-text search on Vietnamese
  - `collections` table with RLS, unique name per user constraint, default "Uncategorized" auto-create
  - `vocabulary_collections` junction table with RLS, unique constraint
  - `user_settings` table with RLS, auto-create default settings
  - `vocabulary_full` view with definitions + collection names aggregated
  - `get_vocab_count(p_user_id UUID)` → `INTEGER`
  - `get_level_distribution(p_user_id UUID)` → `TABLE(level TEXT, count INTEGER)`
  - `get_collection_distribution(p_user_id UUID)` → `TABLE(collection_name TEXT, count INTEGER)`
  - `get_daily_word_count(p_user_id UUID, p_days INTEGER)` → `TABLE(date DATE, count INTEGER)`
  - `check_duplicate_word(p_user_id UUID, p_word TEXT, p_definitions_vi TEXT[])` → duplicate check result

- [ ] **Step 1: Create migration files**

Copy the exact SQL from [Database_Schema.md](file:///f:/Side%20Projects/mewmory/docs/Database_Schema.md) into each migration file:

- `00001_create_profiles.sql` — Section 3.1 (profiles table + trigger + RLS)
- `00002_create_vocabularies.sql` — Section 3.2 (vocabularies table + indexes + `update_updated_at` function + trigger + RLS)
- `00003_create_definitions.sql` — Section 3.3 (definitions table + indexes + trigger + RLS)
- `00004_create_collections.sql` — Section 3.4 (collections table + indexes + trigger + RLS + default collection trigger)
- `00005_create_vocabulary_collections.sql` — Section 3.5 (junction table + indexes + trigger + RLS)
- `00006_create_user_settings.sql` — Section 3.6 (user_settings table + trigger + RLS + auto-create trigger)
- `00007_create_views.sql` — Section 5.1 (`vocabulary_full` view)
- `00008_create_functions.sql` — Sections 5.2 + 6 (stats functions + duplicate check function)

> [!NOTE]
> The `update_updated_at()` function is defined in `00002_create_vocabularies.sql` and reused by subsequent tables. Migration order matters.

- [ ] **Step 2: Run migrations**

> [!IMPORTANT]
> **⏸️ USER INTERACTION CHECKPOINT (Trước khi chạy Step 2):**
> **AI Agent PHẢI tạm dừng và hướng dẫn người dùng liên kết Supabase CLI với project:**
>
> 1. Nhắc người dùng đăng nhập CLI (nếu chưa): `supabase login`
> 2. Hướng dẫn người dùng lấy **Reference ID** từ Supabase Dashboard (URL: `https://supabase.com/dashboard/project/<PROJECT_REF>`).
> 3. Hướng dẫn chạy lệnh:
>    ```bash
>    supabase link --project-ref <PROJECT_REF>
>    ```
>    _(CLI sẽ hỏi database password đã tạo khi tạo project trên Supabase)_.
> 4. Sau khi link thành công, Agent mới chạy tiếp lệnh `supabase db push` để đẩy toàn bộ 8 file migration lên database cloud.

```bash
cd f:\Side Projects\mewmory
supabase db push
```

Expected: All migrations applied successfully.

- [ ] **Step 3: Verify schema via Supabase Dashboard**

Open Supabase Dashboard → Table Editor. Verify:

- All 6 tables exist with correct columns
- RLS is enabled on all tables
- Triggers exist for `updated_at` and auto-create profile/collection/settings

- [ ] **Step 4: Commit**

```bash
git add supabase/
git commit -m "feat: add database schema migrations with RLS, triggers, views, and functions"
```

---

### Task 4: Local Database (Dexie.js) + Vocabulary CRUD

**Files:**

- Create: `web/src/db/database.js`
- Create: `web/src/services/vocabulary.service.js`
- Create: `web/src/stores/vocabulary.store.js`
- Test: `web/src/services/__tests__/vocabulary.service.test.js`

**Interfaces:**

- Consumes: `supabase` client from Task 2
- Produces:
  - `db` — Dexie.js database instance with tables: `vocabularies`, `definitions`, `collections`, `vocabulary_collections`, `user_settings`, `sync_queue`
  - `vocabularyService.create(vocabularyData, definitions[]): Promise<{ vocabulary, definitions }>`
  - `vocabularyService.getAll(userId, { search?, filters?, sort?, offset?, limit? }): Promise<{ items, total }>`
  - `vocabularyService.getById(id): Promise<{ vocabulary, definitions, collections }>`
  - `vocabularyService.update(id, updates): Promise<vocabulary>`
  - `vocabularyService.delete(id): Promise<void>` — soft delete
  - `vocabularyService.checkDuplicate(userId, word): Promise<{ count, entries }>`
  - `useVocabularyStore` — Zustand store: `{ items, total, isLoading, filters, sort, search, setSearch, setFilters, setSort, fetchVocabularies, addVocabulary, updateVocabulary, deleteVocabulary }`

- [ ] **Step 1: Create Dexie.js database definition**

Create `web/src/db/database.js`:

```javascript
import Dexie from "dexie";

const db = new Dexie("mewmory");

db.version(1).stores({
  vocabularies:
    "id, user_id, word, cefr_level, part_of_speech, usage_register, created_at, updated_at, is_deleted",
  definitions: "id, vocabulary_id, sort_order, updated_at, is_deleted",
  collections: "id, user_id, name, is_default, updated_at, is_deleted",
  vocabulary_collections:
    "id, vocabulary_id, collection_id, updated_at, is_deleted",
  user_settings: "id, user_id",
  sync_queue: "++id, table_name, record_id, operation, created_at, synced",
});

export default db;
```

- [ ] **Step 2: Create vocabulary service**

Create `web/src/services/vocabulary.service.js`:

```javascript
import db from "../db/database";
import { PAGINATION } from "../utils/constants";

export const vocabularyService = {
  async create(vocabularyData, definitions = []) {
    const vocabId = crypto.randomUUID();
    const now = new Date().toISOString();

    const vocabulary = {
      id: vocabId,
      user_id: vocabularyData.user_id,
      word: vocabularyData.word.trim(),
      phonetic: vocabularyData.phonetic || null,
      audio_url: vocabularyData.audio_url || null,
      part_of_speech: vocabularyData.part_of_speech || null,
      cefr_level: vocabularyData.cefr_level || null,
      usage_register: vocabularyData.usage_register || null,
      created_at: now,
      updated_at: now,
      is_deleted: false,
    };

    const definitionRecords = definitions.map((def, index) => ({
      id: crypto.randomUUID(),
      vocabulary_id: vocabId,
      definition_en: def.definition_en || null,
      definition_vi: def.definition_vi || null,
      example: def.example || null,
      sort_order: index,
      created_at: now,
      updated_at: now,
      is_deleted: false,
    }));

    await db.transaction(
      "rw",
      [db.vocabularies, db.definitions, db.sync_queue],
      async () => {
        await db.vocabularies.put(vocabulary);
        if (definitionRecords.length > 0) {
          await db.definitions.bulkPut(definitionRecords);
        }

        // Add to sync queue
        await db.sync_queue.add({
          table_name: "vocabularies",
          record_id: vocabId,
          operation: "CREATE",
          payload: vocabulary,
          created_at: now,
          synced: false,
        });

        for (const def of definitionRecords) {
          await db.sync_queue.add({
            table_name: "definitions",
            record_id: def.id,
            operation: "CREATE",
            payload: def,
            created_at: now,
            synced: false,
          });
        }
      },
    );

    return { vocabulary, definitions: definitionRecords };
  },

  async getAll(
    userId,
    {
      search = "",
      filters = {},
      sort = { field: "created_at", order: "desc" },
      offset = 0,
      limit = PAGINATION.DEFAULT_LIMIT,
    } = {},
  ) {
    let collection = db.vocabularies
      .where("user_id")
      .equals(userId)
      .and((v) => !v.is_deleted);

    let items = await collection.toArray();

    // Apply search
    if (search) {
      const searchLower = search.toLowerCase();
      // Also search in definitions
      const allDefinitions = await db.definitions
        .where("is_deleted")
        .equals(0)
        .toArray();
      const vocabIdsWithMatchingDefs = new Set(
        allDefinitions
          .filter(
            (d) =>
              (d.definition_vi &&
                d.definition_vi.toLowerCase().includes(searchLower)) ||
              (d.definition_en &&
                d.definition_en.toLowerCase().includes(searchLower)),
          )
          .map((d) => d.vocabulary_id),
      );

      items = items.filter(
        (v) =>
          v.word.toLowerCase().includes(searchLower) ||
          vocabIdsWithMatchingDefs.has(v.id),
      );
    }

    // Apply filters
    if (filters.cefr_level) {
      items = items.filter((v) => v.cefr_level === filters.cefr_level);
    }
    if (filters.part_of_speech) {
      items = items.filter((v) => v.part_of_speech === filters.part_of_speech);
    }
    if (filters.usage_register) {
      items = items.filter((v) => v.usage_register === filters.usage_register);
    }
    if (filters.collection_id) {
      const vcLinks = await db.vocabulary_collections
        .where("collection_id")
        .equals(filters.collection_id)
        .and((vc) => !vc.is_deleted)
        .toArray();
      const vocabIds = new Set(vcLinks.map((vc) => vc.vocabulary_id));
      items = items.filter((v) => vocabIds.has(v.id));
    }

    const total = items.length;

    // Sort
    items.sort((a, b) => {
      const aVal = a[sort.field] || "";
      const bVal = b[sort.field] || "";
      const comparison =
        typeof aVal === "string" ? aVal.localeCompare(bVal) : aVal - bVal;
      return sort.order === "desc" ? -comparison : comparison;
    });

    // Paginate
    items = items.slice(offset, offset + limit);

    // Attach definitions to each vocabulary
    for (const item of items) {
      item.definitions = await db.definitions
        .where("vocabulary_id")
        .equals(item.id)
        .and((d) => !d.is_deleted)
        .sortBy("sort_order");
    }

    return { items, total };
  },

  async getById(id) {
    const vocabulary = await db.vocabularies.get(id);
    if (!vocabulary || vocabulary.is_deleted) return null;

    const definitions = await db.definitions
      .where("vocabulary_id")
      .equals(id)
      .and((d) => !d.is_deleted)
      .sortBy("sort_order");

    const vcLinks = await db.vocabulary_collections
      .where("vocabulary_id")
      .equals(id)
      .and((vc) => !vc.is_deleted)
      .toArray();
    const collectionIds = vcLinks.map((vc) => vc.collection_id);
    const collections =
      collectionIds.length > 0
        ? await db.collections
            .where("id")
            .anyOf(collectionIds)
            .and((c) => !c.is_deleted)
            .toArray()
        : [];

    return { vocabulary, definitions, collections };
  },

  async update(id, updates) {
    const now = new Date().toISOString();
    const updated = { ...updates, updated_at: now };
    delete updated.id;

    await db.transaction("rw", [db.vocabularies, db.sync_queue], async () => {
      await db.vocabularies.update(id, updated);
      await db.sync_queue.add({
        table_name: "vocabularies",
        record_id: id,
        operation: "UPDATE",
        payload: updated,
        created_at: now,
        synced: false,
      });
    });

    return db.vocabularies.get(id);
  },

  async delete(id) {
    const now = new Date().toISOString();

    await db.transaction(
      "rw",
      [
        db.vocabularies,
        db.definitions,
        db.vocabulary_collections,
        db.sync_queue,
      ],
      async () => {
        // Soft delete vocabulary
        await db.vocabularies.update(id, { is_deleted: true, updated_at: now });

        // Soft delete related definitions
        const defs = await db.definitions
          .where("vocabulary_id")
          .equals(id)
          .toArray();
        for (const def of defs) {
          await db.definitions.update(def.id, {
            is_deleted: true,
            updated_at: now,
          });
        }

        // Soft delete related collection links
        const vcLinks = await db.vocabulary_collections
          .where("vocabulary_id")
          .equals(id)
          .toArray();
        for (const vc of vcLinks) {
          await db.vocabulary_collections.update(vc.id, {
            is_deleted: true,
            updated_at: now,
          });
        }

        // Add to sync queue
        await db.sync_queue.add({
          table_name: "vocabularies",
          record_id: id,
          operation: "DELETE",
          payload: { is_deleted: true },
          created_at: now,
          synced: false,
        });
      },
    );
  },

  async checkDuplicate(userId, word) {
    const matches = await db.vocabularies
      .where("user_id")
      .equals(userId)
      .and(
        (v) =>
          !v.is_deleted && v.word.toLowerCase() === word.toLowerCase().trim(),
      )
      .toArray();

    return { count: matches.length, entries: matches };
  },
};
```

- [ ] **Step 3: Create vocabulary Zustand store**

Create `web/src/stores/vocabulary.store.js`:

```javascript
import { create } from "zustand";
import { vocabularyService } from "../services/vocabulary.service";

export const useVocabularyStore = create((set, get) => ({
  items: [],
  total: 0,
  isLoading: false,
  search: "",
  filters: {},
  sort: { field: "created_at", order: "desc" },
  offset: 0,

  setSearch: (search) => set({ search, offset: 0 }),
  setFilters: (filters) => set({ filters, offset: 0 }),
  setSort: (sort) => set({ sort, offset: 0 }),
  setOffset: (offset) => set({ offset }),

  fetchVocabularies: async (userId) => {
    set({ isLoading: true });
    try {
      const { search, filters, sort, offset } = get();
      const result = await vocabularyService.getAll(userId, {
        search,
        filters,
        sort,
        offset,
      });
      set({ items: result.items, total: result.total });
    } catch (error) {
      console.error("Failed to fetch vocabularies:", error);
    } finally {
      set({ isLoading: false });
    }
  },

  addVocabulary: async (vocabularyData, definitions) => {
    const result = await vocabularyService.create(vocabularyData, definitions);
    return result;
  },

  updateVocabulary: async (id, updates) => {
    return vocabularyService.update(id, updates);
  },

  deleteVocabulary: async (id) => {
    await vocabularyService.delete(id);
  },
}));
```

- [ ] **Step 4: Write vocabulary service tests**

Create `web/src/services/__tests__/vocabulary.service.test.js`:

```javascript
import { describe, it, expect, beforeEach } from "vitest";
import "fake-indexeddb/auto";
import db from "../../db/database";
import { vocabularyService } from "../vocabulary.service";

const TEST_USER_ID = "test-user-123";

beforeEach(async () => {
  await db.vocabularies.clear();
  await db.definitions.clear();
  await db.vocabulary_collections.clear();
  await db.sync_queue.clear();
});

describe("vocabularyService", () => {
  it("creates a vocabulary with definitions", async () => {
    const result = await vocabularyService.create(
      {
        user_id: TEST_USER_ID,
        word: "resilient",
        cefr_level: "C1",
        part_of_speech: "adjective",
      },
      [
        {
          definition_en: "able to recover",
          definition_vi: "kiên cường",
          example: "She is resilient.",
        },
      ],
    );

    expect(result.vocabulary.word).toBe("resilient");
    expect(result.definitions).toHaveLength(1);
    expect(result.definitions[0].definition_vi).toBe("kiên cường");

    // Check sync queue
    const queue = await db.sync_queue.toArray();
    expect(queue.length).toBeGreaterThanOrEqual(2); // vocab + definition
  });

  it("getAll returns vocabularies for user", async () => {
    await vocabularyService.create({ user_id: TEST_USER_ID, word: "hello" }, [
      { definition_vi: "xin chào" },
    ]);
    await vocabularyService.create({ user_id: TEST_USER_ID, word: "world" }, [
      { definition_vi: "thế giới" },
    ]);

    const result = await vocabularyService.getAll(TEST_USER_ID);
    expect(result.items).toHaveLength(2);
    expect(result.total).toBe(2);
  });

  it("getAll with search filters by word", async () => {
    await vocabularyService.create(
      { user_id: TEST_USER_ID, word: "apple" },
      [],
    );
    await vocabularyService.create(
      { user_id: TEST_USER_ID, word: "banana" },
      [],
    );

    const result = await vocabularyService.getAll(TEST_USER_ID, {
      search: "apple",
    });
    expect(result.items).toHaveLength(1);
    expect(result.items[0].word).toBe("apple");
  });

  it("getById returns vocabulary with definitions and collections", async () => {
    const { vocabulary } = await vocabularyService.create(
      { user_id: TEST_USER_ID, word: "test" },
      [{ definition_vi: "kiểm tra" }],
    );

    const result = await vocabularyService.getById(vocabulary.id);
    expect(result.vocabulary.word).toBe("test");
    expect(result.definitions).toHaveLength(1);
  });

  it("delete soft-deletes vocabulary", async () => {
    const { vocabulary } = await vocabularyService.create(
      { user_id: TEST_USER_ID, word: "delete-me" },
      [],
    );

    await vocabularyService.delete(vocabulary.id);

    const result = await vocabularyService.getById(vocabulary.id);
    expect(result).toBeNull();
  });

  it("checkDuplicate finds existing word", async () => {
    await vocabularyService.create(
      { user_id: TEST_USER_ID, word: "duplicate" },
      [],
    );

    const result = await vocabularyService.checkDuplicate(
      TEST_USER_ID,
      "Duplicate",
    );
    expect(result.count).toBe(1);
  });
});
```

> Install `fake-indexeddb` for tests: `npm install -D fake-indexeddb`

- [ ] **Step 5: Run tests**

```bash
cd web
npx vitest run
```

Expected: All tests pass.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: add Dexie.js local database and vocabulary CRUD service with offline-first sync queue"
```

---

### Task 5: Layout & Navigation Shell

**Files:**

- Create: `web/src/components/layout/MainLayout.jsx`
- Create: `web/src/components/layout/Sidebar.jsx`
- Create: `web/src/components/layout/Header.jsx`
- Create: `web/src/components/common/OfflineBadge.jsx`
- Create: `web/src/hooks/useOnlineStatus.js`
- Modify: `web/src/App.jsx` — wrap protected routes in `MainLayout`

**Interfaces:**

- Consumes: `useAuthStore`, `useUIStore`, `<Button />`, `<OfflineBadge />` from earlier tasks
- Produces:
  - `<MainLayout />` — sidebar + header + content area wrapper
  - `<Sidebar />` — navigation links: Dashboard, Vocabulary, Collections, Settings
  - `<Header />` — top bar with page title, offline badge, user menu
  - `<OfflineBadge />` — shows "Offline" indicator
  - `useOnlineStatus()` → `{ isOnline: boolean }`

- [ ] **Step 1: Create useOnlineStatus hook**

Create `web/src/hooks/useOnlineStatus.js`:

```javascript
import { useState, useEffect } from "react";

export function useOnlineStatus() {
  const [isOnline, setIsOnline] = useState(navigator.onLine);

  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);

    window.addEventListener("online", handleOnline);
    window.addEventListener("offline", handleOffline);

    return () => {
      window.removeEventListener("online", handleOnline);
      window.removeEventListener("offline", handleOffline);
    };
  }, []);

  return { isOnline };
}
```

- [ ] **Step 2: Create OfflineBadge**

Create `web/src/components/common/OfflineBadge.jsx`:

```jsx
import { useOnlineStatus } from "../../hooks/useOnlineStatus";

export default function OfflineBadge() {
  const { isOnline } = useOnlineStatus();

  if (isOnline) return null;

  return (
    <div className="inline-flex items-center gap-1.5 px-3 py-1 bg-amber-50 text-amber-700 border border-amber-200 rounded-pill text-body-sm">
      <span className="w-2 h-2 rounded-full bg-amber-500 animate-pulse" />
      Offline
    </div>
  );
}
```

- [ ] **Step 3: Create Sidebar component**

Create `web/src/components/layout/Sidebar.jsx`:

```jsx
import { NavLink } from "react-router-dom";
import { useAuthStore } from "../../stores/auth.store";
import { authService } from "../../services/auth.service";
import { useUIStore } from "../../stores/ui.store";

const navItems = [
  { to: "/", label: "Dashboard", icon: "📊" },
  { to: "/vocabulary", label: "Từ vựng", icon: "📖" },
  { to: "/collections", label: "Collections", icon: "📚" },
  { to: "/settings", label: "Cài đặt", icon: "⚙️" },
];

export default function Sidebar() {
  const { user, signOut: clearAuth } = useAuthStore();
  const addToast = useUIStore((s) => s.addToast);

  const handleSignOut = async () => {
    try {
      await authService.signOut();
      clearAuth();
    } catch (err) {
      addToast("Lỗi đăng xuất", "error");
    }
  };

  return (
    <aside className="w-60 h-screen bg-warm-taupe border-r border-stone flex flex-col fixed left-0 top-0">
      {/* Logo */}
      <div className="p-6 pb-4">
        <h1 className="text-heading-sm font-display font-light tracking-tight">
          Mewmory
        </h1>
      </div>

      <div className="h-px bg-stone mx-4" />

      {/* Navigation */}
      <nav className="flex-1 p-4 flex flex-col gap-1">
        {navItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            end={item.to === "/"}
            className={({ isActive }) =>
              `flex items-center gap-3 px-3 py-2.5 rounded-lg text-body-sm transition-colors ${
                isActive
                  ? "bg-eggshell text-ink font-medium shadow-subtle-inset"
                  : "text-smoke hover:text-ink hover:bg-eggshell/60"
              }`
            }
          >
            <span>{item.icon}</span>
            {item.label}
          </NavLink>
        ))}
      </nav>

      {/* User section */}
      <div className="p-4 border-t border-stone">
        <div className="flex items-center gap-3 mb-3">
          <div className="w-8 h-8 rounded-full bg-stone flex items-center justify-center text-caption text-graphite">
            {user?.email?.[0]?.toUpperCase() || "?"}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-body-sm text-ink truncate">
              {user?.email || "User"}
            </p>
          </div>
        </div>
        <button
          onClick={handleSignOut}
          className="w-full text-left px-3 py-2 text-body-sm text-smoke hover:text-ink transition-colors rounded-lg hover:bg-eggshell/60"
        >
          Đăng xuất
        </button>
      </div>
    </aside>
  );
}
```

- [ ] **Step 4: Create Header component**

Create `web/src/components/layout/Header.jsx`:

```jsx
import OfflineBadge from "../common/OfflineBadge";

export default function Header({ title }) {
  return (
    <header className="h-14 border-b border-stone bg-eggshell flex items-center justify-between px-6">
      <h2 className="text-subheading font-display font-light">{title}</h2>
      <div className="flex items-center gap-4">
        <OfflineBadge />
      </div>
    </header>
  );
}
```

- [ ] **Step 5: Create MainLayout wrapper**

Create `web/src/components/layout/MainLayout.jsx`:

```jsx
import { Outlet } from "react-router-dom";
import Sidebar from "./Sidebar";

export default function MainLayout() {
  return (
    <div className="flex min-h-screen bg-eggshell">
      <Sidebar />
      <main className="flex-1 ml-60 overflow-auto">
        <Outlet />
      </main>
    </div>
  );
}
```

- [ ] **Step 6: Update App.jsx to use MainLayout with nested routes**

Update `App.jsx` routing to nest protected routes under `<MainLayout />`:

```jsx
// In the Routes section of App.jsx, replace the flat protected routes with:
<Route
  element={
    <ProtectedRoute>
      <MainLayout />
    </ProtectedRoute>
  }
>
  <Route path="/" element={<PlaceholderPage title="Dashboard" />} />
  <Route path="/vocabulary" element={<PlaceholderPage title="Vocabulary" />} />
  <Route
    path="/vocabulary/add"
    element={<PlaceholderPage title="Add Word" />}
  />
  <Route
    path="/vocabulary/:id"
    element={<PlaceholderPage title="Word Detail" />}
  />
  <Route
    path="/collections"
    element={<PlaceholderPage title="Collections" />}
  />
  <Route
    path="/collections/:id"
    element={<PlaceholderPage title="Collection Detail" />}
  />
  <Route path="/settings" element={<PlaceholderPage title="Settings" />} />
</Route>
```

Import `MainLayout` at the top of App.jsx.

- [ ] **Step 7: Verify visually — run dev server**

```bash
cd web
npm run dev
```

Check: Login page renders, after login sidebar and header appear, nav links work.

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "feat: add layout shell with sidebar navigation, header, and offline badge"
```

---

### Task 6: Edge Functions (lookup-word & ai-classify)

**Files:**

- Create: `supabase/functions/lookup-word/index.ts`
- Create: `supabase/functions/ai-classify/index.ts`

**Interfaces:**

- Consumes: Supabase project, `GEMINI_API_KEY` / `OPENROUTER_API_KEY` secrets
- Produces:
  - `POST /functions/v1/lookup-word` — `{ word, provider?, model? }` → `{ word, phonetic, audio_url, meanings[], suggested_collections[], source }`
  - `POST /functions/v1/ai-classify` — `{ word, definitions_vi[], existing_collections[] }` → `{ suggested_collections[], new_collections[], existing_matches[] }`

- [ ] **Step 1: Create lookup-word Edge Function**

Create `supabase/functions/lookup-word/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface LookupRequest {
  word: string;
  provider?: "gemini" | "openrouter";
  model?: string;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Verify auth
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const {
      word,
      provider = "gemini",
      model,
    }: LookupRequest = await req.json();

    if (!word || typeof word !== "string" || word.trim().length === 0) {
      return new Response(JSON.stringify({ error: "Word is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const trimmedWord = word.trim().toLowerCase();

    // Call Dictionary API + AI API in parallel
    const [dictResult, aiResult] = await Promise.allSettled([
      fetchDictionary(trimmedWord),
      fetchAI(trimmedWord, provider, model),
    ]);

    const dictData =
      dictResult.status === "fulfilled" ? dictResult.value : null;
    const aiData = aiResult.status === "fulfilled" ? aiResult.value : null;

    if (!dictData && !aiData) {
      return new Response(
        JSON.stringify({ error: "All lookup services unavailable" }),
        {
          status: 503,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Merge results
    const result = mergeResults(trimmedWord, dictData, aiData);

    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: "Internal server error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

async function fetchDictionary(word: string) {
  const response = await fetch(
    `https://api.dictionaryapi.dev/api/v2/entries/en/${word}`,
  );
  if (!response.ok) return null;
  return response.json();
}

async function fetchAI(word: string, provider: string, model?: string) {
  const prompt = `You are a vocabulary analysis assistant. Given an English word, provide additional information in JSON format.

Word: "${word}"

Return a JSON object with:
{
  "cefr_level": "A1|A2|B1|B2|C1|C2",
  "usage_register": "formal|informal|slang|neutral|vulgar|technical",
  "vietnamese_definitions": [
    {
      "part_of_speech": "<part of speech>",
      "original_en": "<English definition>",
      "translation_vi": "<Vietnamese translation>",
      "example": "<example sentence>"
    }
  ],
  "suggested_collections": ["<topic categories like Travel, Business, etc.>"]
}

Rules:
- CEFR level should reflect the word's difficulty for learners.
- Vietnamese translations should be natural and contextual, not literal.
- Suggested collections should be broad topic categories.
- Return ONLY valid JSON, no markdown or explanation.`;

  if (provider === "gemini") {
    return callGemini(prompt, model);
  } else {
    return callOpenRouter(prompt, model);
  }
}

async function callGemini(prompt: string, model?: string) {
  const apiKey = Deno.env.get("GEMINI_API_KEY");
  if (!apiKey) throw new Error("GEMINI_API_KEY not set");

  const modelName = model || "gemini-2.0-flash";
  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${modelName}:generateContent?key=${apiKey}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { responseMimeType: "application/json" },
      }),
    },
  );

  if (!response.ok) throw new Error(`Gemini API error: ${response.status}`);
  const data = await response.json();
  const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
  return JSON.parse(text);
}

async function callOpenRouter(prompt: string, model?: string) {
  const apiKey = Deno.env.get("OPENROUTER_API_KEY");
  if (!apiKey) throw new Error("OPENROUTER_API_KEY not set");

  const modelName = model || "meta-llama/llama-3.1-8b-instruct:free";
  const response = await fetch(
    "https://openrouter.ai/api/v1/chat/completions",
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: modelName,
        messages: [{ role: "user", content: prompt }],
        response_format: { type: "json_object" },
      }),
    },
  );

  if (!response.ok) throw new Error(`OpenRouter API error: ${response.status}`);
  const data = await response.json();
  const text = data.choices?.[0]?.message?.content;
  return JSON.parse(text);
}

function mergeResults(word: string, dictData: any, aiData: any) {
  const result: any = {
    word,
    phonetic: null,
    audio_url: null,
    meanings: [],
    suggested_collections: [],
    source: { dictionary: !!dictData, ai: !!aiData },
  };

  // Extract dictionary data
  if (dictData && Array.isArray(dictData) && dictData.length > 0) {
    const entry = dictData[0];
    result.phonetic =
      entry.phonetic || entry.phonetics?.find((p: any) => p.text)?.text || null;
    result.audio_url =
      entry.phonetics?.find((p: any) => p.audio)?.audio || null;

    for (const meaning of entry.meanings || []) {
      const m: any = {
        part_of_speech: meaning.partOfSpeech,
        cefr_level: aiData?.cefr_level || null,
        usage_register: aiData?.usage_register || null,
        definitions: [],
      };

      for (const def of meaning.definitions || []) {
        const aiVi = aiData?.vietnamese_definitions?.find(
          (v: any) =>
            v.original_en &&
            def.definition &&
            (v.original_en
              .toLowerCase()
              .includes(def.definition.substring(0, 30).toLowerCase()) ||
              def.definition
                .toLowerCase()
                .includes(v.original_en.substring(0, 30).toLowerCase())),
        );

        m.definitions.push({
          definition_en: def.definition || null,
          definition_vi: aiVi?.translation_vi || null,
          example: def.example || aiVi?.example || null,
          synonyms: def.synonyms || [],
          antonyms: def.antonyms || [],
        });
      }

      result.meanings.push(m);
    }
  } else if (aiData?.vietnamese_definitions) {
    // AI-only mode
    const grouped: Record<string, any[]> = {};
    for (const viDef of aiData.vietnamese_definitions) {
      const pos = viDef.part_of_speech || "unknown";
      if (!grouped[pos]) grouped[pos] = [];
      grouped[pos].push(viDef);
    }
    for (const [pos, defs] of Object.entries(grouped)) {
      result.meanings.push({
        part_of_speech: pos,
        cefr_level: aiData.cefr_level || null,
        usage_register: aiData.usage_register || null,
        definitions: defs.map((d: any) => ({
          definition_en: d.original_en || null,
          definition_vi: d.translation_vi || null,
          example: d.example || null,
          synonyms: [],
          antonyms: [],
        })),
      });
    }
  }

  result.suggested_collections = aiData?.suggested_collections || [];

  return result;
}
```

- [ ] **Step 2: Create ai-classify Edge Function**

Create `supabase/functions/ai-classify/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { word, definitions_vi, existing_collections } = await req.json();

    if (!word) {
      return new Response(JSON.stringify({ error: "Word is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const prompt = `Given the English word "${word}" with Vietnamese meanings: ${JSON.stringify(definitions_vi)}, and the user's existing collections: ${JSON.stringify(existing_collections)}, suggest appropriate collections for this word.

Return a JSON object:
{
  "suggested_collections": ["<all suggested collections>"],
  "new_collections": ["<collections that don't exist yet>"],
  "existing_matches": ["<collections that already exist and match>"]
}

Rules:
- Prefer matching existing collections when appropriate.
- Suggest 1-3 collections maximum.
- Use broad, reusable topic names (Travel, Business, Technology, etc.).
- Return ONLY valid JSON.`;

    const apiKey = Deno.env.get("GEMINI_API_KEY");
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: "AI API key not configured" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
          generationConfig: { responseMimeType: "application/json" },
        }),
      },
    );

    if (!response.ok) throw new Error(`AI API error: ${response.status}`);
    const data = await response.json();
    const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
    const result = JSON.parse(text);

    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: "Internal server error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
```

- [ ] **Step 3: Deploy Edge Functions & Set AI Secrets**

> [!IMPORTANT]
> **⏸️ USER INTERACTION CHECKPOINT (Trước khi deploy Edge Functions):**
> **AI Agent PHẢI tạm dừng và hướng dẫn người dùng cấu hình API Key AI:**
>
> 1. Nhắc người dùng lấy **Google Gemini API Key** tại [Google AI Studio](https://aistudio.google.com/) (hoặc OpenRouter API Key).
> 2. Hướng dẫn người dùng chạy lệnh để cài secret lên Supabase Cloud:
>    ```bash
>    supabase secrets set GEMINI_API_KEY="<YOUR_GEMINI_KEY>"
>    ```
>    _(Hoặc vào Supabase Dashboard -> Project Settings -> Edge Functions -> Secrets để thêm thủ công)_.
> 3. Chờ người dùng xác nhận đã set secret xong, sau đó Agent mới chạy lệnh deploy:

```bash
supabase functions deploy lookup-word
supabase functions deploy ai-classify
```

- [ ] **Step 4: Test Edge Functions via cURL**

```bash
curl -X POST https://<project>.supabase.co/functions/v1/lookup-word \
  -H "Authorization: Bearer <anon-key>" \
  -H "Content-Type: application/json" \
  -d '{"word": "resilient", "provider": "gemini"}'
```

Expected: JSON response with phonetic, meanings, suggested_collections.

- [ ] **Step 5: Commit**

```bash
git add supabase/functions/
git commit -m "feat: add Edge Functions for word lookup (Dictionary + AI) and collection classification"
```

---

### Task 7: Smart Vocabulary Input (AddWordPage)

**Files:**

- Create: `web/src/services/lookup.service.js`
- Create: `web/src/pages/AddWordPage.jsx`
- Create: `web/src/components/vocabulary/LookupResult.jsx`
- Create: `web/src/components/vocabulary/MeaningSelector.jsx`
- Create: `web/src/components/vocabulary/DuplicateWarning.jsx`
- Create: `web/src/hooks/useDebouncedSearch.js`
- Modify: `web/src/App.jsx` — replace AddWordPage placeholder

**Interfaces:**

- Consumes: `supabase` client, `vocabularyService.create()`, `vocabularyService.checkDuplicate()`, `useAuthStore`, `useUIStore`, `<Button />`, `<Input />`, `<LoadingSpinner />`, constants
- Produces:
  - `lookupService.lookupWord(word, provider?, model?): Promise<LookupResult>`
  - `<AddWordPage />` — full smart input page with lookup, result display, meaning selection, edit, collection selection, save
  - `<LookupResult />` — displays lookup results grouped by part of speech
  - `<MeaningSelector />` — checkboxes for selecting which definitions to save
  - `<DuplicateWarning />` — warning badge when word already exists
  - `useDebouncedSearch(value, delay)` → debouncedValue

- [ ] **Step 1: Create lookup service**

Create `web/src/services/lookup.service.js`:

```javascript
import { supabase } from "../config/supabase";

export const lookupService = {
  async lookupWord(word, provider = "gemini", model = null) {
    const { data, error } = await supabase.functions.invoke("lookup-word", {
      body: { word: word.trim(), provider, model },
    });

    if (error) throw error;
    return data;
  },
};
```

- [ ] **Step 2: Create useDebouncedSearch hook**

Create `web/src/hooks/useDebouncedSearch.js`:

```javascript
import { useState, useEffect } from "react";

export function useDebouncedSearch(value, delay = 300) {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}
```

- [ ] **Step 3: Create DuplicateWarning component**

Create `web/src/components/vocabulary/DuplicateWarning.jsx`:

```jsx
export default function DuplicateWarning({ count, onViewExisting }) {
  if (!count || count === 0) return null;

  return (
    <div className="flex items-center gap-2 px-3 py-2 bg-amber-50 border border-amber-200 rounded-lg text-body-sm text-amber-800">
      <span>⚠️</span>
      <span>
        Từ này đã có <strong>{count}</strong>{" "}
        {count === 1 ? "entry" : "entries"}
      </span>
      {onViewExisting && (
        <button
          onClick={onViewExisting}
          className="ml-auto text-amber-900 underline hover:no-underline"
        >
          Xem
        </button>
      )}
    </div>
  );
}
```

- [ ] **Step 4: Create MeaningSelector component**

Create `web/src/components/vocabulary/MeaningSelector.jsx`:

```jsx
import { useState } from "react";

export default function MeaningSelector({
  meanings,
  selectedMeanings,
  onSelectionChange,
}) {
  const handleToggleMeaning = (meaningIdx, defIdx) => {
    const key = `${meaningIdx}-${defIdx}`;
    const newSelection = { ...selectedMeanings };
    if (newSelection[key]) {
      delete newSelection[key];
    } else {
      newSelection[key] = { meaningIdx, defIdx };
    }
    onSelectionChange(newSelection);
  };

  if (!meanings || meanings.length === 0) {
    return <p className="text-smoke text-body-sm">Không tìm thấy nghĩa nào.</p>;
  }

  return (
    <div className="flex flex-col gap-4">
      {meanings.map((meaning, mIdx) => (
        <div key={mIdx} className="card-taupe">
          <div className="flex items-center gap-2 mb-3">
            <span className="px-2 py-0.5 bg-eggshell rounded-pill text-body-sm text-ink font-medium border border-stone">
              {meaning.part_of_speech}
            </span>
            {meaning.cefr_level && (
              <span className="px-2 py-0.5 bg-eggshell rounded-pill text-body-sm text-smoke border border-stone">
                {meaning.cefr_level}
              </span>
            )}
            {meaning.usage_register && (
              <span className="px-2 py-0.5 bg-eggshell rounded-pill text-body-sm text-smoke border border-stone">
                {meaning.usage_register}
              </span>
            )}
          </div>

          <div className="flex flex-col gap-2">
            {meaning.definitions.map((def, dIdx) => {
              const key = `${mIdx}-${dIdx}`;
              const isSelected = !!selectedMeanings[key];

              return (
                <label
                  key={dIdx}
                  className={`flex items-start gap-3 p-3 rounded-lg cursor-pointer transition-colors ${
                    isSelected
                      ? "bg-eggshell border border-ink/10"
                      : "hover:bg-eggshell/60"
                  }`}
                >
                  <input
                    type="checkbox"
                    checked={isSelected}
                    onChange={() => handleToggleMeaning(mIdx, dIdx)}
                    className="mt-1 accent-ink"
                  />
                  <div className="flex-1">
                    {def.definition_en && (
                      <p className="text-body-sm text-ink">
                        {def.definition_en}
                      </p>
                    )}
                    {def.definition_vi && (
                      <p className="text-body-sm text-smoke mt-0.5">
                        → {def.definition_vi}
                      </p>
                    )}
                    {def.example && (
                      <p className="text-caption text-ash mt-1 italic">
                        "{def.example}"
                      </p>
                    )}
                  </div>
                </label>
              );
            })}
          </div>
        </div>
      ))}
    </div>
  );
}
```

- [ ] **Step 5: Create LookupResult component**

Create `web/src/components/vocabulary/LookupResult.jsx`:

```jsx
export default function LookupResult({ result, onPlayAudio }) {
  if (!result) return null;

  return (
    <div className="flex items-center gap-4 p-4 bg-warm-taupe rounded-card">
      <div className="flex-1">
        <div className="flex items-center gap-3">
          <h3 className="text-heading-sm font-display font-light">
            {result.word}
          </h3>
          {result.audio_url && (
            <button
              onClick={() => onPlayAudio(result.audio_url)}
              className="w-8 h-8 rounded-full bg-eggshell border border-stone flex items-center justify-center hover:bg-stone/50 transition-colors"
              title="Phát âm"
            >
              🔊
            </button>
          )}
        </div>
        {result.phonetic && (
          <p className="text-body text-smoke font-mono mt-1">
            {result.phonetic}
          </p>
        )}
      </div>
      <div className="flex gap-2">
        {result.source?.dictionary && (
          <span className="px-2 py-0.5 bg-green-50 text-green-700 rounded-pill text-caption border border-green-200">
            Dictionary ✓
          </span>
        )}
        {result.source?.ai && (
          <span className="px-2 py-0.5 bg-blue-50 text-blue-700 rounded-pill text-caption border border-blue-200">
            AI ✓
          </span>
        )}
      </div>
    </div>
  );
}
```

- [ ] **Step 6: Create AddWordPage**

Create `web/src/pages/AddWordPage.jsx`:

```jsx
import { useState, useEffect, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import { useAuthStore } from "../stores/auth.store";
import { useUIStore } from "../stores/ui.store";
import { vocabularyService } from "../services/vocabulary.service";
import { lookupService } from "../services/lookup.service";
import { useOnlineStatus } from "../hooks/useOnlineStatus";
import { useDebouncedSearch } from "../hooks/useDebouncedSearch";
import { validateWord } from "../utils/validators";
import Header from "../components/layout/Header";
import Button from "../components/common/Button";
import Input from "../components/common/Input";
import LoadingSpinner from "../components/common/LoadingSpinner";
import LookupResult from "../components/vocabulary/LookupResult";
import MeaningSelector from "../components/vocabulary/MeaningSelector";
import DuplicateWarning from "../components/vocabulary/DuplicateWarning";

export default function AddWordPage() {
  const navigate = useNavigate();
  const { user } = useAuthStore();
  const addToast = useUIStore((s) => s.addToast);
  const { isOnline } = useOnlineStatus();

  const [word, setWord] = useState("");
  const [lookupResult, setLookupResult] = useState(null);
  const [selectedMeanings, setSelectedMeanings] = useState({});
  const [isLooking, setIsLooking] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [duplicateCount, setDuplicateCount] = useState(0);
  const [wordError, setWordError] = useState("");

  // Manual field overrides
  const [editFields, setEditFields] = useState({
    phonetic: "",
    cefr_level: "",
    usage_register: "",
  });

  const debouncedWord = useDebouncedSearch(word, 300);

  // Check for duplicates on debounced word change
  useEffect(() => {
    if (debouncedWord && user) {
      vocabularyService
        .checkDuplicate(user.id, debouncedWord)
        .then(({ count }) => setDuplicateCount(count));
    } else {
      setDuplicateCount(0);
    }
  }, [debouncedWord, user]);

  const handleLookup = async () => {
    const validation = validateWord(word);
    if (!validation.valid) {
      setWordError(validation.error);
      return;
    }
    setWordError("");

    if (!isOnline) {
      addToast("Cần kết nối mạng để tra cứu", "error");
      return;
    }

    setIsLooking(true);
    try {
      const result = await lookupService.lookupWord(word);
      setLookupResult(result);
      setEditFields({
        phonetic: result.phonetic || "",
        cefr_level: result.meanings?.[0]?.cefr_level || "",
        usage_register: result.meanings?.[0]?.usage_register || "",
      });
      // Auto-select all meanings
      const selection = {};
      result.meanings?.forEach((m, mIdx) => {
        m.definitions?.forEach((_, dIdx) => {
          selection[`${mIdx}-${dIdx}`] = { meaningIdx: mIdx, defIdx: dIdx };
        });
      });
      setSelectedMeanings(selection);
    } catch (err) {
      addToast(err.message || "Lỗi tra cứu từ vựng", "error");
    } finally {
      setIsLooking(false);
    }
  };

  const handleSave = async () => {
    if (!user || Object.keys(selectedMeanings).length === 0) {
      addToast("Vui lòng chọn ít nhất 1 nghĩa", "error");
      return;
    }

    setIsSaving(true);
    try {
      // Group selected definitions by meaning (part_of_speech)
      const groupedByMeaning = {};
      for (const [key, { meaningIdx, defIdx }] of Object.entries(
        selectedMeanings,
      )) {
        if (!groupedByMeaning[meaningIdx]) groupedByMeaning[meaningIdx] = [];
        groupedByMeaning[meaningIdx].push(defIdx);
      }

      // Create one vocabulary entry per part_of_speech
      for (const [mIdxStr, defIndices] of Object.entries(groupedByMeaning)) {
        const mIdx = parseInt(mIdxStr);
        const meaning = lookupResult.meanings[mIdx];

        const vocabData = {
          user_id: user.id,
          word: lookupResult.word || word.trim(),
          phonetic: editFields.phonetic || lookupResult.phonetic || null,
          audio_url: lookupResult.audio_url || null,
          part_of_speech: meaning.part_of_speech || null,
          cefr_level: editFields.cefr_level || meaning.cefr_level || null,
          usage_register:
            editFields.usage_register || meaning.usage_register || null,
        };

        const definitions = defIndices.map((dIdx) => meaning.definitions[dIdx]);

        await vocabularyService.create(vocabData, definitions);
      }

      addToast("Đã lưu thành công!", "success");
      navigate("/vocabulary");
    } catch (err) {
      addToast(err.message || "Lỗi lưu từ vựng", "error");
    } finally {
      setIsSaving(false);
    }
  };

  const handlePlayAudio = (url) => {
    const audio = new Audio(url);
    audio.play().catch(() => addToast("Không thể phát audio", "error"));
  };

  const handleKeyDown = (e) => {
    if (e.key === "Enter") handleLookup();
  };

  return (
    <>
      <Header title="Thêm từ mới" />
      <div className="p-6 max-w-2xl mx-auto">
        {/* Word input */}
        <div className="flex gap-3 mb-4">
          <Input
            id="word-input"
            placeholder="Nhập từ tiếng Anh..."
            value={word}
            onChange={(e) => setWord(e.target.value)}
            onKeyDown={handleKeyDown}
            error={wordError}
            className="flex-1"
          />
          <Button onClick={handleLookup} disabled={isLooking || !isOnline}>
            {isLooking ? <LoadingSpinner size="sm" /> : "Lookup"}
          </Button>
        </div>

        {/* Duplicate warning */}
        <DuplicateWarning count={duplicateCount} />

        {/* Offline notice */}
        {!isOnline && (
          <div className="mt-4 p-4 bg-amber-50 border border-amber-200 rounded-card text-body-sm text-amber-800">
            📡 Bạn đang offline. Bạn có thể tự điền tay tất cả các field.
          </div>
        )}

        {/* Loading */}
        {isLooking && (
          <div className="flex items-center justify-center py-12">
            <LoadingSpinner size="lg" />
          </div>
        )}

        {/* Results */}
        {lookupResult && !isLooking && (
          <div className="mt-6 flex flex-col gap-6">
            <LookupResult result={lookupResult} onPlayAudio={handlePlayAudio} />

            {/* Editable fields */}
            <div className="grid grid-cols-3 gap-4">
              <Input
                id="phonetic"
                label="Phiên âm (IPA)"
                value={editFields.phonetic}
                onChange={(e) =>
                  setEditFields({ ...editFields, phonetic: e.target.value })
                }
              />
              <div className="flex flex-col gap-1.5">
                <label className="text-body-sm text-graphite font-medium">
                  CEFR Level
                </label>
                <select
                  value={editFields.cefr_level}
                  onChange={(e) =>
                    setEditFields({ ...editFields, cefr_level: e.target.value })
                  }
                  className="w-full px-3 py-2 rounded border border-stone bg-eggshell text-body"
                >
                  <option value="">—</option>
                  {["A1", "A2", "B1", "B2", "C1", "C2"].map((l) => (
                    <option key={l} value={l}>
                      {l}
                    </option>
                  ))}
                </select>
              </div>
              <div className="flex flex-col gap-1.5">
                <label className="text-body-sm text-graphite font-medium">
                  Usage
                </label>
                <select
                  value={editFields.usage_register}
                  onChange={(e) =>
                    setEditFields({
                      ...editFields,
                      usage_register: e.target.value,
                    })
                  }
                  className="w-full px-3 py-2 rounded border border-stone bg-eggshell text-body"
                >
                  <option value="">—</option>
                  {[
                    "formal",
                    "informal",
                    "slang",
                    "neutral",
                    "vulgar",
                    "technical",
                  ].map((u) => (
                    <option key={u} value={u}>
                      {u}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            {/* Meaning selection */}
            <div>
              <h3 className="text-subheading font-display font-light mb-3">
                Chọn nghĩa muốn lưu
              </h3>
              <MeaningSelector
                meanings={lookupResult.meanings}
                selectedMeanings={selectedMeanings}
                onSelectionChange={setSelectedMeanings}
              />
            </div>

            {/* Save */}
            <div className="flex justify-end gap-3 pt-4 border-t border-stone">
              <Button
                variant="secondary"
                onClick={() => navigate("/vocabulary")}
              >
                Hủy
              </Button>
              <Button
                onClick={handleSave}
                disabled={
                  isSaving || Object.keys(selectedMeanings).length === 0
                }
              >
                {isSaving
                  ? "Đang lưu..."
                  : `Lưu (${Object.keys(selectedMeanings).length} nghĩa)`}
              </Button>
            </div>
          </div>
        )}
      </div>
    </>
  );
}
```

- [ ] **Step 7: Update App.jsx — replace AddWordPage placeholder**

In `App.jsx`, import and use the real `AddWordPage`:

```jsx
import AddWordPage from "./pages/AddWordPage";
// Replace: <Route path="/vocabulary/add" element={<PlaceholderPage title="Add Word" />} />
// With:    <Route path="/vocabulary/add" element={<AddWordPage />} />
```

- [ ] **Step 8: Verify — run dev server and test the lookup flow**

```bash
cd web
npm run dev
```

Test: Navigate to `/vocabulary/add`, enter "resilient", click Lookup, verify results appear.

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "feat: add smart vocabulary input page with dictionary + AI lookup, meaning selection, and duplicate detection"
```

---

### Task 8: Collection Management

**Files:**

- Create: `web/src/services/collection.service.js`
- Create: `web/src/stores/collection.store.js`
- Create: `web/src/pages/CollectionsPage.jsx`
- Create: `web/src/pages/CollectionDetailPage.jsx`
- Create: `web/src/components/collection/CollectionCard.jsx`
- Create: `web/src/components/collection/CollectionForm.jsx`
- Modify: `web/src/App.jsx` — replace collection page placeholders
- Test: `web/src/services/__tests__/collection.service.test.js`

**Interfaces:**

- Consumes: `db` (Dexie), `vocabularyService`, `useAuthStore`, `useUIStore`, `<Button />`, `<Input />`, `<Modal />`, `<ConfirmDialog />`
- Produces:
  - `collectionService.create(data): Promise<collection>`
  - `collectionService.getAll(userId): Promise<{ items: collection[] }>`
  - `collectionService.getById(id): Promise<{ collection, vocabularies }>`
  - `collectionService.update(id, updates): Promise<collection>`
  - `collectionService.delete(id): Promise<void>`
  - `collectionService.assignWord(vocabularyId, collectionId): Promise<void>`
  - `collectionService.removeWord(vocabularyId, collectionId): Promise<void>`
  - `useCollectionStore` — Zustand store: `{ items, isLoading, fetchCollections, addCollection, updateCollection, deleteCollection }`
  - `<CollectionsPage />`, `<CollectionDetailPage />`, `<CollectionCard />`, `<CollectionForm />`

- [ ] **Step 1: Create collection service**

Create `web/src/services/collection.service.js`:

```javascript
import db from "../db/database";

export const collectionService = {
  async create(data) {
    const id = crypto.randomUUID();
    const now = new Date().toISOString();

    const collection = {
      id,
      user_id: data.user_id,
      name: data.name.trim(),
      description: data.description?.trim() || null,
      is_default: data.is_default || false,
      is_ai_generated: data.is_ai_generated || false,
      created_at: now,
      updated_at: now,
      is_deleted: false,
    };

    await db.transaction("rw", [db.collections, db.sync_queue], async () => {
      await db.collections.put(collection);
      await db.sync_queue.add({
        table_name: "collections",
        record_id: id,
        operation: "CREATE",
        payload: collection,
        created_at: now,
        synced: false,
      });
    });

    return collection;
  },

  async getAll(userId) {
    const collections = await db.collections
      .where("user_id")
      .equals(userId)
      .and((c) => !c.is_deleted)
      .toArray();

    // Attach word count
    for (const col of collections) {
      const links = await db.vocabulary_collections
        .where("collection_id")
        .equals(col.id)
        .and((vc) => !vc.is_deleted)
        .toArray();
      col.word_count = links.length;
    }

    // Sort: default first, then alphabetically
    collections.sort((a, b) => {
      if (a.is_default && !b.is_default) return -1;
      if (!a.is_default && b.is_default) return 1;
      return a.name.localeCompare(b.name);
    });

    return { items: collections };
  },

  async getById(id) {
    const collection = await db.collections.get(id);
    if (!collection || collection.is_deleted) return null;

    const vcLinks = await db.vocabulary_collections
      .where("collection_id")
      .equals(id)
      .and((vc) => !vc.is_deleted)
      .toArray();
    const vocabIds = vcLinks.map((vc) => vc.vocabulary_id);

    let vocabularies = [];
    if (vocabIds.length > 0) {
      vocabularies = await db.vocabularies
        .where("id")
        .anyOf(vocabIds)
        .and((v) => !v.is_deleted)
        .toArray();

      for (const vocab of vocabularies) {
        vocab.definitions = await db.definitions
          .where("vocabulary_id")
          .equals(vocab.id)
          .and((d) => !d.is_deleted)
          .sortBy("sort_order");
      }
    }

    return { collection, vocabularies };
  },

  async update(id, updates) {
    const now = new Date().toISOString();
    const updated = { ...updates, updated_at: now };
    delete updated.id;

    await db.transaction("rw", [db.collections, db.sync_queue], async () => {
      await db.collections.update(id, updated);
      await db.sync_queue.add({
        table_name: "collections",
        record_id: id,
        operation: "UPDATE",
        payload: updated,
        created_at: now,
        synced: false,
      });
    });

    return db.collections.get(id);
  },

  async delete(id) {
    const now = new Date().toISOString();

    await db.transaction(
      "rw",
      [db.collections, db.vocabulary_collections, db.sync_queue],
      async () => {
        await db.collections.update(id, { is_deleted: true, updated_at: now });

        const vcLinks = await db.vocabulary_collections
          .where("collection_id")
          .equals(id)
          .toArray();
        for (const vc of vcLinks) {
          await db.vocabulary_collections.update(vc.id, {
            is_deleted: true,
            updated_at: now,
          });
        }

        await db.sync_queue.add({
          table_name: "collections",
          record_id: id,
          operation: "DELETE",
          payload: { is_deleted: true },
          created_at: now,
          synced: false,
        });
      },
    );
  },

  async assignWord(vocabularyId, collectionId) {
    const id = crypto.randomUUID();
    const now = new Date().toISOString();

    const link = {
      id,
      vocabulary_id: vocabularyId,
      collection_id: collectionId,
      created_at: now,
      updated_at: now,
      is_deleted: false,
    };

    await db.transaction(
      "rw",
      [db.vocabulary_collections, db.sync_queue],
      async () => {
        await db.vocabulary_collections.put(link);
        await db.sync_queue.add({
          table_name: "vocabulary_collections",
          record_id: id,
          operation: "CREATE",
          payload: link,
          created_at: now,
          synced: false,
        });
      },
    );
  },

  async removeWord(vocabularyId, collectionId) {
    const now = new Date().toISOString();

    const link = await db.vocabulary_collections
      .where("vocabulary_id")
      .equals(vocabularyId)
      .and((vc) => vc.collection_id === collectionId && !vc.is_deleted)
      .first();

    if (!link) return;

    await db.transaction(
      "rw",
      [db.vocabulary_collections, db.sync_queue],
      async () => {
        await db.vocabulary_collections.update(link.id, {
          is_deleted: true,
          updated_at: now,
        });
        await db.sync_queue.add({
          table_name: "vocabulary_collections",
          record_id: link.id,
          operation: "DELETE",
          payload: { is_deleted: true },
          created_at: now,
          synced: false,
        });
      },
    );
  },
};
```

- [ ] **Step 2: Create collection store, pages, and components**

Follow the same pattern as vocabulary — create `collection.store.js`, `CollectionsPage.jsx`, `CollectionDetailPage.jsx`, `CollectionCard.jsx`, `CollectionForm.jsx`. Each component follows the design system from DESIGN.md (warm taupe cards, pill buttons, hairline dividers).

- [ ] **Step 3: Write collection service tests**

Similar structure to vocabulary service tests using `fake-indexeddb`.

- [ ] **Step 4: Update App.jsx routes**

Replace collection placeholder routes with real pages.

- [ ] **Step 5: Run tests and verify visually**

```bash
cd web
npx vitest run
npm run dev
```

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: add collection management — CRUD, word assignment, and collection pages"
```

---

### Task 9: Vocabulary List Page + Search & Filter

**Files:**

- Create: `web/src/pages/VocabularyPage.jsx`
- Create: `web/src/components/vocabulary/WordCard.jsx`
- Create: `web/src/components/vocabulary/FilterBar.jsx`
- Modify: `web/src/App.jsx` — replace vocabulary page placeholder

**Interfaces:**

- Consumes: `useVocabularyStore`, `useAuthStore`, `<Button />`, `<Input />`, constants, `useDebouncedSearch`
- Produces:
  - `<VocabularyPage />` — full vocabulary list with search, filters, sort, pagination, and "+ Thêm từ mới" button
  - `<WordCard />` — single vocabulary card showing word, part_of_speech, cefr_level, truncated definitions
  - `<FilterBar />` — filter UI for CEFR level, part of speech, usage, collection

- [ ] **Step 1: Create WordCard component**

Create `web/src/components/vocabulary/WordCard.jsx`:

```jsx
import { Link } from "react-router-dom";
import { CEFR_COLORS } from "../../utils/constants";
import { truncateText } from "../../utils/formatters";

export default function WordCard({ vocabulary }) {
  const cefrStyle = CEFR_COLORS[vocabulary.cefr_level] || {};

  return (
    <Link
      to={`/vocabulary/${vocabulary.id}`}
      className="block p-4 bg-warm-taupe rounded-card hover:shadow-subtle transition-all duration-200"
    >
      <div className="flex items-start justify-between mb-2">
        <h3 className="text-subheading font-display font-light">
          {vocabulary.word}
        </h3>
        <div className="flex gap-1.5">
          {vocabulary.part_of_speech && (
            <span className="px-2 py-0.5 bg-eggshell border border-stone rounded-pill text-caption text-smoke">
              {vocabulary.part_of_speech}
            </span>
          )}
          {vocabulary.cefr_level && (
            <span
              className={`px-2 py-0.5 rounded-pill text-caption ${cefrStyle.bg} ${cefrStyle.text}`}
            >
              {vocabulary.cefr_level}
            </span>
          )}
        </div>
      </div>

      {vocabulary.phonetic && (
        <p className="text-body-sm text-smoke font-mono mb-2">
          {vocabulary.phonetic}
        </p>
      )}

      {vocabulary.definitions && vocabulary.definitions.length > 0 && (
        <p className="text-body-sm text-smoke">
          {truncateText(
            vocabulary.definitions[0].definition_vi ||
              vocabulary.definitions[0].definition_en,
            80,
          )}
        </p>
      )}
    </Link>
  );
}
```

- [ ] **Step 2: Create FilterBar component**

Create `web/src/components/vocabulary/FilterBar.jsx`:

```jsx
import {
  CEFR_LEVELS,
  PARTS_OF_SPEECH,
  USAGE_REGISTERS,
} from "../../utils/constants";

export default function FilterBar({ filters, onFilterChange }) {
  const handleChange = (key, value) => {
    onFilterChange({
      ...filters,
      [key]: value || undefined,
    });
  };

  return (
    <div className="flex flex-wrap gap-3 p-4 bg-warm-taupe rounded-card">
      <select
        value={filters.cefr_level || ""}
        onChange={(e) => handleChange("cefr_level", e.target.value)}
        className="px-3 py-1.5 rounded-pill border border-stone bg-eggshell text-body-sm"
      >
        <option value="">Tất cả Level</option>
        {CEFR_LEVELS.map((l) => (
          <option key={l} value={l}>
            {l}
          </option>
        ))}
      </select>

      <select
        value={filters.part_of_speech || ""}
        onChange={(e) => handleChange("part_of_speech", e.target.value)}
        className="px-3 py-1.5 rounded-pill border border-stone bg-eggshell text-body-sm"
      >
        <option value="">Tất cả loại từ</option>
        {PARTS_OF_SPEECH.map((p) => (
          <option key={p} value={p}>
            {p}
          </option>
        ))}
      </select>

      <select
        value={filters.usage_register || ""}
        onChange={(e) => handleChange("usage_register", e.target.value)}
        className="px-3 py-1.5 rounded-pill border border-stone bg-eggshell text-body-sm"
      >
        <option value="">Tất cả usage</option>
        {USAGE_REGISTERS.map((u) => (
          <option key={u} value={u}>
            {u}
          </option>
        ))}
      </select>
    </div>
  );
}
```

- [ ] **Step 3: Create VocabularyPage**

Create `web/src/pages/VocabularyPage.jsx` with search bar, FilterBar, vocabulary list (WordCard grid), sort dropdown, pagination, and "+Thêm từ mới" button linking to `/vocabulary/add`.

- [ ] **Step 4: Update App.jsx route**

Replace vocabulary placeholder with real `VocabularyPage`.

- [ ] **Step 5: Verify**

```bash
cd web
npm run dev
```

Test: Search, filter by level/POS, sort by date/alphabet, click word to navigate to detail.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: add vocabulary list page with search, filter, sort, and pagination"
```

---

### Task 10: Word Detail Page (View/Edit)

**Files:**

- Create: `web/src/pages/WordDetailPage.jsx`
- Create: `web/src/components/vocabulary/WordForm.jsx`
- Modify: `web/src/App.jsx` — replace word detail placeholder

**Interfaces:**

- Consumes: `vocabularyService.getById()`, `vocabularyService.update()`, `vocabularyService.delete()`, `collectionService`, `useAuthStore`, `useUIStore`, `<Button />`, `<Input />`, `<ConfirmDialog />`
- Produces:
  - `<WordDetailPage />` — full word detail with all fields, definitions, collections, edit mode, delete
  - `<WordForm />` — editable form for all vocabulary fields

- [ ] **Step 1: Create WordForm component**

Editable form with: word, phonetic (with play button), part_of_speech select, cefr_level select, usage_register select, definitions list (each with definition_en, definition_vi, example), collection tags.

- [ ] **Step 2: Create WordDetailPage**

View/edit toggle pattern. Displays all word data. Edit button switches to form. Delete with confirm dialog. "Back to list" navigation. Collection assignment/removal.

- [ ] **Step 3: Update App.jsx route**

- [ ] **Step 4: Verify**

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: add word detail page with view/edit mode and delete"
```

---

### Task 11: Sync Engine

**Files:**

- Create: `web/src/db/sync.js`
- Create: `web/src/hooks/useSync.js`
- Modify: `web/src/App.jsx` — integrate sync hook
- Test: `web/src/db/__tests__/sync.test.js`

**Interfaces:**

- Consumes: `db` (Dexie), `supabase` client, `useOnlineStatus`, `useAuthStore`
- Produces:
  - `syncEngine.pushChanges(): Promise<{ pushed: number, errors: string[] }>`
  - `syncEngine.pullChanges(lastSyncTimestamp): Promise<{ pulled: number }>`
  - `syncEngine.fullSync(): Promise<{ pushed, pulled }>`
  - `useSync()` — hook that auto-triggers sync when online, returns `{ syncStatus, lastSyncAt, triggerSync }`

- [ ] **Step 1: Create sync engine**

Create `web/src/db/sync.js` implementing the push/pull strategy from [API_Specification.md](file:///f:/Side%20Projects/mewmory/docs/API_Specification.md) Section 4. Push processes `sync_queue` entries sequentially via Supabase client. Pull fetches records with `updated_at > lastSyncTimestamp` and bulk-puts into IndexedDB. Last-write-wins conflict resolution.

- [ ] **Step 2: Create useSync hook**

Create `web/src/hooks/useSync.js` that watches `isOnline` and triggers `fullSync()` when transitioning from offline to online. Also runs on initial login.

- [ ] **Step 3: Integrate in App.jsx**

Call `useSync()` inside the App or MainLayout component.

- [ ] **Step 4: Write sync tests**

Test push creates Supabase records (mock), pull updates IndexedDB, conflict resolution picks latest `updated_at`.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: add sync engine with push/pull queue processing and auto-sync on reconnect"
```

---

### Task 12: Dashboard + Statistics

**Files:**

- Create: `web/src/services/statistics.service.js`
- Create: `web/src/pages/DashboardPage.jsx`
- Create: `web/src/components/dashboard/DailyReviewWidget.jsx`
- Create: `web/src/components/dashboard/StatsOverview.jsx`
- Create: `web/src/components/dashboard/StreakChart.jsx`
- Create: `web/src/components/dashboard/LevelDistribution.jsx`
- Create: `web/src/components/dashboard/CollectionDistribution.jsx`
- Modify: `web/src/App.jsx` — replace dashboard placeholder

**Interfaces:**

- Consumes: `db` (Dexie), `vocabularyService`, `collectionService`, `useAuthStore`, `<Button />`, Recharts
- Produces:
  - `statisticsService.getTotalCount(userId): Promise<number>`
  - `statisticsService.getLevelDistribution(userId): Promise<{ level, count }[]>`
  - `statisticsService.getCollectionDistribution(userId): Promise<{ name, count }[]>`
  - `statisticsService.getDailyWordCount(userId, days): Promise<{ date, count }[]>`
  - `statisticsService.getRandomWord(userId, collectionIds?): Promise<vocabulary>`
  - `<DashboardPage />` — Daily Review Widget + Statistics charts
  - `<DailyReviewWidget />` — random word flashcard with gentle/quiz modes
  - `<StatsOverview />` — total word count
  - `<StreakChart />` — Recharts BarChart of daily additions (30 days)
  - `<LevelDistribution />` — Recharts PieChart of CEFR levels
  - `<CollectionDistribution />` — Recharts BarChart of collection sizes

- [ ] **Step 1: Create statistics service**

Compute all stats from IndexedDB (offline-first). Count vocabularies, group by cefr_level, count per collection, group by created_at date, pick random word.

- [ ] **Step 2: Create DailyReviewWidget**

Two modes: "gentle" (shows word + phonetic + definition) and "quiz" (shows word, click to reveal). "Next word" button picks another random word.

- [ ] **Step 3: Create chart components**

Use Recharts with the design system colors (smoke, ink, warm-taupe, stone).

- [ ] **Step 4: Create DashboardPage**

Assembles DailyReviewWidget at top + StatsOverview + StreakChart + LevelDistribution + CollectionDistribution below. Clickable stats navigate to filtered vocabulary lists.

- [ ] **Step 5: Update App.jsx route**

- [ ] **Step 6: Verify visually**

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat: add dashboard with daily review widget, streak chart, and statistics visualizations"
```

---

### Task 13: Settings Page

**Files:**

- Create: `web/src/services/settings.service.js`
- Create: `web/src/stores/settings.store.js`
- Create: `web/src/pages/SettingsPage.jsx`
- Modify: `web/src/App.jsx` — replace settings placeholder

**Interfaces:**

- Consumes: `db` (Dexie), `useAuthStore`, `useUIStore`, `<Button />`, `<Input />`
- Produces:
  - `settingsService.get(userId): Promise<settings>`
  - `settingsService.update(userId, updates): Promise<settings>`
  - `useSettingsStore` — Zustand store: `{ settings, isLoading, fetchSettings, updateSettings }`
  - `<SettingsPage />` — AI provider/model selection, notification toggle/mode/time, account info, sign out

- [ ] **Step 1: Create settings service**

CRUD for `user_settings` in IndexedDB + sync queue.

- [ ] **Step 2: Create settings store**

- [ ] **Step 3: Create SettingsPage**

Three sections: AI Settings (provider select, model input), Notification Settings (toggle, mode radio, time picker, collection source multi-select), Account (email, display name, sign out button).

- [ ] **Step 4: Update App.jsx route**

- [ ] **Step 5: Verify**

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: add settings page with AI provider, notification, and account management"
```

---

### Task 14: Polish & Testing

**Files:**

- Modify: `web/src/index.css` — add animations (fade-in, slide-in)
- Modify: Various components — review for consistency, fix edge cases
- Create: `web/src/components/common/EmptyState.jsx` — placeholder for empty lists

**Interfaces:**

- Consumes: All prior tasks
- Produces: Polished, tested, production-ready web app

- [ ] **Step 1: Add CSS animations**

Add to `index.css`:

```css
@keyframes fade-in {
  from {
    opacity: 0;
    transform: translateY(8px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes slide-in {
  from {
    opacity: 0;
    transform: translateX(16px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.animate-fade-in {
  animation: fade-in 0.2s ease-out;
}
.animate-slide-in {
  animation: slide-in 0.3s ease-out;
}
```

- [ ] **Step 2: Add empty states for all list pages**

- [ ] **Step 3: Review and fix all edge cases**

- Offline → online transition: verify sync runs
- Empty database state: all pages render gracefully
- API errors: toast messages are user-friendly (Vietnamese)
- Large lists: pagination works correctly
- Long text: truncation and overflow handling

- [ ] **Step 4: Run full test suite**

```bash
cd web
npx vitest run --coverage
```

Expected: All tests pass, reasonable coverage on services and utilities.

- [ ] **Step 5: Build production bundle**

```bash
cd web
npm run build
npm run preview
```

Expected: Build succeeds, preview works at http://localhost:4173.

- [ ] **Step 6: Final commit**

```bash
git add -A
git commit -m "feat: polish UI with animations, empty states, and edge case handling"
```

---

## Verification Plan

### Automated Tests

```bash
cd web
npx vitest run                # All unit + integration tests
npx vitest run --coverage     # Coverage report
npm run build                 # Production build succeeds
```

### Manual Verification

1. **Auth flow**: Sign up → auto-create profile/collection/settings → login → logout → login again
2. **Smart input**: Lookup "resilient" → verify all fields populated → select meanings → save → verify in vocabulary list
3. **Offline mode**: Disconnect network → add word manually → reconnect → verify sync pushes data
4. **Collections**: Create collection → assign words → view collection detail → delete collection (words remain)
5. **Search & Filter**: Search by English/Vietnamese → filter by CEFR level → sort by date → verify results
6. **Dashboard**: Verify daily review widget → check statistics charts match actual data
7. **Settings**: Change AI provider → verify lookup uses new provider
8. **Duplicate detection**: Add "hello" twice → verify warning badge appears on second attempt
