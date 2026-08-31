import { describe, it, expect, beforeEach } from "vitest";
import "fake-indexeddb/auto";
import db from "../../db/database";
import { collectionService } from "../collection.service";
import { vocabularyService } from "../vocabulary.service";

const TEST_USER_ID = "test-user-123";

beforeEach(async () => {
  await db.collections.clear();
  await db.vocabularies.clear();
  await db.definitions.clear();
  await db.vocabulary_collections.clear();
  await db.sync_queue.clear();
});

describe("collectionService", () => {
  it("creates a collection", async () => {
    const col = await collectionService.create({
      user_id: TEST_USER_ID,
      name: "IELTS Vocab",
      description: "Words for IELTS exam",
    });

    expect(col.name).toBe("IELTS Vocab");
    expect(col.is_deleted).toBe(false);

    // Sync queue verification
    const queue = await db.sync_queue.toArray();
    expect(queue.some((q) => q.table_name === "collections")).toBe(true);
  });

  it("getAll returns user collections with word count", async () => {
    const col1 = await collectionService.create({
      user_id: TEST_USER_ID,
      name: "Travel",
    });
    const col2 = await collectionService.create({
      user_id: TEST_USER_ID,
      name: "Business",
    });

    const { vocabulary } = await vocabularyService.create(
      { user_id: TEST_USER_ID, word: "flight" },
      [],
    );

    await collectionService.assignWord(vocabulary.id, col1.id);

    const result = await collectionService.getAll(TEST_USER_ID);
    expect(result.items).toHaveLength(2);

    const travelCol = result.items.find((c) => c.id === col1.id);
    expect(travelCol.word_count).toBe(1);

    const businessCol = result.items.find((c) => c.id === col2.id);
    expect(businessCol.word_count).toBe(0);
  });

  it("getById returns collection and its vocabularies", async () => {
    const col = await collectionService.create({
      user_id: TEST_USER_ID,
      name: "Food",
    });

    const { vocabulary } = await vocabularyService.create(
      { user_id: TEST_USER_ID, word: "delicious" },
      [{ definition_vi: "ngon miệng" }],
    );

    await collectionService.assignWord(vocabulary.id, col.id);

    const data = await collectionService.getById(col.id);
    expect(data.collection.name).toBe("Food");
    expect(data.vocabularies).toHaveLength(1);
    expect(data.vocabularies[0].word).toBe("delicious");
    expect(data.vocabularies[0].definitions[0].definition_vi).toBe("ngon miệng");
  });

  it("update modifies collection details", async () => {
    const col = await collectionService.create({
      user_id: TEST_USER_ID,
      name: "Old Name",
    });

    const updated = await collectionService.update(col.id, {
      name: "New Name",
      description: "Updated description",
    });

    expect(updated.name).toBe("New Name");
    expect(updated.description).toBe("Updated description");
  });

  it("delete soft deletes collection and removes word links", async () => {
    const col = await collectionService.create({
      user_id: TEST_USER_ID,
      name: "Delete Me",
    });

    await collectionService.delete(col.id);
    const result = await collectionService.getById(col.id);
    expect(result).toBeNull();
  });

  it("removeWord removes vocabulary from collection", async () => {
    const col = await collectionService.create({
      user_id: TEST_USER_ID,
      name: "Temp",
    });

    const { vocabulary } = await vocabularyService.create(
      { user_id: TEST_USER_ID, word: "temp" },
      [],
    );

    await collectionService.assignWord(vocabulary.id, col.id);
    await collectionService.removeWord(vocabulary.id, col.id);

    const data = await collectionService.getById(col.id);
    expect(data.vocabularies).toHaveLength(0);
  });
});
