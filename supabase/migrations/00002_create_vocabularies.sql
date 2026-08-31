CREATE TABLE vocabularies (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    word            TEXT NOT NULL,
    phonetic        TEXT,                -- IPA phonetic transcription
    audio_url       TEXT,                -- Audio pronunciation URL (.mp3)
    part_of_speech  TEXT,                -- noun, verb, adjective, adverb, etc.
    cefr_level      TEXT,                -- A1, A2, B1, B2, C1, C2
    usage_register  TEXT,                -- formal, informal, slang, neutral, vulgar, technical
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_deleted      BOOLEAN NOT NULL DEFAULT FALSE,   -- Soft delete for sync

    CONSTRAINT valid_cefr_level CHECK (
        cefr_level IS NULL OR cefr_level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')
    )
);

-- Indexes
CREATE INDEX idx_vocabularies_user_id ON vocabularies(user_id);
CREATE INDEX idx_vocabularies_word ON vocabularies(user_id, word);
CREATE INDEX idx_vocabularies_cefr_level ON vocabularies(user_id, cefr_level);
CREATE INDEX idx_vocabularies_part_of_speech ON vocabularies(user_id, part_of_speech);
CREATE INDEX idx_vocabularies_usage_register ON vocabularies(user_id, usage_register);
CREATE INDEX idx_vocabularies_created_at ON vocabularies(user_id, created_at DESC);
CREATE INDEX idx_vocabularies_updated_at ON vocabularies(updated_at);

-- Full-text search index
CREATE INDEX idx_vocabularies_word_search ON vocabularies
    USING GIN (to_tsvector('english', word));

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER vocabularies_updated_at
    BEFORE UPDATE ON vocabularies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- RLS
ALTER TABLE vocabularies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD own vocabularies"
    ON vocabularies FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);
