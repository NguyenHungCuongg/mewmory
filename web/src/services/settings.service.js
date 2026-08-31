import db from "../db/database";

export const DEFAULT_SETTINGS = {
  ai_provider: "gemini",
  ai_model: "gemini-3.6-flash",
  notification_enabled: false,
  notification_mode: "gentle",
  notification_time: "09:00:00",
  notification_collection_ids: [],
};

export const settingsService = {
  async get(userId) {
    if (!userId) return null;

    let settings = await db.user_settings
      .where("user_id")
      .equals(userId)
      .first();

    if (!settings) {
      const now = new Date().toISOString();
      const id = crypto.randomUUID();
      settings = {
        id,
        user_id: userId,
        ...DEFAULT_SETTINGS,
        created_at: now,
        updated_at: now,
        is_deleted: false,
      };

      await db.transaction("rw", [db.user_settings, db.sync_queue], async () => {
        await db.user_settings.put(settings);
        await db.sync_queue.add({
          table_name: "user_settings",
          record_id: id,
          operation: "CREATE",
          payload: settings,
          created_at: now,
          synced: false,
        });
      });
    }

    return settings;
  },

  async update(userId, updates) {
    if (!userId) return null;

    let existing = await this.get(userId);
    const now = new Date().toISOString();
    const updated = {
      ...existing,
      ...updates,
      updated_at: now,
    };

    await db.transaction("rw", [db.user_settings, db.sync_queue], async () => {
      await db.user_settings.put(updated);
      await db.sync_queue.add({
        table_name: "user_settings",
        record_id: updated.id,
        operation: "UPDATE",
        payload: updated,
        created_at: now,
        synced: false,
      });
    });

    return updated;
  },
};
