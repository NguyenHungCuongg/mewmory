import { describe, it, expect, beforeEach } from "vitest";
import "fake-indexeddb/auto";
import db from "../../db/database";
import { statisticsService } from "../statistics.service";
import { vocabularyService } from "../vocabulary.service";
import { collectionService } from "../collection.service";

const TEST_USER_ID = "stats-user-123";

beforeEach(async () => {
  await db.vocabularies.clear();
  await db.definitions.clear();
  await db.collections.clear();
  await db.vocabulary_collections.clear();
  await db.sync_queue.clear();
});

describe("statisticsService", () => {
  it("getTotalCount returns total non-deleted vocabulary count", async () => {
    await vocabularyService.create({ user_id: TEST_USER_ID, word: "word1" }, []);
    await vocabularyService.create({ user_id: TEST_USER_ID, word: "word2" }, []);

    const count = await statisticsService.getTotalCount(TEST_USER_ID);
    expect(count).toBe(2);
  });

  it("getLevelDistribution groups count by CEFR level", async () => {
    await vocabularyService.create(
      { user_id: TEST_USER_ID, word: "w1", cefr_level: "A1" },
      [],
    );
    await vocabularyService.create(
      { user_id: TEST_USER_ID, word: "w2", cefr_level: "A1" },
      [],
    );
    await vocabularyService.create(
      { user_id: TEST_USER_ID, word: "w3", cefr_level: "C1" },
      [],
    );

    const dist = await statisticsService.getLevelDistribution(TEST_USER_ID);
    expect(dist.find((d) => d.level === "A1")?.count).toBe(2);
    expect(dist.find((d) => d.level === "C1")?.count).toBe(1);
  });

  it("getCollectionDistribution returns collection sizes", async () => {
    const col = await collectionService.create({
      user_id: TEST_USER_ID,
      name: "Travel",
    });

    const { vocabulary } = await vocabularyService.create(
      { user_id: TEST_USER_ID, word: "airport" },
      [],
    );

    await collectionService.assignWord(vocabulary.id, col.id);

    const dist = await statisticsService.getCollectionDistribution(TEST_USER_ID);
    expect(dist.find((d) => d.name === "Travel")?.count).toBe(1);
  });

  it("getDailyWordCount returns entries for the given days", async () => {
    await vocabularyService.create(
      { user_id: TEST_USER_ID, word: "today-word" },
      [],
    );

    const daily = await statisticsService.getDailyWordCount(TEST_USER_ID, 7);
    expect(daily).toHaveLength(7);
    expect(daily[daily.length - 1].count).toBe(1);
  });

  it("getRandomWord returns a vocabulary with definitions", async () => {
    const { vocabulary } = await vocabularyService.create(
      { user_id: TEST_USER_ID, word: "random-test" },
      [{ definition_vi: "ngẫu nhiên" }],
    );

    const word = await statisticsService.getRandomWord(TEST_USER_ID);
    expect(word).not.toBeNull();
    expect(word.word).toBe("random-test");
    expect(word.definitions).toHaveLength(1);
  });
});
