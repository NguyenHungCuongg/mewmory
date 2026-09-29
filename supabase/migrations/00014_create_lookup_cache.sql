-- Shared cache of merged lookup-word results (dictionary + AI), one row per word.
-- Written and read by the lookup-word Edge Function via the service role only.
CREATE TABLE IF NOT EXISTS lookup_cache (
  word       TEXT        PRIMARY KEY,   -- normalized: trimmed, lowercased, single spaces
  result     JSONB       NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS on with no policies: anon/authenticated get nothing; service role bypasses RLS.
ALTER TABLE lookup_cache ENABLE ROW LEVEL SECURITY;
