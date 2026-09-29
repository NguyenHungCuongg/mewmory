import db from "./database";
import { supabase } from "../config/supabase";

// Entries the server rejected this many times stop being retried.
export const MAX_PUSH_ATTEMPTS = 5;

const isRetryable = (item) =>
  !item.synced && (item.attempts ?? 0) < MAX_PUSH_ATTEMPTS;

// Re-read this much before the cursor: a row stamped just before the newest one
// we saw may commit after we read. Re-pulling a row is harmless (last-write-wins).
export const SYNC_CURSOR_OVERLAP_MS = 60_000;

// PostgREST errors carry a code ("23505", "PGRST116", ...); a failed fetch has none.
const isNetworkError = (err) => !err?.code;

export const syncEngine = {
  async pushChanges() {
    const queue = await db.sync_queue.filter(isRetryable).sortBy("id");

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

        if (table_name === "user_settings" && operation === "CREATE") {
          // Queued by older builds with default values; pushing them now would
          // overwrite the user's real settings. Only UPDATEs carry user changes.
          await db.sync_queue.update(id, { synced: true });
          continue;
        } else if (table_name === "user_settings") {
          // One row per user already exists server-side; the local id may differ.
          const { id: _localId, ...row } = pushPayload;
          const { error } = await supabase
            .from(table_name)
            .upsert(row, { onConflict: "user_id" });
          if (error) throw error;
        } else if (operation === "CREATE" && table_name === "vocabulary_collections") {
          // Server has UNIQUE (vocabulary_id, collection_id), including soft-deleted rows.
          const { error } = await supabase
            .from(table_name)
            .upsert(pushPayload, { onConflict: "vocabulary_id,collection_id" });
          if (error) throw error;
        } else if (operation === "CREATE") {
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
        // Network down: stop and keep order for the next sync.
        if (isNetworkError(err)) break;
        await db.sync_queue.update(id, {
          attempts: (entry.attempts ?? 0) + 1,
          last_error: err.message,
        });
      }
    }

    return { pushed, errors };
  },

  /** Entries that the next push will try to send. */
  pendingCount() {
    return db.sync_queue.filter(isRetryable).count();
  },

  /** Every local change not on the server yet, including ones that gave up. */
  unsyncedCount() {
    return db.sync_queue.filter((item) => !item.synced).count();
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
    // Cursor = newest server updated_at seen; the device clock may be skewed.
    let cursorMs = lastSyncTimestamp ? Date.parse(lastSyncTimestamp) : null;
    let failed = false;

    for (const tableName of tables) {
      try {
        let query = supabase.from(tableName).select("*");

        // RLS will ensure user only gets their own data, but we can explicitly filter if user_id column exists
        if (tableName !== "definitions" && tableName !== "vocabulary_collections") {
          query = query.eq("user_id", userId);
        }

        if (lastSyncTimestamp) {
          const since = Date.parse(lastSyncTimestamp) - SYNC_CURSOR_OVERLAP_MS;
          query = query.gt("updated_at", new Date(since).toISOString());
        }

        const { data, error } = await query;
        if (error) throw error;

        for (const row of data ?? []) {
          const rowMs = Date.parse(row.updated_at);
          if (!Number.isNaN(rowMs) && (cursorMs === null || rowMs > cursorMs)) {
            cursorMs = rowMs;
          }
        }

        if (data && data.length > 0) {
          // Last-write-wins conflict resolution
          for (const remoteRecord of data) {
            if (tableName === "user_settings") {
              // Drop any locally created default row: the server row is the real one.
              await db.user_settings
                .where("user_id")
                .equals(remoteRecord.user_id)
                .and((s) => s.id !== remoteRecord.id)
                .delete();
            }

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
        failed = true;
      }
    }

    // A failed table must be re-read next time, so only advance when all succeeded.
    if (!failed && cursorMs !== null) {
      localStorage.setItem(
        `last_sync_${userId}`,
        new Date(cursorMs).toISOString(),
      );
    }
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
