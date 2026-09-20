import db from "../db/database";

export const DEFAULT_SETTINGS = {
  ai_provider: "gemini",
  ai_model: "gemini-3.6-flash",
  notification_enabled: false,
  notification_mode: "gentle",
  notification_time: "09:00:00",
  notification_collections: [],
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
        updated_at: now,
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

    return {
      ...settings,
      notification_collection_ids:
        settings.notification_collection_ids ||
        settings.notification_collections ||
        [],
    };
  },

  async update(userId, updates) {
    if (!userId) return null;

    let existing = await this.get(userId);
    const now = new Date().toISOString();

    const normalizedUpdates = { ...updates };
    if (normalizedUpdates.notification_collection_ids !== undefined) {
      normalizedUpdates.notification_collections =
        normalizedUpdates.notification_collection_ids;
    }

    const updated = {
      ...existing,
      ...normalizedUpdates,
      updated_at: now,
    };
    delete updated.is_deleted;
    delete updated.created_at;

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
