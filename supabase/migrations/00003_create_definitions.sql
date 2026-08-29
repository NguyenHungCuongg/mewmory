CREATE TABLE definitions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vocabulary_id   UUID NOT NULL REFERENCES vocabularies(id) ON DELETE CASCADE,
    definition_en   TEXT,                -- English definition
    definition_vi   TEXT,                -- Vietnamese translation
    example         TEXT,                -- Example sentence
    sort_order      INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_deleted      BOOLEAN NOT NULL DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_definitions_vocabulary_id ON definitions(vocabulary_id);
CREATE INDEX idx_definitions_updated_at ON definitions(updated_at);

-- Full-text search on Vietnamese definitions
CREATE INDEX idx_definitions_vi_search ON definitions
    USING GIN (to_tsvector('simple', COALESCE(definition_vi, '')));

CREATE TRIGGER definitions_updated_at
    BEFORE UPDATE ON definitions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- RLS (through vocabulary ownership)
ALTER TABLE definitions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD own definitions"
    ON definitions FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM vocabularies
            WHERE vocabularies.id = definitions.vocabulary_id
            AND vocabularies.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM vocabularies
            WHERE vocabularies.id = definitions.vocabulary_id
            AND vocabularies.user_id = auth.uid()
        )
    );
