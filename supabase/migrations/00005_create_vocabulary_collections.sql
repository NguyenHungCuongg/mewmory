CREATE TABLE vocabulary_collections (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vocabulary_id   UUID NOT NULL REFERENCES vocabularies(id) ON DELETE CASCADE,
    collection_id   UUID NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_deleted      BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT unique_vocab_collection UNIQUE (vocabulary_id, collection_id)
);

-- Indexes
CREATE INDEX idx_vocab_collections_vocabulary ON vocabulary_collections(vocabulary_id);
CREATE INDEX idx_vocab_collections_collection ON vocabulary_collections(collection_id);
CREATE INDEX idx_vocab_collections_updated ON vocabulary_collections(updated_at);

CREATE TRIGGER vocab_collections_updated_at
    BEFORE UPDATE ON vocabulary_collections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- RLS (through vocabulary and collection ownership)
ALTER TABLE vocabulary_collections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD own vocab_collections"
    ON vocabulary_collections FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM vocabularies
            WHERE vocabularies.id = vocabulary_collections.vocabulary_id
            AND vocabularies.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM vocabularies
            WHERE vocabularies.id = vocabulary_collections.vocabulary_id
            AND vocabularies.user_id = auth.uid()
        )
    );
