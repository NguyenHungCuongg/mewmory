-- Useful for search and display
CREATE OR REPLACE VIEW vocabulary_full AS
SELECT
    v.id,
    v.user_id,
    v.word,
    v.phonetic,
    v.audio_url,
    v.part_of_speech,
    v.cefr_level,
    v.usage_register,
    v.created_at,
    v.updated_at,
    COALESCE(
        json_agg(
            json_build_object(
                'id', d.id,
                'definition_en', d.definition_en,
                'definition_vi', d.definition_vi,
                'example', d.example,
                'sort_order', d.sort_order
            ) ORDER BY d.sort_order
        ) FILTER (WHERE d.id IS NOT NULL AND d.is_deleted = FALSE),
        '[]'
    ) AS definitions,
    COALESCE(
        json_agg(DISTINCT c.name) FILTER (WHERE c.id IS NOT NULL AND c.is_deleted = FALSE),
        '[]'
    ) AS collection_names
FROM vocabularies v
LEFT JOIN definitions d ON d.vocabulary_id = v.id
LEFT JOIN vocabulary_collections vc ON vc.vocabulary_id = v.id AND vc.is_deleted = FALSE
LEFT JOIN collections c ON c.id = vc.collection_id AND c.is_deleted = FALSE
WHERE v.is_deleted = FALSE
GROUP BY v.id;
