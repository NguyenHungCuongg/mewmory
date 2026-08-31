CREATE TABLE user_settings (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,

    -- AI Settings
    ai_provider             TEXT NOT NULL DEFAULT 'gemini',
    ai_model                TEXT,

    -- Notification Settings
    notification_enabled    BOOLEAN NOT NULL DEFAULT TRUE,
    notification_mode       TEXT NOT NULL DEFAULT 'gentle',    -- 'gentle' | 'quiz'
    notification_time       TIME NOT NULL DEFAULT '09:00',     -- Daily notification time
    notification_collections UUID[] DEFAULT '{}',              -- Empty = all collections

    -- Sync
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT valid_ai_provider CHECK (ai_provider IN ('gemini', 'openrouter')),
    CONSTRAINT valid_notification_mode CHECK (notification_mode IN ('gentle', 'quiz'))
);

CREATE TRIGGER user_settings_updated_at
    BEFORE UPDATE ON user_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE INDEX idx_user_settings_updated_at ON user_settings(updated_at);

-- RLS
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD own settings"
    ON user_settings FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Auto-create settings for new users
CREATE OR REPLACE FUNCTION create_default_settings()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_settings (user_id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_profile_created_settings
    AFTER INSERT ON profiles
    FOR EACH ROW EXECUTE FUNCTION create_default_settings();
