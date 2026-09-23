# Mewmory Admin Panel

Internal admin dashboard for monitoring users and API usage.

## Setup

1. Copy env template:
   ```bash
   cp .env.example .env.local
   ```
   Fill in `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` (same values as `web/.env.local`).

2. Bootstrap admin account (run once in Supabase Dashboard SQL Editor):
   ```sql
   UPDATE profiles SET is_admin = TRUE WHERE email = 'your-email@example.com';
   ```

3. Install and run:
   ```bash
   npm install
   npm run dev
   ```

## Deploy

Deploy to Vercel or Netlify as a separate project pointing to the `admin/` directory.
Set environment variables `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` in the platform's UI.

## Security

- Only accounts with `profiles.is_admin = TRUE` can access the panel.
- All sensitive queries go through the `admin-api` Edge Function (service role stays server-side).
- To revoke admin access: `UPDATE profiles SET is_admin = FALSE WHERE email = '...';`
