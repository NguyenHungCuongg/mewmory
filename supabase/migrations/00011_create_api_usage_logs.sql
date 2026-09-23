-- Usage log table — written by Edge Functions only (service role)
CREATE TABLE IF NOT EXISTS api_usage_logs (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  action     TEXT        NOT NULL,
  word       TEXT,
  status     TEXT        NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT valid_action CHECK (action IN ('lookup_word', 'ai_classify', 'translate_definition')),
  CONSTRAINT valid_status CHECK (status IN ('success', 'error', 'rate_limited', 'banned'))
);

CREATE INDEX IF NOT EXISTS idx_api_usage_logs_user_id    ON api_usage_logs(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_api_usage_logs_created_at ON api_usage_logs(created_at DESC);

-- Enable RLS — no SELECT policy for regular users; service role bypasses RLS
ALTER TABLE api_usage_logs ENABLE ROW LEVEL SECURITY;
