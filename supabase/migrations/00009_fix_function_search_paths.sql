-- Fix search_path and schema qualification for SECURITY DEFINER functions
-- Prevents "relation does not exist" errors when called from auth triggers (where search_path = 'auth')
-- and resolves Supabase database security advisor warnings (lint 0011_function_search_path_mutable).

-- 1. Auto-create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
    INSERT INTO public.profiles (id, email, display_name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
    );
    RETURN NEW;
END;
$$;

-- 2. Auto-create default collection on profile created
CREATE OR REPLACE FUNCTION public.create_default_collection()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
    INSERT INTO public.collections (user_id, name, description, is_default)
    VALUES (NEW.id, 'Uncategorized', 'Default collection for uncategorized words', TRUE);
    RETURN NEW;
END;
$$;

-- 3. Auto-create default settings on profile created
CREATE OR REPLACE FUNCTION public.create_default_settings()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
    INSERT INTO public.user_settings (user_id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$;

-- 4. Total vocabulary count per user
CREATE OR REPLACE FUNCTION public.get_vocab_count(p_user_id UUID)
RETURNS INTEGER
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT COUNT(*)::INTEGER
    FROM public.vocabularies
    WHERE user_id = p_user_id AND is_deleted = FALSE;
$$;

-- 5. Vocabulary count by CEFR level
CREATE OR REPLACE FUNCTION public.get_level_distribution(p_user_id UUID)
RETURNS TABLE(level TEXT, count INTEGER)
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT cefr_level, COUNT(*)::INTEGER
    FROM public.vocabularies
    WHERE user_id = p_user_id AND is_deleted = FALSE AND cefr_level IS NOT NULL
    GROUP BY cefr_level
    ORDER BY
        CASE cefr_level
            WHEN 'A1' THEN 1 WHEN 'A2' THEN 2
            WHEN 'B1' THEN 3 WHEN 'B2' THEN 4
            WHEN 'C1' THEN 5 WHEN 'C2' THEN 6
        END;
$$;

-- 6. Vocabulary count by collection
CREATE OR REPLACE FUNCTION public.get_collection_distribution(p_user_id UUID)
RETURNS TABLE(collection_name TEXT, count INTEGER)
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT c.name, COUNT(vc.vocabulary_id)::INTEGER
    FROM public.collections c
    LEFT JOIN public.vocabulary_collections vc ON vc.collection_id = c.id AND vc.is_deleted = FALSE
    LEFT JOIN public.vocabularies v ON v.id = vc.vocabulary_id AND v.is_deleted = FALSE
    WHERE c.user_id = p_user_id AND c.is_deleted = FALSE
    GROUP BY c.id, c.name
    ORDER BY COUNT(vc.vocabulary_id) DESC;
$$;

-- 7. Daily word count
CREATE OR REPLACE FUNCTION public.get_daily_word_count(p_user_id UUID, p_days INTEGER DEFAULT 30)
RETURNS TABLE(date DATE, count INTEGER)
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT
        DATE(created_at) as date,
        COUNT(*)::INTEGER as count
    FROM public.vocabularies
    WHERE user_id = p_user_id
        AND is_deleted = FALSE
        AND created_at >= NOW() - (p_days || ' days')::INTERVAL
    GROUP BY DATE(created_at)
    ORDER BY date;
$$;

-- 8. Check duplicate word
CREATE OR REPLACE FUNCTION public.check_duplicate_word(
    p_user_id UUID,
    p_word TEXT,
    p_definitions_vi TEXT[]
)
RETURNS TABLE(
    vocabulary_id UUID,
    existing_word TEXT,
    matching_definitions TEXT[]
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT
        v.id,
        v.word,
        ARRAY_AGG(d.definition_vi) FILTER (WHERE d.definition_vi = ANY(p_definitions_vi))
    FROM public.vocabularies v
    JOIN public.definitions d ON d.vocabulary_id = v.id AND d.is_deleted = FALSE
    WHERE v.user_id = p_user_id
        AND LOWER(v.word) = LOWER(p_word)
        AND v.is_deleted = FALSE
        AND d.definition_vi = ANY(p_definitions_vi)
    GROUP BY v.id, v.word
    HAVING COUNT(*) > 0;
$$;
