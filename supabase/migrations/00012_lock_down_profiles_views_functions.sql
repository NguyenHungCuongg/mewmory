-- Security fixes from dev-docs/BUG_AUDIT_2026-09-28.md (S1–S3).

-- S1: "Users can update own profile" allowed every column, including
-- is_admin / is_banned / is_flagged (00010). Restrict clients to the columns
-- web and mobile actually edit. Edge Functions use the service role and are unaffected.
REVOKE UPDATE ON public.profiles FROM anon, authenticated;
GRANT UPDATE (display_name, avatar_url, updated_at) ON public.profiles TO authenticated;

-- S2: views run with the owner's rights and bypass RLS, so this exposed every
-- user's vocabulary. No client uses it.
DROP VIEW IF EXISTS public.vocabulary_full;

-- S3: SECURITY DEFINER functions take any p_user_id and bypass RLS.
-- No client calls them; keep them for server-side use only.
REVOKE EXECUTE ON FUNCTION public.get_vocab_count(UUID) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.get_level_distribution(UUID) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.get_collection_distribution(UUID) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.get_daily_word_count(UUID, INTEGER) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.check_duplicate_word(UUID, TEXT, TEXT[]) FROM PUBLIC, anon, authenticated;
