-- Total vocabulary count per user
CREATE OR REPLACE FUNCTION get_vocab_count(p_user_id UUID)
RETURNS INTEGER AS $$
    SELECT COUNT(*)::INTEGER
    FROM vocabularies
    WHERE user_id = p_user_id AND is_deleted = FALSE;
$$ LANGUAGE sql SECURITY DEFINER;

-- Vocabulary count by CEFR level
CREATE OR REPLACE FUNCTION get_level_distribution(p_user_id UUID)
RETURNS TABLE(level TEXT, count INTEGER) AS $$
    SELECT cefr_level, COUNT(*)::INTEGER
    FROM vocabularies
    WHERE user_id = p_user_id AND is_deleted = FALSE AND cefr_level IS NOT NULL
    GROUP BY cefr_level
    ORDER BY
        CASE cefr_level
            WHEN 'A1' THEN 1 WHEN 'A2' THEN 2
            WHEN 'B1' THEN 3 WHEN 'B2' THEN 4
            WHEN 'C1' THEN 5 WHEN 'C2' THEN 6
        END;
$$ LANGUAGE sql SECURITY DEFINER;

-- Vocabulary count by collection
CREATE OR REPLACE FUNCTION get_collection_distribution(p_user_id UUID)
RETURNS TABLE(collection_name TEXT, count INTEGER) AS $$
    SELECT c.name, COUNT(vc.vocabulary_id)::INTEGER
    FROM collections c
    LEFT JOIN vocabulary_collections vc ON vc.collection_id = c.id AND vc.is_deleted = FALSE
    LEFT JOIN vocabularies v ON v.id = vc.vocabulary_id AND v.is_deleted = FALSE
    WHERE c.user_id = p_user_id AND c.is_deleted = FALSE
    GROUP BY c.id, c.name
    ORDER BY COUNT(vc.vocabulary_id) DESC;
$$ LANGUAGE sql SECURITY DEFINER;

-- Daily word count (for streak chart)
CREATE OR REPLACE FUNCTION get_daily_word_count(p_user_id UUID, p_days INTEGER DEFAULT 30)
RETURNS TABLE(date DATE, count INTEGER) AS $$
    SELECT
        DATE(created_at) as date,
        COUNT(*)::INTEGER as count
    FROM vocabularies
    WHERE user_id = p_user_id
        AND is_deleted = FALSE
        AND created_at >= NOW() - (p_days || ' days')::INTERVAL
    GROUP BY DATE(created_at)
    ORDER BY date;
$$ LANGUAGE sql SECURITY DEFINER;

-- Check if word + meaning combination already exists
CREATE OR REPLACE FUNCTION check_duplicate_word(
    p_user_id UUID,
    p_word TEXT,
    p_definitions_vi TEXT[]
)
RETURNS TABLE(
    vocabulary_id UUID,
    existing_word TEXT,
    matching_definitions TEXT[]
) AS $$
    SELECT
        v.id,
        v.word,
        ARRAY_AGG(d.definition_vi) FILTER (WHERE d.definition_vi = ANY(p_definitions_vi))
    FROM vocabularies v
    JOIN definitions d ON d.vocabulary_id = v.id AND d.is_deleted = FALSE
    WHERE v.user_id = p_user_id
        AND LOWER(v.word) = LOWER(p_word)
        AND v.is_deleted = FALSE
        AND d.definition_vi = ANY(p_definitions_vi)
    GROUP BY v.id, v.word
    HAVING COUNT(*) > 0;
$$ LANGUAGE sql SECURITY DEFINER;
