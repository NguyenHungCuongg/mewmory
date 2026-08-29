import { describe, it, expect, beforeEach } from "vitest";
import "fake-indexeddb/auto";
import db from "../../db/database";
import { vocabularyService } from "../vocabulary.service";

const TEST_USER_ID = "test-user-123";

beforeEach(async () => {
  await db.vocabularies.clear();
  await db.definitions.clear();
  await db.vocabulary_collections.clear();
  await db.sync_queue.clear();
});

describe("vocabularyService", () => {
  it("creates a vocabulary with definitions", async () => {
    const result = await vocabularyService.create(
      {
        user_id: TEST_USER_ID,
        word: "resilient",
        cefr_level: "C1",
        part_of_speech: "adjective",
      },
      [
        {
          definition_en: "able to recover",
          definition_vi: "kiên cường",
          example: "She is resilient.",
        },
      ],
    );

    expect(result.vocabulary.word).toBe("resilient");
    expect(result.definitions).toHaveLength(1);
    expect(result.definitions[0].definition_vi).toBe("kiên cường");

    // Check sync queue
    const queue = await db.sync_queue.toArray();
    expect(queue.length).toBeGreaterThanOrEqual(2); // vocab + definition
  });

  it("getAll returns vocabularies for user", async () => {
    await vocabularyService.create({ user_id: TEST_USER_ID, word: "hello" }, [
      { definition_vi: "xin chào" },
    ]);
    await vocabularyService.create({ user_id: TEST_USER_ID, word: "world" }, [
      { definition_vi: "thế giới" },
    ]);

    const result = await vocabularyService.getAll(TEST_USER_ID);
    expect(result.items).toHaveLength(2);
    expect(result.total).toBe(2);
  });

  it("getAll with search filters by word", async () => {
    await vocabularyService.create(
      { user_id: TEST_USER_ID, word: "apple" },
      [],
    );
    await vocabularyService.create(
      { user_id: TEST_USER_ID, word: "banana" },
      [],
    );

    const result = await vocabularyService.getAll(TEST_USER_ID, {
      search: "apple",
    });
    expect(result.items).toHaveLength(1);
    expect(result.items[0].word).toBe("apple");
  });

  it("getById returns vocabulary with definitions and collections", async () => {
    const { vocabulary } = await vocabularyService.create(
      { user_id: TEST_USER_ID, word: "test" },
      [{ definition_vi: "kiểm tra" }],
    );

    const result = await vocabularyService.getById(vocabulary.id);
    expect(result.vocabulary.word).toBe("test");
    expect(result.definitions).toHaveLength(1);
  });

  it("delete soft-deletes vocabulary", async () => {
    const { vocabulary } = await vocabularyService.create(
      { user_id: TEST_USER_ID, word: "delete-me" },
      [],
    );

    await vocabularyService.delete(vocabulary.id);

    const result = await vocabularyService.getById(vocabulary.id);
    expect(result).toBeNull();
  });

  it("checkDuplicate finds existing word", async () => {
    await vocabularyService.create(
      { user_id: TEST_USER_ID, word: "duplicate" },
      [],
    );

    const result = await vocabularyService.checkDuplicate(
      TEST_USER_ID,
      "Duplicate",
    );
    expect(result.count).toBe(1);
  });
});
