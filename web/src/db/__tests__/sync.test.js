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
});
