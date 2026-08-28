# Mewmory — Project Setup & Development Guide

> **Version:** 1.0
> **Last Updated:** 2026-08-25
> **Related:** [SAD.md](file:///f:/Side%20Projects/mewmory/docs/SAD.md)
> **Status:** Draft — Pending Review

---

## 1. Prerequisites

| Tool             | Version | Purpose                             |
| ---------------- | ------- | ----------------------------------- |
| **Node.js**      | ≥ 18.x  | Runtime                             |
| **npm**          | ≥ 9.x   | Package manager                     |
| **Git**          | ≥ 2.x   | Version control                     |
| **Supabase CLI** | latest  | Database migrations, Edge Functions |

---

## 2. Tech Stack Summary

### Web App (Phase 1)

| Layer          | Technology            | Version |
| -------------- | --------------------- | ------- |
| Build Tool     | Vite                  | ^5.x    |
| UI Framework   | React                 | ^18.x   |
| Styling        | TailwindCSS           | ^3.x    |
| Routing        | React Router          | ^6.x    |
| State          | Zustand               | ^4.x    |
| Local DB       | Dexie.js              | ^4.x    |
| Backend Client | @supabase/supabase-js | ^2.x    |
| Charts         | Recharts              | ^2.x    |

### Backend

| Service    | Technology                     |
| ---------- | ------------------------------ |
| Auth       | Supabase Auth                  |
| Database   | Supabase PostgreSQL            |
| Serverless | Supabase Edge Functions (Deno) |
| Hosting    | Vercel                         |

---

## 3. Project Structure

```
mewmory/
├── README.md
├── RAW_IDEA.md
├── docs/                          # Documentation
│   ├── PRD.md
│   ├── SAD.md
│   ├── Database_Schema.md
│   ├── API_Specification.md
│   ├── User_Flows.md
│   └── Project_Setup.md
│
├── web/                           # Web App (Vite + React)
│   ├── package.json
│   ├── vite.config.js
│   ├── tailwind.config.js
│   ├── postcss.config.js
│   ├── index.html
│   ├── .env.local                 # Supabase URL + anon key
│   ├── .env.example
│   ├── public/
│   └── src/
│       ├── main.jsx
│       ├── App.jsx
│       ├── index.css              # TailwindCSS imports
│       ├── config/
│       ├── db/
│       ├── services/
│       ├── stores/
│       ├── hooks/
│       ├── pages/
│       ├── components/
│       └── utils/
│
├── supabase/                      # Supabase configuration
│   ├── config.toml                # Supabase project config
│   ├── migrations/                # Database migrations (SQL)
│   │   ├── 00001_create_profiles.sql
│   │   ├── 00002_create_vocabularies.sql
│   │   ├── 00003_create_definitions.sql
│   │   ├── 00004_create_collections.sql
│   │   ├── 00005_create_vocabulary_collections.sql
│   │   ├── 00006_create_user_settings.sql
│   │   ├── 00007_create_views.sql
│   │   └── 00008_create_functions.sql
│   ├── functions/                 # Edge Functions
│   │   ├── lookup-word/
│   │   │   └── index.ts
│   │   └── ai-classify/
│   │       └── index.ts
│   └── seed.sql                   # Seed data (optional)
│
├── .gitignore
└── .github/
    └── workflows/                 # CI/CD (optional)
```

---

## 4. Environment Variables

### Web App (`.env.local`)

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIs...
```

### Supabase Edge Functions (Supabase Dashboard → Settings → Secrets)

```env
GEMINI_API_KEY=AIzaSy...
OPENROUTER_API_KEY=sk-or-...
```

### `.env.example`

```env
# Supabase
VITE_SUPABASE_URL=
VITE_SUPABASE_ANON_KEY=

# (Edge Function secrets are configured via Supabase Dashboard)
```

---

## 5. Getting Started

### 5.1 Clone & Install

```bash
git clone <repository-url>
cd mewmory

# Install web app dependencies
cd web
npm install
```

### 5.2 Supabase Setup

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref <your-project-ref>

# Run migrations
supabase db push

# Deploy Edge Functions
supabase functions deploy lookup-word
supabase functions deploy ai-classify

# Set secrets (API keys)
supabase secrets set GEMINI_API_KEY=AIzaSy...
supabase secrets set OPENROUTER_API_KEY=sk-or-...
```

### 5.3 Local Development

```bash
# Start web app dev server
cd web
npm run dev
# → http://localhost:5173

# (Optional) Start Supabase locally
supabase start
# → Local Supabase at http://localhost:54321
```

---

## 6. Deployment

### 6.1 Web App → Vercel

1. Push code to GitHub.
2. Connect repo to Vercel.
3. Set build settings:
   - **Framework:** Vite
   - **Root Directory:** `web`
   - **Build Command:** `npm run build`
   - **Output Directory:** `dist`
4. Set environment variables in Vercel Dashboard:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
5. Deploy (auto on push to `main`).

### 6.2 Supabase

- Database migrations: `supabase db push`
- Edge Functions: `supabase functions deploy <function-name>`
- Secrets: `supabase secrets set KEY=VALUE`

---

## 7. Development Workflow

### Git Branching

```
main          ← production (auto-deploy to Vercel)
└── develop   ← development integration
    ├── feature/smart-input
    ├── feature/collections
    ├── feature/search-filter
    └── feature/statistics
```

### Recommended Development Order

| Order | Feature                           | Dependencies            | Estimated Effort |
| ----- | --------------------------------- | ----------------------- | ---------------- |
| 1     | **Project Setup**                 | None                    | 1 day            |
| 2     | **Auth (Login/Register)**         | Supabase Auth           | 1 day            |
| 3     | **Database Schema + Migrations**  | Supabase                | 1 day            |
| 4     | **Vocabulary CRUD (basic)**       | Auth, DB                | 2 days           |
| 5     | **Local DB (Dexie.js) + Offline** | Vocabulary CRUD         | 2 days           |
| 6     | **Edge Functions (lookup-word)**  | Supabase                | 2 days           |
| 7     | **Smart Input (AI + Dictionary)** | Edge Functions          | 2 days           |
| 8     | **Collections**                   | Vocabulary              | 2 days           |
| 9     | **Search & Filter**               | Vocabulary, Collections | 1 day            |
| 10    | **Sync Engine**                   | Local DB, Supabase      | 2 days           |
| 11    | **Statistics Dashboard**          | Vocabulary data         | 1 day            |
| 12    | **Settings**                      | Auth                    | 1 day            |
| 13    | **Notifications (Web Push)**      | Settings                | 1 day            |
| 14    | **Polish & Testing**              | All                     | 2 days           |
|       | **Total Estimated**               |                         | **~21 days**     |

---

## 8. Key npm Scripts

```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "lint": "eslint src/"
  }
}
```

---

## 9. Coding Conventions

| Area                 | Convention                                                          |
| -------------------- | ------------------------------------------------------------------- |
| **File naming**      | `camelCase.jsx` for components, `kebab-case.js` for utilities       |
| **Component naming** | PascalCase (e.g., `WordCard.jsx`)                                   |
| **State management** | Zustand stores in `stores/` directory                               |
| **Services**         | Business logic in `services/` — components don't call APIs directly |
| **CSS**              | TailwindCSS utility classes, no inline styles                       |
| **Constants**        | All constants in `utils/constants.js`                               |
