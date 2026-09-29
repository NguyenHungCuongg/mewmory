-- Extend profiles table with admin and moderation fields
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS is_admin       BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS is_banned      BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS is_flagged     BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS banned_at      TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS ban_reason     TEXT,
  ADD COLUMN IF NOT EXISTS last_active_at TIMESTAMPTZ;

-- Partial indexes for efficient admin queries
CREATE INDEX IF NOT EXISTS idx_profiles_is_flagged ON profiles(is_flagged) WHERE is_flagged = TRUE;
CREATE INDEX IF NOT EXISTS idx_profiles_is_banned  ON profiles(is_banned)  WHERE is_banned  = TRUE;
CREATE INDEX IF NOT EXISTS idx_profiles_last_active ON profiles(last_active_at DESC NULLS LAST);
