import { describe, it, expect, beforeEach, vi } from "vitest";
import "fake-indexeddb/auto";
import db from "../database";
import { syncEngine } from "../sync";
import { supabase } from "../../config/supabase";

vi.mock("../../config/supabase", () => ({
  supabase: {
    from: vi.fn(),
  },
}));

const TEST_USER_ID = "sync-user-123";

beforeEach(async () => {
  await db.vocabularies.clear();
  await db.definitions.clear();
  await db.collections.clear();
  await db.vocabulary_collections.clear();
  await db.sync_queue.clear();
  localStorage.clear();
  vi.clearAllMocks();
});

describe("syncEngine", () => {
  it("pushChanges processes CREATE operations in sync_queue", async () => {
    const upsertMock = vi.fn().mockResolvedValue({ data: null, error: null });
    supabase.from.mockReturnValue({
      upsert: upsertMock,
    });

    await db.sync_queue.add({
      table_name: "vocabularies",
      record_id: "vocab-1",
      operation: "CREATE",
      payload: { id: "vocab-1", word: "resilient", user_id: TEST_USER_ID },
      created_at: new Date().toISOString(),
      synced: false,
    });

    const result = await syncEngine.pushChanges();
    expect(result.pushed).toBe(1);
    expect(result.errors).toHaveLength(0);

    expect(supabase.from).toHaveBeenCalledWith("vocabularies");
    expect(upsertMock).toHaveBeenCalled();

    const queueItems = await db.sync_queue.toArray();
    expect(queueItems[0].synced).toBe(true);
  });

  it("pushChanges processes UPDATE operations in sync_queue", async () => {
    const updateMock = vi.fn().mockReturnValue({
      eq: vi.fn().mockResolvedValue({ data: null, error: null }),
    });
    supabase.from.mockReturnValue({
      update: updateMock,
    });

    await db.sync_queue.add({
      table_name: "vocabularies",
      record_id: "vocab-2",
      operation: "UPDATE",
      payload: { word: "resilient updated" },
      created_at: new Date().toISOString(),
      synced: false,
    });

    const result = await syncEngine.pushChanges();
    expect(result.pushed).toBe(1);
    expect(supabase.from).toHaveBeenCalledWith("vocabularies");
    expect(updateMock).toHaveBeenCalled();
  });

  it("pullChanges puts new remote records into local IndexedDB", async () => {
    const mockVocabularies = [
      {
        id: "remote-vocab-1",
        user_id: TEST_USER_ID,
        word: "serendipity",
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        is_deleted: false,
      },
    ];

    supabase.from.mockImplementation((tableName) => {
      if (tableName === "vocabularies") {
        return {
          select: vi.fn().mockReturnValue({
            eq: vi.fn().mockResolvedValue({
              data: mockVocabularies,
              error: null,
            }),
          }),
        };
      }
      return {
        select: vi.fn().mockReturnValue({
          eq: vi.fn().mockResolvedValue({ data: [], error: null }),
        }),
      };
    });

    const result = await syncEngine.pullChanges(TEST_USER_ID);
    expect(result.pulled).toBeGreaterThanOrEqual(1);

    const localVocab = await db.vocabularies.get("remote-vocab-1");
    expect(localVocab).toBeDefined();
    expect(localVocab.word).toBe("serendipity");
  });

  it("pullChanges applies last-write-wins conflict resolution", async () => {
    const olderTime = "2026-01-01T00:00:00.000Z";
    const newerTime = "2026-01-02T00:00:00.000Z";

    // Local record is older
    await db.vocabularies.put({
      id: "conflict-vocab",
      user_id: TEST_USER_ID,
      word: "local-older",
      updated_at: olderTime,
      is_deleted: false,
    });

    const remoteRecords = [
      {
        id: "conflict-vocab",
        user_id: TEST_USER_ID,
        word: "remote-newer",
        updated_at: newerTime,
        is_deleted: false,
      },
    ];

    supabase.from.mockImplementation((tableName) => {
      if (tableName === "vocabularies") {
        return {
          select: vi.fn().mockReturnValue({
            eq: vi.fn().mockResolvedValue({
              data: remoteRecords,
              error: null,
            }),
          }),
        };
      }
      return {
        select: vi.fn().mockReturnValue({
          eq: vi.fn().mockResolvedValue({ data: [], error: null }),
        }),
      };
    });

    await syncEngine.pullChanges(TEST_USER_ID);

    const resolved = await db.vocabularies.get("conflict-vocab");
    expect(resolved.word).toBe("remote-newer");
  });

  const queueEntry = (overrides) => ({
    table_name: "vocabularies",
    record_id: "r-1",
    operation: "CREATE",
    payload: { id: "r-1" },
    created_at: new Date().toISOString(),
    synced: false,
    ...overrides,
  });

  it("pushChanges upserts user_settings on user_id without the local id", async () => {
    const upsertMock = vi.fn().mockResolvedValue({ error: null });
    supabase.from.mockReturnValue({ upsert: upsertMock });

    await db.sync_queue.add(
      queueEntry({
        table_name: "user_settings",
        record_id: "local-settings-id",
        operation: "UPDATE",
        payload: {
          id: "local-settings-id",
          user_id: TEST_USER_ID,
          ai_provider: "openrouter",
        },
      }),
    );

    await syncEngine.pushChanges();

    expect(upsertMock).toHaveBeenCalledWith(
      { user_id: TEST_USER_ID, ai_provider: "openrouter" },
      { onConflict: "user_id" },
    );
  });

  it("pushChanges drops legacy user_settings CREATE entries instead of sending defaults", async () => {
    const upsertMock = vi.fn().mockResolvedValue({ error: null });
    supabase.from.mockReturnValue({ upsert: upsertMock });

    const legacyId = await db.sync_queue.add(
      queueEntry({
        table_name: "user_settings",
        payload: { id: "local", user_id: TEST_USER_ID, ai_provider: "gemini" },
      }),
    );

    await syncEngine.pushChanges();

    expect(upsertMock).not.toHaveBeenCalled();
    expect((await db.sync_queue.get(legacyId)).synced).toBe(true);
  });

  it("pushChanges upserts vocabulary_collections on the (vocabulary, collection) pair", async () => {
    const upsertMock = vi.fn().mockResolvedValue({ error: null });
    supabase.from.mockReturnValue({ upsert: upsertMock });

    const payload = { id: "l-1", vocabulary_id: "v-1", collection_id: "c-1" };
    await db.sync_queue.add(
      queueEntry({ table_name: "vocabulary_collections", payload }),
    );

    await syncEngine.pushChanges();

    expect(upsertMock).toHaveBeenCalledWith(payload, {
      onConflict: "vocabulary_id,collection_id",
    });
  });

  it("pushChanges counts server rejections, keeps going, and skips entries after 5", async () => {
    const upsertMock = vi
      .fn()
      .mockResolvedValueOnce({ error: { code: "23505", message: "duplicate" } })
      .mockResolvedValue({ error: null });
    supabase.from.mockReturnValue({ upsert: upsertMock });

    const badId = await db.sync_queue.add(queueEntry({ record_id: "bad" }));
    await db.sync_queue.add(queueEntry({ record_id: "good" }));
    const deadId = await db.sync_queue.add(
      queueEntry({ record_id: "dead", attempts: 5 }),
    );

    const result = await syncEngine.pushChanges();

    expect(result.pushed).toBe(1);
    expect(upsertMock).toHaveBeenCalledTimes(2); // "dead" is never sent
    const bad = await db.sync_queue.get(badId);
    expect(bad.synced).toBe(false);
    expect(bad.attempts).toBe(1);
    expect(bad.last_error).toBe("duplicate");
    expect((await db.sync_queue.get(deadId)).attempts).toBe(5);
    expect(await syncEngine.pendingCount()).toBe(1); // only "bad" is retryable
    expect(await syncEngine.unsyncedCount()).toBe(2); // "bad" + "dead"
  });

  it("pushChanges stops on a network error without counting an attempt", async () => {
    const upsertMock = vi.fn().mockResolvedValue({
      error: { code: "", message: "TypeError: Failed to fetch" },
    });
    supabase.from.mockReturnValue({ upsert: upsertMock });

    await db.sync_queue.add(queueEntry({ record_id: "a" }));
    await db.sync_queue.add(queueEntry({ record_id: "b" }));

    await syncEngine.pushChanges();

    expect(upsertMock).toHaveBeenCalledTimes(1);
    const entries = await db.sync_queue.toArray();
    expect(entries.every((e) => !e.synced && !e.attempts)).toBe(true);
  });

  it("pullChanges replaces other local user_settings rows of the same user", async () => {
    await db.user_settings.clear();
    await db.user_settings.put({ id: "local-default", user_id: TEST_USER_ID });
    const remote = {
      id: "server-id",
      user_id: TEST_USER_ID,
      ai_provider: "openrouter",
      updated_at: new Date().toISOString(),
    };

    supabase.from.mockImplementation((tableName) => ({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockResolvedValue({
          data: tableName === "user_settings" ? [remote] : [],
          error: null,
        }),
      }),
    }));

    await syncEngine.pullChanges(TEST_USER_ID);

    const rows = await db.user_settings.toArray();
    expect(rows.map((r) => r.id)).toEqual(["server-id"]);
  });
});
