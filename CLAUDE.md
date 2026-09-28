# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

`AGENTS.md` holds the full product context (features, gaps, conventions, design quick reference) — read it too. Note it is partly stale: `mobile/` and `admin/` both contain real code now.

## Repo layout

Three independent apps sharing one Supabase backend. No root package.json / workspace — run commands inside each app dir.

- `web/` — main user app (React 19 + Vite, JS/JSX, Zustand, Dexie, Tailwind v4, i18next). Only app with JS tests.
- `admin/` — separate Vite app for moderation (users, ban/unban/unflag, usage stats). No tests.
- `mobile/` — Flutter app (Riverpod, Drift, GoRouter), Android.
- `supabase/` — SQL migrations + Deno Edge Functions.

## Commands

```bash
# web
cd web && npm run dev
cd web && npm run build
cd web && npm test                                        # vitest run (jsdom, fake-indexeddb)
cd web && npx vitest run src/services/__tests__/vocabulary.service.test.js   # single file
cd web && npx vitest run -t "test name"                   # single test by name

# admin
cd admin && npm run dev

# mobile
cd mobile && flutter pub get
cd mobile && dart run build_runner build --delete-conflicting-outputs   # regenerate Drift *.g.dart
cd mobile && flutter gen-l10n                                            # l10n from lib/l10n/app_vi.arb (template)
cd mobile && flutter analyze && flutter test
cd mobile && flutter test test/services/some_test.dart                   # single file

# supabase
supabase start
supabase functions serve
```

CI (`.github/workflows/ci.yml`, Node 22) runs `web` tests and `mobile` analyze + test on push/PR to `main`/`dev`. Admin is not in CI.

Env: `web/` and `admin/` need `VITE_SUPABASE_URL` / `VITE_SUPABASE_ANON_KEY` in `.env.local`; mobile reads `SUPABASE_URL` / `SUPABASE_ANON_KEY` via flutter_dotenv. AI provider keys are Edge Function secrets only.

## Architecture

### Web offline-first data flow
- Dexie schema in `web/src/db/database.js`; every table mirrors a Supabase table plus a local `sync_queue`.
- Services (`web/src/services/*.service.js`) write to Dexie **and** append a `sync_queue` entry (`table_name`, `record_id`, `operation` CREATE/UPDATE/DELETE, full `payload`). Any new write path must do both, or it will never reach the server.
- Deletes are soft (`is_deleted: true`); reads must filter them out.
- `web/src/db/sync.js` `syncEngine`: push drains the queue in order (CREATE→upsert, UPDATE→update, DELETE→soft-delete); pull fetches rows with `updated_at > last_sync_<userId>` (localStorage) and applies last-write-wins on `updated_at`. `user_settings` payloads are remapped before push (`notification_collection_ids` → `notification_collections`).
- `web/src/hooks/useSync.js` triggers `fullSync` on login and on reconnect.
- Stores (`web/src/stores/`) hold UI/auth state; business logic stays in services.

### Lookup / AI pipeline
`lookup.service.js` calls Edge Functions via `supabase.functions.invoke`: `lookup-word` (Free Dictionary + AI classify, `provider` = `gemini` | `openrouter`), `translate-definition`, `ai-classify`. Edge Functions use `_shared/admin-utils.ts` to log to `api_usage_logs`, update last-active, and auto-flag spam.

### Admin
`admin-api` Edge Function checks the caller's `profiles.is_admin` and then uses a service-role client (bypasses RLS). Admin/moderation columns (`is_admin`, `is_banned`, `is_flagged`, ...) come from migration `00010`.

### Mobile
Mirrors the web service layer in Dart (`lib/services/*_service.dart`, incl. `sync_service.dart`) over a Drift DB (`lib/db/`, generated `database.g.dart`; `build.yaml` stores DateTimes as text).

## Rules
- Don't modify migrations, schema, or RLS unless explicitly asked. New schema changes = new numbered migration file.
- UI follows `DESIGN.md` (pill buttons, 20px card radius). Colors: `web/src/index.css` is the source of truth; keep `DESIGN.md` and `mobile/lib/config/theme.dart` in sync with it. Use tokens, never hardcoded hex, so dark mode works.
- Web tests live in `__tests__/` next to the code under test.
- Docs under `docs/` (esp. `SAD.md`) are partly outdated — trust the code.
