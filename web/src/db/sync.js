import db from "./database";
import { supabase } from "../config/supabase";

export const syncEngine = {
  async pushChanges() {
    const queue = await db.sync_queue
      .filter((item) => !item.synced)
      .sortBy("id");

    let pushed = 0;
    const errors = [];

    for (const entry of queue) {
      const { id, table_name, record_id, operation, payload } = entry;

      try {
        let pushPayload = payload;
        if (table_name === "user_settings" && payload) {
          const { is_deleted, created_at, notification_collection_ids, ...rest } = payload;
          pushPayload = {
            ...rest,
            ...(notification_collection_ids !== undefined && rest.notification_collections === undefined
              ? { notification_collections: notification_collection_ids }
              : {}),
          };
        }

        if (operation === "CREATE") {
          const { error } = await supabase.from(table_name).upsert(pushPayload);
          if (error) throw error;
        } else if (operation === "UPDATE") {
          const { error } = await supabase
            .from(table_name)
            .update(pushPayload)
            .eq("id", record_id);
          if (error) throw error;
        } else if (operation === "DELETE") {
          const { error } = await supabase
            .from(table_name)
            .update({ is_deleted: true, updated_at: new Date().toISOString() })
            .eq("id", record_id);
          if (error) throw error;
        }

        // Mark as synced locally
        await db.sync_queue.update(id, { synced: true });
        pushed++;
      } catch (err) {
        console.error(`Sync push error for ${table_name} (${record_id}):`, err);
        errors.push(`${table_name}:${record_id} - ${err.message}`);
      }
    }

    return { pushed, errors };
  },

  async pullChanges(userId, lastSyncTimestamp = null) {
    if (!userId) return { pulled: 0 };

    const tables = [
      "vocabularies",
      "definitions",
      "collections",
      "vocabulary_collections",
      "user_settings",
    ];

    let totalPulled = 0;
    const now = new Date().toISOString();

    for (const tableName of tables) {
      try {
        let query = supabase.from(tableName).select("*");

        // RLS will ensure user only gets their own data, but we can explicitly filter if user_id column exists
        if (tableName !== "definitions" && tableName !== "vocabulary_collections") {
          query = query.eq("user_id", userId);
        }

        if (lastSyncTimestamp) {
          query = query.gt("updated_at", lastSyncTimestamp);
        }

        const { data, error } = await query;
        if (error) throw error;

        if (data && data.length > 0) {
          // Last-write-wins conflict resolution
          for (const remoteRecord of data) {
            const localRecord = await db[tableName].get(remoteRecord.id);

            if (!localRecord) {
              await db[tableName].put(remoteRecord);
              totalPulled++;
            } else {
              const localTime = new Date(localRecord.updated_at || 0).getTime();
              const remoteTime = new Date(remoteRecord.updated_at || 0).getTime();

              // Only overwrite if remote is newer or equal
              if (remoteTime >= localTime) {
                await db[tableName].put(remoteRecord);
                totalPulled++;
              }
            }
          }
        }
      } catch (err) {
        console.error(`Sync pull error for table ${tableName}:`, err);
      }
    }

    localStorage.setItem(`last_sync_${userId}`, now);
    return { pulled: totalPulled };
  },

  async fullSync(userId) {
    if (!userId) return { pushed: 0, pulled: 0, errors: [] };

    const lastSync = localStorage.getItem(`last_sync_${userId}`);
    const pushResult = await this.pushChanges();
    const pullResult = await this.pullChanges(userId, lastSync);

    return {
      pushed: pushResult.pushed,
      pulled: pullResult.pulled,
      errors: pushResult.errors,
    };
  },
};
